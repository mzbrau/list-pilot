import 'package:drift/drift.dart';

import '../database/app_database.dart';

class ShopStatsComparison {
  const ShopStatsComparison({
    required this.shopNumber,
    required this.rank,
    this.previousDeltaMs,
    this.bestDeltaMs,
    this.averageDeltaMs,
    this.isPersonalBest = false,
  });

  final int shopNumber;
  final int rank;
  final int? previousDeltaMs;
  final int? bestDeltaMs;
  final int? averageDeltaMs;
  final bool isPersonalBest;
}

class ShopCompletionResult {
  const ShopCompletionResult({
    required this.duration,
    required this.itemCount,
    required this.msPerItem,
    required this.comparison,
  });

  final Duration duration;
  final int itemCount;
  final Duration msPerItem;
  final ShopStatsComparison comparison;
}

class ListShopAggregates {
  const ListShopAggregates({
    required this.shopCount,
    this.bestMsPerItem,
    this.averageMsPerItem,
    this.mostRecent,
  });

  final int shopCount;
  final int? bestMsPerItem;
  final int? averageMsPerItem;
  final ShopStatsRecord? mostRecent;
}

class ShopStatsRepository {
  ShopStatsRepository(this._db);

  final AppDatabase _db;

  Stream<List<ShopStatsRecord>> watchRecordsForList(int listId) {
    return (_db.select(_db.shopStatsRecords)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .watch();
  }

  Stream<List<ShopStatsRecord>> watchAllRecords() {
    return (_db.select(_db.shopStatsRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .watch();
  }

  Future<List<ShopStatsRecord>> getRecordsForList(int listId) async {
    final records = await (_db.select(_db.shopStatsRecords)
          ..where((t) => t.listId.equals(listId)))
        .get();
    records.sort((a, b) => _msPerItem(a).compareTo(_msPerItem(b)));
    return records;
  }

  Future<List<ShopStatsRecord>> getAllRecords() {
    return (_db.select(_db.shopStatsRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .get();
  }

  Future<ListShopAggregates> getListAggregates(int listId) async {
    final records = await (_db.select(_db.shopStatsRecords)
          ..where((t) => t.listId.equals(listId)))
        .get();

    if (records.isEmpty) {
      return const ListShopAggregates(shopCount: 0);
    }

    final msPerItems = records.map(_msPerItem).toList();
    final best = msPerItems.reduce((a, b) => a < b ? a : b);
    final average = msPerItems.reduce((a, b) => a + b) ~/ msPerItems.length;

    final mostRecent = await (_db.select(_db.shopStatsRecords)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
          ..limit(1))
        .getSingleOrNull();

    return ListShopAggregates(
      shopCount: records.length,
      bestMsPerItem: best,
      averageMsPerItem: average,
      mostRecent: mostRecent,
    );
  }

  Future<int?> getLongTermAverageMsPerItem(int listId) async {
    final aggregates = await getListAggregates(listId);
    if (aggregates.shopCount < 2) return null;
    return aggregates.averageMsPerItem;
  }

  Future<ShopCompletionResult?> onItemCheckedOff({
    required int listId,
    required int remainingAfter,
    required int totalItems,
    required DateTime checkedAt,
  }) async {
    final list = await _db.getListById(listId);
    if (list == null) return null;

    var startedAt = list.activeShopStartedAt;
    if (startedAt == null) {
      startedAt = checkedAt;
      await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
          .write(
        ShoppingListsCompanion(activeShopStartedAt: Value(startedAt)),
      );
    }

    if (remainingAfter > 0) return null;

    final duration = checkedAt.difference(startedAt);
    final msPerItem = totalItems > 0
        ? duration.inMilliseconds ~/ totalItems
        : 0;

    await _db.into(_db.shopStatsRecords).insert(
          ShopStatsRecordsCompanion.insert(
            listId: listId,
            startedAt: startedAt,
            completedAt: checkedAt,
            itemCount: totalItems,
          ),
        );

    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
        .write(
      const ShoppingListsCompanion(activeShopStartedAt: Value(null)),
    );

    final comparison = await _buildComparison(listId, msPerItem);

    return ShopCompletionResult(
      duration: duration,
      itemCount: totalItems,
      msPerItem: Duration(milliseconds: msPerItem),
      comparison: comparison,
    );
  }

  Future<void> abandonSession(int listId) async {
    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
        .write(
      const ShoppingListsCompanion(activeShopStartedAt: Value(null)),
    );
  }

  Future<void> abandonAllSessions() async {
    await (_db.update(_db.shoppingLists)).write(
      const ShoppingListsCompanion(activeShopStartedAt: Value(null)),
    );
  }

  Future<void> deleteRecordsForList(int listId) async {
    await (_db.delete(_db.shopStatsRecords)
          ..where((t) => t.listId.equals(listId)))
        .go();
  }

  Future<ShopStatsComparison> _buildComparison(
    int listId,
    int currentMsPerItem,
  ) async {
    final records = await (_db.select(_db.shopStatsRecords)
          ..where((t) => t.listId.equals(listId)))
        .get();

    final shopNumber = records.length;
    final sortedByPace = [...records]
      ..sort((a, b) => _msPerItem(a).compareTo(_msPerItem(b)));
    final rank = sortedByPace.indexWhere((r) => _msPerItem(r) == currentMsPerItem) +
        1;

    final sortedByDate = [...records]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    int? previousDeltaMs;
    if (sortedByDate.length > 1) {
      previousDeltaMs =
          currentMsPerItem - _msPerItem(sortedByDate[1]);
    }

    final bestMsPerItem =
        sortedByPace.map(_msPerItem).reduce((a, b) => a < b ? a : b);
    final isPersonalBest = currentMsPerItem <= bestMsPerItem;

    int? bestDeltaMs;
    if (!isPersonalBest) {
      bestDeltaMs = currentMsPerItem - bestMsPerItem;
    }

    int? averageDeltaMs;
    if (sortedByDate.length > 1) {
      final previous = sortedByDate.skip(1);
      final average =
          previous.map(_msPerItem).reduce((a, b) => a + b) ~/ previous.length;
      averageDeltaMs = currentMsPerItem - average;
    }

    return ShopStatsComparison(
      shopNumber: shopNumber,
      rank: rank,
      previousDeltaMs: previousDeltaMs,
      bestDeltaMs: bestDeltaMs,
      averageDeltaMs: averageDeltaMs,
      isPersonalBest: isPersonalBest,
    );
  }

  int _msPerItem(ShopStatsRecord record) {
    final durationMs =
        record.completedAt.difference(record.startedAt).inMilliseconds;
    if (record.itemCount <= 0) return 0;
    return durationMs ~/ record.itemCount;
  }
}
