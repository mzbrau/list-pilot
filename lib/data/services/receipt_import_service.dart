import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/providers/app_providers.dart';
import '../repositories/catalog_repository.dart';
import '../repositories/receipt_repository.dart';
import 'ica_receipt_parser.dart';
import 'ingredient_catalog_matcher.dart';
import 'meal_import_service.dart';
import 'receipt_pdf_service.dart';

class ReceiptEnrichedLine {
  const ReceiptEnrichedLine({
    required this.originalDescription,
    required this.englishName,
    this.catalogItemId,
    required this.categoryId,
    this.articleNumber,
    this.unitPrice,
    this.quantity,
    this.quantityUnit,
    required this.lineTotal,
    required this.sortOrder,
  });

  final String originalDescription;
  final String englishName;
  final int? catalogItemId;
  final String categoryId;
  final String? articleNumber;
  final double? unitPrice;
  final double? quantity;
  final String? quantityUnit;
  final double lineTotal;
  final int sortOrder;
}

class ReceiptImportFileError {
  const ReceiptImportFileError({
    required this.fileName,
    required this.message,
  });

  final String fileName;
  final String message;
}

class ReceiptImportResult {
  const ReceiptImportResult({
    required this.imported,
    required this.skipped,
    required this.failed,
    required this.errors,
    this.importedReceiptIds = const [],
  });

  final int imported;
  final int skipped;
  final int failed;
  final List<ReceiptImportFileError> errors;
  final List<int> importedReceiptIds;
}

typedef ReceiptImportProgress = void Function(
  int current,
  int total,
  String fileName,
);

String buildReceiptEnrichmentSystemPrompt({
  required List<String> categoryIds,
}) {
  return '''
You translate Swedish grocery receipt item descriptions to UK English and assign a category.
Respond with JSON only, no markdown.
Use categoryId values only from this list: ${categoryIds.join(', ')}.
Use "other" when unsure.
Schema:
{
  "items": [
    {
      "index": 0,
      "englishName": "Apricots",
      "categoryId": "fruit_veg"
    }
  ]
}
''';
}

class ReceiptItemEnrichmentService {
  ReceiptItemEnrichmentService({
    required AiConfig aiConfig,
    required CatalogRepository catalogRepository,
    required IngredientCatalogMatcher matcher,
    HttpPost? httpPost,
  })  : _defaultAiConfig = aiConfig,
        _catalogRepository = catalogRepository,
        _matcher = matcher,
        _httpPost = httpPost ?? MealImportHttpClient().post;

  final AiConfig _defaultAiConfig;
  final CatalogRepository _catalogRepository;
  final IngredientCatalogMatcher _matcher;
  final HttpPost _httpPost;

  bool get isConfigured => _defaultAiConfig.isConfigured;

