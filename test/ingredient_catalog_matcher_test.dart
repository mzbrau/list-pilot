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
}
