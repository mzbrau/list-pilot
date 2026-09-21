import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/services/ingredient_catalog_matcher.dart';
import 'package:list_pilot/data/services/ingredient_parser_service.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository catalogRepo;
  late IngredientCatalogMatcher matcher;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(id: 'fruit_veg', name: 'Fruit & Veg', sortOrder: 0),
        );
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'potatoes',
            displayName: 'Potatoes',
            categoryId: 'fruit_veg',
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'onion',
            displayName: 'Onion',
            categoryId: 'fruit_veg',
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'apples',
            displayName: 'Apples',
            categoryId: 'fruit_veg',
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'green apple',
            displayName: 'Green apple',
            categoryId: 'fruit_veg',
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'spring onions',
            displayName: 'Spring onions',
            categoryId: 'fruit_veg',
            createdAt: DateTime.now(),
          ),
        );
    catalogRepo = CatalogRepository(db);
    matcher = IngredientCatalogMatcher(
      catalogRepo,
      const IngredientParserService(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('matches exact catalog name', () async {
    final result = await matcher.matchLine('Potatoes');
    expect(result.confidence, IngredientMatchConfidence.matched);
    expect(result.catalogItem?.displayName, 'Potatoes');
  });

  test('does not auto-match descriptive token-only names', () async {
    final result = await matcher.matchLine('chat potatoes');
    expect(result.confidence, IngredientMatchConfidence.unmatched);
    expect(result.catalogItem, isNull);
  });

  test('returns unmatched for unknown item', () async {
    final result = await matcher.matchLine('lettuce or buns of choice for serving');
    expect(result.confidence, IngredientMatchConfidence.unmatched);
    expect(result.catalogItem, isNull);
  });

  test('parses and matches combined line', () async {
    final result = await matcher.matchLine('750g potatoes');
    expect(result.parsed.quantityValue, 750);
    expect(result.parsed.itemName, 'Potatoes');
    expect(result.confidence, IngredientMatchConfidence.matched);
  });

  test('strips prep words and matches exact plural catalog name', () async {
    final result = await matcher.matchLine('1 spring onion, sliced');
    expect(result.confidence, IngredientMatchConfidence.matched);
    expect(result.catalogItem?.displayName, 'Spring onions');
  });

  test('does not match green onion to green apple', () async {
    final result = await matcher.matchLine('1 green onion , sliced');
    expect(result.confidence, IngredientMatchConfidence.unmatched);
    expect(result.catalogItem, isNull);
  });

  test('matchKey strips sliced and punctuation', () {
    expect(
      IngredientCatalogMatcher.matchKey('green onion , sliced'),
      'green onion',
    );
  });

  test('matchKey preserves accented Unicode letters', () {
    expect(
      IngredientCatalogMatcher.matchKey('Crème fraîche, sliced'),
      'crème fraîche',
    );
    expect(
      IngredientCatalogMatcher.matchKey('Tomato purée'),
      'tomato purée',
    );
    expect(
      IngredientCatalogMatcher.matchKey('Béarnaise sauce'),
      'béarnaise sauce',
    );
  });

  test('suggestMatches returns token match for descriptive name', () async {
    final suggestions = await matcher.suggestMatches('green apples');
    expect(
      suggestions.map((item) => item.displayName),
      containsAll(['Apples', 'Green apple']),
    );
  });

  test('suggestMatches suggests onion-related items for green onion', () async {
    final suggestions = await matcher.suggestMatches('green onion, sliced');
    expect(
      suggestions.map((item) => item.displayName),
      anyOf(contains('Onion'), contains('Spring onions')),
    );
  });

  test('suggestMatches returns empty list for unknown item', () async {
    final suggestions =
        await matcher.suggestMatches('unicorn tears and moon dust');
    expect(suggestions, isEmpty);
  });

  test('suggestMatches dedupes when multiple strategies match same item', () async {
    final suggestions = await matcher.suggestMatches('apples');
    expect(suggestions.where((item) => item.displayName == 'Apples').length, 1);
  });

  test('matches catalog item via alias', () async {
    final capsicum = await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'capsicum',
            displayName: 'Capsicum',
            categoryId: 'fruit_veg',
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.catalogItemAliases).insert(
          CatalogItemAliasesCompanion.insert(
            catalogItemId: capsicum,
            alias: 'bell peppers',
            createdAt: DateTime.now(),
          ),
        );

    final result = await matcher.matchLine('bell peppers');
    expect(result.confidence, IngredientMatchConfidence.matched);
    expect(result.catalogItem?.displayName, 'Capsicum');
  });

  test('exact plural variant matches apples from apple', () async {
    final result = await matcher.matchLine('1 apple');
    expect(result.confidence, IngredientMatchConfidence.matched);
    expect(result.catalogItem?.displayName, 'Apples');
  });

  test('does not auto-match via prefix search on shared token', () async {
    final result = await matcher.matchLine('green apple pie filling');
    expect(result.confidence, IngredientMatchConfidence.unmatched);
  });

  test('does not auto-match via contained catalog name', () async {
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'cream cheese',
            displayName: 'Cream cheese',
            categoryId: 'other',
            createdAt: DateTime.now(),
          ),
        );

    final result = await matcher.matchLine('philadelphia cream cheese 200g');
    expect(result.confidence, IngredientMatchConfidence.unmatched);
  });

  test('matchBest falls back to secondary name', () async {
    final result = await matcher.matchBest(
      'unknown english item',
      fallbackName: 'Potatoes',
    );
    expect(result.confidence, IngredientMatchConfidence.matched);
    expect(result.catalogItem?.displayName, 'Potatoes');
  });
}