  Future<List<ReceiptEnrichedLine>> enrichLines(
    List<IcaReceiptLineItem> lines, {
    AiConfig? aiConfig,
  }) async {
    final config = aiConfig ?? _defaultAiConfig;
    final aiResults = config.isConfigured
        ? await _fetchAiTranslations(lines, config)
        : <int, ({String englishName, String categoryId})>{};

    final enriched = <ReceiptEnrichedLine>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final ai = aiResults[i];
      final englishName = ai?.englishName ?? line.description;
      final aiCategory = ai?.categoryId ?? 'other';

      final match = await _matcher.matchBest(
        englishName,
        fallbackName: line.description,
      );
      final catalogItem = match.catalogItem;
      enriched.add(
        ReceiptEnrichedLine(
          originalDescription: line.description,
          englishName: catalogItem?.displayName ?? englishName,
          catalogItemId: catalogItem?.id,
          categoryId: catalogItem?.categoryId ?? aiCategory,
          articleNumber: line.articleNumber,
          unitPrice: line.unitPrice,
          quantity: line.quantity,
          quantityUnit: line.quantityUnit,
          lineTotal: line.lineTotal,
          sortOrder: i,
        ),
      );
    }
    return enriched;
  }

  Future<Map<int, ({String englishName, String categoryId})>>
      _fetchAiTranslations(
    List<IcaReceiptLineItem> lines,
    AiConfig aiConfig,
  ) async {
    final categories = await _catalogRepository.getCategories();
    final categoryIds = categories.map((c) => c.id).toList();
    final baseUri = aiConfig.apiUri!.trim().replaceAll(RegExp(r'/+$'), '');
    final apiUri = Uri.parse('$baseUri/chat/completions');

    final payload = lines
        .asMap()
        .entries
        .map(
          (entry) => {
            'index': entry.key,
            'description': entry.value.description,
          },
        )
        .toList();

    final body = {
      'model': aiConfig.modelName!.trim(),
      'messages': [
        {
          'role': 'system',
          'content': buildReceiptEnrichmentSystemPrompt(categoryIds: categoryIds),
        },
        {
          'role': 'user',
          'content':
              'Translate these Swedish grocery receipt items to UK English:\n${jsonEncode(payload)}',
        },
      ],
      'response_format': {'type': 'json_object'},
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${aiConfig.apiKey!.trim()}',
    };

    var response = await _httpPost(
      apiUri,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      body.remove('response_format');
      response = await _httpPost(
        apiUri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 90));
    }

    if (response.statusCode != 200) {
      throw ReceiptImportException(
        'AI enrichment failed (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const ReceiptImportException('No choices in AI response');
    }
    final message = choices.first as Map<String, dynamic>;
    final content =
        (message['message'] as Map<String, dynamic>)['content'] as String;
    final itemsJson = jsonDecode(content) as Map<String, dynamic>;
    final items = itemsJson['items'] as List<dynamic>? ?? [];

    final results = <int, ({String englishName, String categoryId})>{};
    for (final entry in items) {
      if (entry is! Map<String, dynamic>) continue;
      final index = entry['index'];
      if (index is! int) continue;
      final englishName = (entry['englishName'] as String?)?.trim();
      final categoryId = (entry['categoryId'] as String?)?.trim();
      if (englishName == null || englishName.isEmpty) continue;
      results[index] = (
        englishName: englishName,
        categoryId: categoryId?.isNotEmpty == true ? categoryId! : 'other',
      );
    }
    return results;
  }
}

class ReceiptImportService {
  ReceiptImportService({
    required ReceiptRepository repository,
    required ReceiptPdfService pdfService,
    required ReceiptItemEnrichmentService enrichmentService,
    required Future<AiConfig> Function() resolveAiConfig,
    IcaReceiptParser? parser,
  })  : _repository = repository,
        _pdfService = pdfService,
        _enrichmentService = enrichmentService,
        _resolveAiConfig = resolveAiConfig,
        _parser = parser ?? IcaReceiptParser();

  final ReceiptRepository _repository;
  final ReceiptPdfService _pdfService;
  final ReceiptItemEnrichmentService _enrichmentService;
  final Future<AiConfig> Function() _resolveAiConfig;
  final IcaReceiptParser _parser;

  bool get aiConfigured => _enrichmentService.isConfigured;

  Future<int> importPdf({
    required int listId,
    required String sourcePdfPath,
  }) async {
    final aiConfig = await _resolveAiConfig();
    final text = await _pdfService.extractTextFromFile(sourcePdfPath);
    final parsed = _parser.parse(text);
    final enriched = await _enrichmentService.enrichLines(
      parsed.lines,
      aiConfig: aiConfig,
    );

    final draft = ReceiptImportDraft(
      shopName: parsed.shopName,
      purchasedAt: parsed.purchasedAt,
      receiptNumber: parsed.receiptNumber,
      totalAmount: parsed.totalAmount,
      lines: enriched
          .map(
            (line) => ReceiptLineDraft(
              originalDescription: line.originalDescription,
              englishName: line.englishName,
              catalogItemId: line.catalogItemId,
              categoryId: line.categoryId,
              articleNumber: line.articleNumber,
              unitPrice: line.unitPrice,
              quantity: line.quantity,
              quantityUnit: line.quantityUnit,
              lineTotal: line.lineTotal,
              sortOrder: line.sortOrder,
            ),
          )
          .toList(),
    );

    return _repository.importReceipt(
      listId: listId,
      draft: draft,
      sourcePdfPath: sourcePdfPath,
    );
  }

