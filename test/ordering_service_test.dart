import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shop_flow/data/database/app_database.dart';
import 'package:shop_flow/data/repositories/catalog_repository.dart';
import 'package:shop_flow/features/learning/ordering_service.dart';

void main() {
  group('OrderingService', () {
    late OrderingService service;

    setUp(() {
      service = OrderingService();
    });

    test('computes median category first-rank across trips', () {
      final events = [
        _event(tripId: 1, seq: 0, categoryId: 'cleaning', catalogId: 1),
        _event(tripId: 1, seq: 1, categoryId: 'dairy', catalogId: 2),
        _event(tripId: 2, seq: 0, categoryId: 'dairy', catalogId: 2),
        _event(tripId: 2, seq: 1, categoryId: 'cleaning', catalogId: 1),
      ];

      final results = service.computeCategoryRanks(
        events: events,
        defaultCategoryOrder: ['dairy', 'cleaning'],
      );

      final cleaning = results.firstWhere((r) => r.categoryId == 'cleaning');
      final dairy = results.firstWhere((r) => r.categoryId == 'dairy');

      expect(cleaning.medianRank, 0.5);
      expect(dairy.medianRank, 0.5);
      expect(cleaning.sampleCount, 2);
    });

    test('applies learned order when sample count threshold met', () {
      final item = ListItem(
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

      final key = service.sortKeyForItem(
        item: item,
        defaultCategoryOrder: {'dairy': 3, 'cleaning': 9},
        categoryStats: {
          'dairy': CategoryRankStat(
            listId: 1,
            categoryId: 'dairy',
            medianRank: 1,
            sampleCount: 3,
            lastUpdated: DateTime.now(),
          ),
        },
        itemStats: {
          10: ItemRankStat(
            listId: 1,
            catalogItemId: 10,
            categoryId: 'dairy',
            medianRank: 0,
            sampleCount: 3,
            lastUpdated: DateTime.now(),
          ),
        },
      );

      expect(key, lessThan(20000));
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
  });
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
