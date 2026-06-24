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

  test('matches token from descriptive name', () async {
    final result = await matcher.matchLine('chat potatoes');
    expect(result.confidence, IngredientMatchConfidence.matched);
    expect(result.catalogItem?.displayName, 'Potatoes');
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

  test('suggestMatches returns token match for descriptive name', () async {
    final suggestions = await matcher.suggestMatches('green apples');
    expect(suggestions.map((item) => item.displayName), ['Apples']);
  });

  test('suggestMatches returns empty list for unknown item', () async {
    final suggestions =
        await matcher.suggestMatches('unicorn tears and moon dust');
    expect(suggestions, isEmpty);
  });

  test('suggestMatches dedupes when multiple strategies match same item', () async {
    final suggestions = await matcher.suggestMatches('apples');
    expect(suggestions.length, 1);
    expect(suggestions.first.displayName, 'Apples');
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

  test('matches via prefix search on token', () async {
    final result = await matcher.matchLine('green apple');
    expect(result.confidence, IngredientMatchConfidence.matched);
    expect(result.catalogItem?.displayName, 'Apples');
  });

  test('matches via contained catalog name in descriptive phrase', () async {
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'cream cheese',
            displayName: 'Cream cheese',
            categoryId: 'other',
            createdAt: DateTime.now(),
          ),
        );

    final result = await matcher.matchLine('philadelphia cream cheese 200g');
    expect(result.confidence, IngredientMatchConfidence.matched);
    expect(result.catalogItem?.displayName, 'Cream cheese');
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