  Future<ReceiptImportResult> importFolder(
    String folderPath, {
    required int listId,
    ReceiptImportProgress? onProgress,
  }) async {
    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw ReceiptImportException('Folder not found: $folderPath');
    }

    final pdfFiles = await _findPdfFiles(folder);
    final paths = pdfFiles.map((file) => file.path).toList();
    return importPdfs(
      paths,
      listId: listId,
      onProgress: onProgress,
    );
  }

  Future<ReceiptImportResult> importPdfs(
    List<String> paths, {
    required int listId,
    ReceiptImportProgress? onProgress,
  }) async {
    if (paths.isEmpty) {
      return const ReceiptImportResult(
        imported: 0,
        skipped: 0,
        failed: 0,
        errors: [],
      );
    }

    var completed = 0;
    final outcomes = <_ImportOutcome>[];
    for (final path in paths) {
      final fileName = p.basename(path);
      try {
        final receiptId = await importPdf(
          listId: listId,
          sourcePdfPath: path,
        );
        outcomes.add(_ImportOutcome.imported(receiptId));
      } on DuplicateReceiptException catch (e) {
        outcomes.add(_ImportOutcome.skipped(e.existingReceiptId));
      } on IcaReceiptParseException catch (e) {
        outcomes.add(
          _ImportOutcome.failed(
            ReceiptImportFileError(fileName: fileName, message: e.message),
          ),
        );
      } on ReceiptImportException catch (e) {
        outcomes.add(
          _ImportOutcome.failed(
            ReceiptImportFileError(fileName: fileName, message: e.message),
          ),
        );
      } catch (e) {
        outcomes.add(
          _ImportOutcome.failed(
            ReceiptImportFileError(fileName: fileName, message: e.toString()),
          ),
        );
      } finally {
        completed++;
        onProgress?.call(completed, paths.length, fileName);
      }
    }

    var imported = 0;
    var skipped = 0;
    var failed = 0;
    final errors = <ReceiptImportFileError>[];
    final importedReceiptIds = <int>[];

    for (final outcome in outcomes) {
      switch (outcome.kind) {
        case _ImportOutcomeKind.imported:
          imported++;
          importedReceiptIds.add(outcome.receiptId!);
        case _ImportOutcomeKind.skipped:
          skipped++;
        case _ImportOutcomeKind.failed:
          failed++;
          errors.add(outcome.error!);
      }
    }

    return ReceiptImportResult(
      imported: imported,
      skipped: skipped,
      failed: failed,
      errors: errors,
      importedReceiptIds: importedReceiptIds,
    );
  }

  Future<List<File>> _findPdfFiles(Directory directory) async {
    final files = <File>[];
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
        files.add(entity);
      }
    }
    files.sort((a, b) => a.path.compareTo(b.path));
    return files;
  }
}

enum _ImportOutcomeKind { imported, skipped, failed }

class _ImportOutcome {
  const _ImportOutcome._({
    required this.kind,
    this.receiptId,
    this.error,
  });

  factory _ImportOutcome.imported(int receiptId) => _ImportOutcome._(
        kind: _ImportOutcomeKind.imported,
        receiptId: receiptId,
      );

  factory _ImportOutcome.skipped(int existingReceiptId) => _ImportOutcome._(
        kind: _ImportOutcomeKind.skipped,
        receiptId: existingReceiptId,
      );

  factory _ImportOutcome.failed(ReceiptImportFileError error) =>
      _ImportOutcome._(
        kind: _ImportOutcomeKind.failed,
        error: error,
      );

  final _ImportOutcomeKind kind;
  final int? receiptId;
  final ReceiptImportFileError? error;
}

class ReceiptImportException implements Exception {
  const ReceiptImportException(this.message);
  final String message;

  @override
  String toString() => message;
}
