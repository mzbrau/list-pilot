import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/features/learning/ordering_service.dart';

void main() {
  group('OrderingService', () {
    late OrderingService service;

    setUp(() {
      service = OrderingService();
    });

    test('category rank comes only from user sortOrder', () {
      final item = _listItem();

      final diag = service.diagnosticsForItem(
        item: item,
        categoryOrder: {'dairy': 3, 'cleaning': 9},
        itemStats: {},
      );

      expect(diag.categoryRank, 3);
      expect(diag.itemRank, 999);
      expect(diag.usingDefaultItem, isTrue);
    });

    test('applies learned item order when sample count threshold met', () {
      final item = _listItem();

      final key = service.sortKeyForItem(
        item: item,
        categoryOrder: {'dairy': 3, 'cleaning': 9},
        itemStats: {
          10: _itemStat(
            medianRank: 0,
            sampleCount: 3,
          ),
        },
      );

      // category 3 * 10000 + item 0 * 100 + nameTie
      expect(key, greaterThanOrEqualTo(30000));
      expect(key, lessThan(30100));
    });

    test('item override rank bypasses sample count threshold', () {
      final item = _listItem();
      final now = DateTime.now();

      final diag = service.diagnosticsForItem(
        item: item,
        categoryOrder: {'dairy': 3},
        itemStats: {
          10: ItemRankStat(
            listId: 1,
            catalogItemId: 10,
            categoryId: 'dairy',
            medianRank: 8,
            sampleCount: 1,
            lastUpdated: now,
            overrideRank: 1,
          ),
        },
      );

      expect(diag.categoryRank, 3);
      expect(diag.itemRank, 1);
      expect(diag.itemOverridden, isTrue);
      expect(diag.usingDefaultItem, isFalse);
      expect(diag.sortKey, closeTo(30100, 1));
    });

    test('falls back to default item rank when samples below threshold', () {
      final item = _listItem();

      final diag = service.diagnosticsForItem(
        item: item,
        categoryOrder: {'dairy': 3},
        itemStats: {
          10: _itemStat(medianRank: 0, sampleCount: 2),
        },
      );

      expect(diag.categoryRank, 3);
      expect(diag.itemRank, 999);
      expect(diag.usingDefaultItem, isTrue);
    });

    test('groups active items by category sortOrder', () {
      final now = DateTime.now();
      final items = [
        ListItem(
          id: 1,
          listId: 1,
          catalogItemId: 1,
          displayName: 'Milk',
          categoryId: 'dairy',
          quantityValue: null,
          quantityUnit: null,
          isCompleted: false,
          completedAt: null,
          addedAt: now,
        ),
        ListItem(
          id: 2,
          listId: 1,
          catalogItemId: 2,
          displayName: 'Apples',
          categoryId: 'fruit_veg',
          quantityValue: null,
          quantityUnit: null,
          isCompleted: false,
          completedAt: null,
          addedAt: now,
        ),
      ];
      final categories = [
        Category(id: 'dairy', name: 'Dairy', sortOrder: 1),
        Category(id: 'fruit_veg', name: 'Fruit & Veg', sortOrder: 0),
      ];

      final grouped = service.groupActiveItems(
        items: items,
        categories: categories,
        itemRankStats: const [],
      );

      expect(grouped.keys.toList(), ['Fruit & Veg', 'Dairy']);
    });

    test(
      'category aisle order beats unlearned item ranks across categories',
      () {
        final now = DateTime.now();
        final items = [
          ListItem(
            id: 1,
            listId: 1,
            catalogItemId: 1,
            displayName: 'Unlearned early aisle',
            categoryId: 'fruit_veg',
            quantityValue: null,
            quantityUnit: null,
            isCompleted: false,
            completedAt: null,
            addedAt: now,
          ),
          ListItem(
            id: 2,
            listId: 1,
            catalogItemId: 2,
            displayName: 'Learned later aisle',
            categoryId: 'dairy',
            quantityValue: null,
            quantityUnit: null,
            isCompleted: false,
            completedAt: null,
            addedAt: now,
          ),
        ];
        final categories = [
          Category(id: 'fruit_veg', name: 'Fruit & Veg', sortOrder: 0),
          Category(id: 'dairy', name: 'Dairy', sortOrder: 1),
        ];

        final grouped = service.groupActiveItems(
          items: items,
          categories: categories,
          itemRankStats: [
            ItemRankStat(
              listId: 1,
              catalogItemId: 2,
              categoryId: 'dairy',
              medianRank: 0,
              sampleCount: 10,
              lastUpdated: now,
              overrideRank: null,
            ),
          ],
        );

        // Unlearned fruit_veg item would score ~99,900 on the old scalar key;
        // learned dairy would score ~10,000. Category order must still win.
        expect(grouped.keys.toList(), ['Fruit & Veg', 'Dairy']);
      },
    );

    test('computes median item ranks within category across trips', () {
      final events = [
        _event(tripId: 1, seq: 0, categoryId: 'dairy', catalogId: 10),
        _event(tripId: 1, seq: 1, categoryId: 'dairy', catalogId: 11),
        _event(tripId: 2, seq: 0, categoryId: 'dairy', catalogId: 11),
        _event(tripId: 2, seq: 1, categoryId: 'dairy', catalogId: 10),
      ];

      final results = service.computeItemRanks(events: events);
      final milk = results.firstWhere((r) => r.catalogItemId == 10);
      final cheese = results.firstWhere((r) => r.catalogItemId == 11);

      expect(milk.medianRank, 0.5);
      expect(cheese.medianRank, 0.5);
      expect(milk.sampleCount, 2);
    });

    test('effectiveRank prefers override over median', () {
      expect(
        OrderingService.effectiveRank(
          overrideRank: 2,
          medianRank: 10,
          sampleCount: 10,
          fallback: 99,
        ),
        2,
      );
      expect(
        OrderingService.effectiveRank(
          overrideRank: null,
          medianRank: 10,
          sampleCount: 10,
          fallback: 99,
        ),
        10,
      );
      expect(
        OrderingService.effectiveRank(
          overrideRank: null,
          medianRank: 10,
          sampleCount: 1,
          fallback: 99,
        ),
        99,
      );
    });
  });

  group('CatalogRepository', () {
    late AppDatabase db;
    late CatalogRepository repo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: 'dairy',
              name: 'Dairy',
              sortOrder: 0,
            ),
          );
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: 'fruit_veg',
              name: 'Fruit & Veg',
              sortOrder: 1,
            ),
          );
      repo = CatalogRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('search finds prefix matches', () async {
      await db.into(db.catalogItems).insert(
            CatalogItemsCompanion.insert(
              name: 'milk',
              displayName: 'Milk',
              categoryId: 'dairy',
              createdAt: DateTime.now(),
            ),
          );

      final results = await repo.search('mi');
      expect(results, hasLength(1));
      expect(results.first.displayName, 'Milk');
    });

    test('getOrCreate deduplicates by normalized name', () async {
      final first = await repo.getOrCreate(
        displayName: 'Milk',
        categoryId: 'dairy',
        isUserAdded: true,
      );
      final second = await repo.getOrCreate(
        displayName: 'milk',
        categoryId: 'dairy',
        isUserAdded: true,
      );
      expect(first.id, second.id);
    });

    test('updateCategorySortOrders rewrites global aisle order', () async {
      await repo.updateCategorySortOrders(['fruit_veg', 'dairy']);
      final categories = await repo.getCategories();
      expect(categories.map((c) => c.id).toList(), ['fruit_veg', 'dairy']);
      expect(categories.map((c) => c.sortOrder).toList(), [0, 1]);
    });
  });
}

ListItem _listItem() {
  return ListItem(
    id: 1,
    listId: 1,
    catalogItemId: 10,
    displayName: 'Milk',
    categoryId: 'dairy',
    quantityValue: null,
    quantityUnit: null,
    isCompleted: false,
    completedAt: null,
    addedAt: DateTime.now(),
  );
}

ItemRankStat _itemStat({
  required double medianRank,
  required int sampleCount,
  double? overrideRank,
}) {
  return ItemRankStat(
    listId: 1,
    catalogItemId: 10,
    categoryId: 'dairy',
    medianRank: medianRank,
    sampleCount: sampleCount,
    lastUpdated: DateTime.now(),
    overrideRank: overrideRank,
  );
}

CheckOffEvent _event({
  required int tripId,
  required int seq,
  required String categoryId,
  required int catalogId,
}) {
  return CheckOffEvent(
    id: seq + tripId * 100,
    listId: 1,
    listItemId: seq + 1,
    categoryId: categoryId,
    catalogItemId: catalogId,
    checkedAt: DateTime(2024, 1, tripId, 10, seq),
    sequenceIndex: seq,
    tripId: tripId,
    weight: 1.0,
  );
}
