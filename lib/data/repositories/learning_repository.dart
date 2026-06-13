import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/constants/app_constants.dart';
import '../../features/learning/ordering_service.dart';
import '../../features/learning/trip_detector.dart';
import '../database/app_database.dart';

class LearningRepository {
  LearningRepository(this._db);

  final AppDatabase _db;
  final OrderingService _ordering = OrderingService();
  final TripDetector _tripDetector = TripDetector();

  final Map<int, Timer?> _recomputeTimers = {};

  Future<void> recordCheckOff({
    required int listId,
    required int listItemId,
  }) async {
    final item = await _db.getListItemById(listItemId);
    if (item == null) return;

    final shoppingList = await _db.getListById(listId);
    if (shoppingList == null) return;

    final now = DateTime.now();
    var tripId = shoppingList.currentTripId;
    var sequence = shoppingList.currentTripSequence;

    if (_tripDetector.shouldStartNewTrip(
      lastCheckOffAt: shoppingList.lastCheckOffAt,
      now: now,
    )) {
      tripId += 1;
      sequence = 0;
    }

    final weight = await _computeEventWeight(listId, tripId, now);

    await _db.into(_db.checkOffEvents).insert(
          CheckOffEventsCompanion.insert(
            listId: listId,
            listItemId: listItemId,
            categoryId: item.categoryId,
            catalogItemId: Value(item.catalogItemId),
            checkedAt: now,
            sequenceIndex: sequence,
            tripId: tripId,
            weight: Value(weight),
          ),
        );

    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
        .write(
      ShoppingListsCompanion(
        currentTripId: Value(tripId),
        currentTripSequence: Value(sequence + 1),
        lastCheckOffAt: Value(now),
      ),
    );

    _scheduleRecompute(listId);
  }

  Future<double> _computeEventWeight(
    int listId,
    int tripId,
    DateTime now,
  ) async {
    final recentEvents = await (_db.select(_db.checkOffEvents)
          ..where(
            (t) =>
                t.listId.equals(listId) &
                t.tripId.equals(tripId) &
                t.checkedAt.isBiggerOrEqual(
                  Variable(
                    now.subtract(
                      const Duration(seconds: AppConstants.bulkCheckWindowSeconds),
                    ),
                  ),
                ),
          ))
        .get();

    if (recentEvents.length >= 2) {
      return AppConstants.bulkCheckWeight;
    }
    return 1.0;
  }

  void _scheduleRecompute(int listId) {
    _recomputeTimers[listId]?.cancel();
    _recomputeTimers[listId] = Timer(
      const Duration(milliseconds: AppConstants.rankRecomputeDebounceMs),
      () => recomputeRanks(listId),
    );
  }

  Future<void> recomputeRanks(int listId) async {
    final events = await _db.getCheckOffEventsForList(listId);
    final categories = await _db.getAllCategories();
    final categoryOrder = categories.map((c) => c.id).toList();

    final categoryStats = _ordering.computeCategoryRanks(
      events: events,
      defaultCategoryOrder: categoryOrder,
    );

    final itemStats = _ordering.computeItemRanks(events: events);

    final now = DateTime.now();
    for (final stat in categoryStats) {
      await _db.upsertCategoryRankStat(
        CategoryRankStatsCompanion.insert(
          listId: listId,
          categoryId: stat.categoryId,
          medianRank: stat.medianRank,
          sampleCount: stat.sampleCount,
          lastUpdated: now,
        ),
      );
    }

    for (final stat in itemStats) {
      await _db.upsertItemRankStat(
        ItemRankStatsCompanion.insert(
          listId: listId,
          catalogItemId: stat.catalogItemId,
          categoryId: stat.categoryId,
          medianRank: stat.medianRank,
          sampleCount: stat.sampleCount,
          lastUpdated: now,
        ),
      );
    }
  }

  Future<void> resetLearnedOrder(int listId) async {
    await _db.clearRankStatsForList(listId);
  }

  Future<Map<String, double>> getCategoryRanks(int listId) async {
    final stats = await _db.getCategoryRankStats(listId);
    return {for (final s in stats) s.categoryId: s.medianRank};
  }

  Future<Map<int, double>> getItemRanks(int listId) async {
    final stats = await _db.getItemRankStats(listId);
    return {for (final s in stats) s.catalogItemId: s.medianRank};
  }
}
