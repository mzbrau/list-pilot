import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/seed/database_seeder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseSeeder', () {
    late AppDatabase db;
    late DatabaseSeeder seeder;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      seeder = DatabaseSeeder(db);
    });

    tearDown(() => db.close());

    test('mergeMissingSeedItems adds new seed entries to existing catalog',
        () async {
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: 'pantry',
              name: 'Pantry',
              sortOrder: 6,
            ),
          );
      await db.into(db.catalogItems).insert(
            CatalogItemsCompanion.insert(
              name: 'milk',
              displayName: 'Milk',
              categoryId: 'dairy',
              createdAt: DateTime(2026, 1, 1),
            ),
          );

      await seeder.mergeMissingSeedItems();

      final pesto = await db.findCatalogByName('Pesto');
      expect(pesto, isNotNull);
      expect(pesto!.categoryId, 'pantry');
      expect(pesto.isUserAdded, false);

      final milk = await db.findCatalogByName('Milk');
      expect(milk, isNotNull);
      expect(milk!.displayName, 'Milk');
    });

    test('seedIfNeeded merges missing items when catalog already populated',
        () async {
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: 'household',
              name: 'Household',
              sortOrder: 10,
            ),
          );
      await db.into(db.catalogItems).insert(
            CatalogItemsCompanion.insert(
              name: 'apples',
              displayName: 'Apples',
              categoryId: 'fruit_veg',
              createdAt: DateTime(2026, 1, 1),
            ),
          );

      await seeder.seedIfNeeded();

      final socks = await db.findCatalogByName('Socks');
      expect(socks, isNotNull);

      final allItems = await db.select(db.catalogItems).get();
      expect(allItems.length, greaterThan(1));
    });

    test('seedIfNeeded seeds empty database from JSON asset', () async {
      await seeder.seedIfNeeded();

      expect(await db.hasCategories(), isTrue);
      expect(await db.hasCatalogItems(), isTrue);

      final seedJson =
          await rootBundle.loadString('assets/seed_catalog.json');
      final seedItems =
          ((json.decode(seedJson) as Map<String, dynamic>)['items']
                  as List<dynamic>)
              .length;

      final count = await db.select(db.catalogItems).get();
      expect(count.length, seedItems);
    });
  });
}
