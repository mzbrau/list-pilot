import 'dart:convert';

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
  })  : _aiConfig = aiConfig,
        _catalogRepository = catalogRepository,
        _matcher = matcher,
        _httpPost = httpPost ?? MealImportHttpClient().post;

  final AiConfig _aiConfig;
  final CatalogRepository _catalogRepository;
  final IngredientCatalogMatcher _matcher;
  final HttpPost _httpPost;

  bool get isConfigured => _aiConfig.isConfigured;

  Future<List<ReceiptEnrichedLine>> enrichLines(
    List<IcaReceiptLineItem> lines,
  ) async {
    final aiResults = _aiConfig.isConfigured
        ? await _fetchAiTranslations(lines)
        : <int, ({String englishName, String categoryId})>{};

    final enriched = <ReceiptEnrichedLine>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final ai = aiResults[i];
      final englishName = ai?.englishName ?? line.description;
      final aiCategory = ai?.categoryId ?? 'other';

      final match = await _matcher.matchLine(englishName);
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
      _fetchAiTranslations(List<IcaReceiptLineItem> lines) async {
    final categories = await _catalogRepository.getCategories();
    final categoryIds = categories.map((c) => c.id).toList();
    final baseUri = _aiConfig.apiUri!.trim().replaceAll(RegExp(r'/+$'), '');
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
      'model': _aiConfig.modelName!.trim(),
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
      'Authorization': 'Bearer ${_aiConfig.apiKey!.trim()}',
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
    IcaReceiptParser? parser,
  })  : _repository = repository,
        _pdfService = pdfService,
        _enrichmentService = enrichmentService,
        _parser = parser ?? IcaReceiptParser();

  final ReceiptRepository _repository;
  final ReceiptPdfService _pdfService;
  final ReceiptItemEnrichmentService _enrichmentService;
  final IcaReceiptParser _parser;

  bool get aiConfigured => _enrichmentService.isConfigured;

  Future<int> importPdf({
    required int listId,
    required String sourcePdfPath,
  }) async {
    final text = await _pdfService.extractTextFromFile(sourcePdfPath);
    final parsed = _parser.parse(text);
    final enriched = await _enrichmentService.enrichLines(parsed.lines);

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
}

class ReceiptImportException implements Exception {
  const ReceiptImportException(this.message);
  final String message;

  @override
  String toString() => message;
}
