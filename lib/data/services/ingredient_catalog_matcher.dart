import '../database/app_database.dart';
import '../repositories/catalog_repository.dart';
import 'ingredient_parser_service.dart';

enum IngredientMatchConfidence { matched, unmatched }

class IngredientMatchResult {
  const IngredientMatchResult({
    required this.parsed,
    required this.confidence,
    this.catalogItem,
  });

  final ParsedIngredientLine parsed;
  final IngredientMatchConfidence confidence;
  final CatalogItem? catalogItem;
}

class ImportIngredientDraft {
  ImportIngredientDraft({
    required this.parsed,
    required this.confidence,
    this.catalogItem,
    this.addToCatalog = false,
    this.categoryId = 'other',
    String? displayName,
  }) : displayName = displayName ?? parsed.itemName;

  ParsedIngredientLine parsed;
  IngredientMatchConfidence confidence;
  CatalogItem? catalogItem;
  String displayName;
  bool addToCatalog;
  String categoryId;

  int? get catalogItemId => catalogItem?.id;

  MealIngredientInput toInput() => MealIngredientInput(
        displayName: displayName,
        quantityValue: parsed.quantityValue,
        quantityUnit: parsed.quantityUnit,
        catalogItemId: catalogItemId,
      );
}

class MealIngredientInput {
  const MealIngredientInput({
    required this.displayName,
    this.quantityValue,
    this.quantityUnit,
    this.catalogItemId,
    this.addToShoppingList = true,
  });

  final String displayName;
  final double? quantityValue;
  final String? quantityUnit;
  final int? catalogItemId;
  final bool addToShoppingList;
}

class IngredientCatalogMatcher {
  IngredientCatalogMatcher(this._catalog, this._parser);

  final CatalogRepository _catalog;
  final IngredientParserService _parser;

  static const _noiseWords = {
    'a',
    'an',
    'and',
    'or',
    'of',
    'for',
    'to',
    'the',
    'with',
    'without',
    'optional',
    'fresh',
    'large',
    'small',
    'medium',
    'chopped',
    'diced',
    'sliced',
    'minced',
    'grated',
    'peeled',
    'cooked',
    'raw',
    'boneless',
    'skinless',
    'finely',
    'roughly',
    'thinly',
    'thickly',
    'about',
    'approx',
    'approximately',
    'plus',
    'extra',
    'serving',
    'choice',
  };

  Future<IngredientMatchResult> matchLine(String rawLine) async {
    final parsed = _parser.parse(rawLine);
    if (parsed.itemName.isEmpty) {
      return IngredientMatchResult(
        parsed: parsed,
        confidence: IngredientMatchConfidence.unmatched,
      );
    }

    final catalogItem = await _findMatch(parsed.itemName);
    return IngredientMatchResult(
      parsed: parsed,
      catalogItem: catalogItem,
      confidence: catalogItem != null
          ? IngredientMatchConfidence.matched
          : IngredientMatchConfidence.unmatched,
    );
  }

  Future<List<ImportIngredientDraft>> matchAll(List<String> lines) async {
    final drafts = <ImportIngredientDraft>[];
    for (final line in lines) {
      final result = await matchLine(line);
      drafts.add(
        ImportIngredientDraft(
          parsed: result.parsed,
          confidence: result.confidence,
          catalogItem: result.catalogItem,
          displayName: result.catalogItem?.displayName ?? result.parsed.itemName,
        ),
      );
    }
    return drafts;
  }

  Future<List<CatalogItem>> suggestMatches(
    String itemName, {
    int limit = 5,
  }) async {
    final normalized = itemName.trim().toLowerCase();
    if (normalized.isEmpty) return const [];

    final suggestions = <CatalogItem>[];
    final seenIds = <int>{};

    void add(CatalogItem? item) {
      if (item == null || seenIds.contains(item.id)) return;
      seenIds.add(item.id);
      suggestions.add(item);
    }

    final tokens = _significantTokens(normalized);
    for (final token in tokens) {
      if (suggestions.length >= limit) break;
      add(await _catalog.findByNameOrAlias(token));
    }

    for (final token in tokens) {
      if (suggestions.length >= limit) break;
      final prefixMatches = await _catalog.search(token, limit: 2);
      for (final item in prefixMatches) {
        if (suggestions.length >= limit) break;
        add(item);
      }
    }

    if (suggestions.length < limit) {
      final prefixMatches = await _catalog.search(itemName, limit: limit);
      for (final item in prefixMatches) {
        if (suggestions.length >= limit) break;
        add(item);
      }
    }

    return suggestions;
  }

  Future<CatalogItem?> _findMatch(String itemName) async {
    final normalized = itemName.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final exact = await _catalog.findByNameOrAlias(normalized);
    if (exact != null) return exact;

    final tokens = _significantTokens(normalized);
    for (final token in tokens) {
      final match = await _catalog.findByNameOrAlias(token);
      if (match != null) return match;
    }

    return null;
  }

  List<String> _significantTokens(String normalized) {
    final rawTokens = normalized
        .split(RegExp(r'[\s,/]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final tokens = rawTokens
        .where((t) => t.length > 2 && !_noiseWords.contains(t))
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    return tokens;
  }
}
