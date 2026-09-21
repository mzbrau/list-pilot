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

  /// Normalized key used for exact matching and alias creation.
  String get matchKey => IngredientCatalogMatcher.matchKey(parsed.itemName);

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

  /// Strips prep/noise words and punctuation for exact matching / aliases.
  static String matchKey(String itemName) {
    final lowered = itemName.trim().toLowerCase();
    if (lowered.isEmpty) return '';

    final tokens = lowered
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty && !_noiseWords.contains(t))
        .toList();

    return tokens.join(' ');
  }

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

  /// Tries [primaryName] first, then optional [fallbackName] (e.g. Swedish original).
  Future<IngredientMatchResult> matchBest(
    String primaryName, {
    String? fallbackName,
  }) async {
    final primary = await matchLine(primaryName);
    if (primary.catalogItem != null) return primary;

    final fallback = fallbackName?.trim();
    if (fallback == null ||
        fallback.isEmpty ||
        fallback.toLowerCase() == primaryName.trim().toLowerCase()) {
      return primary;
    }

    return matchLine(fallback);
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
    final key = matchKey(itemName);
    final normalized = key.isNotEmpty ? key : itemName.trim().toLowerCase();
    if (normalized.isEmpty) return const [];

    final suggestions = <CatalogItem>[];
    final seenIds = <int>{};

    void add(CatalogItem? item) {
      if (item == null || seenIds.contains(item.id)) return;
      seenIds.add(item.id);
      suggestions.add(item);
    }

    for (final variant in _pluralVariants(normalized)) {
      if (suggestions.length >= limit) break;
      add(await _catalog.findByNameOrAlias(variant));
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
      final prefixMatches = await _catalog.search(normalized, limit: limit);
      for (final item in prefixMatches) {
        if (suggestions.length >= limit) break;
        add(item);
      }
    }

    return suggestions;
  }

  /// Auto-match only on exact name/alias (after noise strip + plural variants).
  Future<CatalogItem?> _findMatch(String itemName) async {
    final key = matchKey(itemName);
    if (key.isEmpty) return null;

    for (final variant in _pluralVariants(key)) {
      final match = await _catalog.findByNameOrAlias(variant);
      if (match != null) return match;
    }
    return null;
  }

  /// Simple singular/plural variants of [key] for exact lookup.
  static List<String> _pluralVariants(String key) {
    final variants = <String>{key};
    if (key.endsWith('ies') && key.length > 3) {
      variants.add('${key.substring(0, key.length - 3)}y');
    } else if (key.endsWith('oes') && key.length > 3) {
      variants.add(key.substring(0, key.length - 2));
    } else if (key.endsWith('ses') && key.length > 3) {
      variants.add(key.substring(0, key.length - 2));
    } else if (key.endsWith('s') && !key.endsWith('ss') && key.length > 1) {
      variants.add(key.substring(0, key.length - 1));
    }

    if (!key.endsWith('s')) {
      if (key.endsWith('y') &&
          key.length > 1 &&
          !_isVowel(key[key.length - 2])) {
        variants.add('${key.substring(0, key.length - 1)}ies');
      } else if (key.endsWith('o')) {
        variants.add('${key}es');
      } else {
        variants.add('${key}s');
      }
    }

    return variants.toList();
  }

  static bool _isVowel(String char) =>
      const {'a', 'e', 'i', 'o', 'u'}.contains(char);

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
