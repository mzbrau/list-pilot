import '../../core/constants/app_constants.dart';
import '../../data/database/app_database.dart';

class ItemRankResult {
  const ItemRankResult({
    required this.catalogItemId,
    required this.categoryId,
    required this.medianRank,
    required this.sampleCount,
  });

  final int catalogItemId;
  final String categoryId;
  final double medianRank;
  final int sampleCount;
}

/// Breakdown of the sort key components for an active list item.
class ItemSortDiagnostics {
  const ItemSortDiagnostics({
    required this.categoryRank,
    required this.itemRank,
    required this.nameTie,
    required this.sortKey,
    required this.itemOverridden,
    required this.itemSampleCount,
    required this.usingDefaultItem,
  });

  final double categoryRank;
  final double itemRank;
  final double nameTie;
  final double sortKey;
  final bool itemOverridden;
  final int? itemSampleCount;
  final bool usingDefaultItem;

  double get categoryContribution => categoryRank * 10000;
  double get itemContribution => itemRank * 100;
}

class OrderingService {
  /// Effective rank: override if set, else learned median when sample threshold
  /// is met, else [fallback].
  static double effectiveRank({
    required double? overrideRank,
    required double medianRank,
    required int sampleCount,
    required double fallback,
  }) {
    if (overrideRank != null) return overrideRank;
    if (sampleCount >= AppConstants.minSamplesForLearnedOrder) {
      return medianRank;
    }
    return fallback;
  }

  List<ItemRankResult> computeItemRanks({
    required List<CheckOffEvent> events,
  }) {
    final trips = _groupByTrip(events);
    final itemRanks = <int, List<double>>{};
    final itemCategories = <int, String>{};

    for (final tripEvents in trips.values) {
      if (tripEvents.isEmpty) continue;

      final weight = tripEvents.first.weight;
      final categoryCounters = <String, int>{};

      for (final event in tripEvents) {
        final catalogId = event.catalogItemId;
        if (catalogId == null) continue;

        final rank = categoryCounters[event.categoryId] ?? 0;
        categoryCounters[event.categoryId] = rank + 1;

        itemRanks.putIfAbsent(catalogId, () => []).add(rank * weight);
        itemCategories[catalogId] = event.categoryId;
      }
    }

    return itemRanks.entries.map((entry) {
      return ItemRankResult(
        catalogItemId: entry.key,
        categoryId: itemCategories[entry.key] ?? 'other',
        medianRank: _median(entry.value),
        sampleCount: entry.value.length,
      );
    }).toList();
  }

  ItemSortDiagnostics diagnosticsForItem({
    required ListItem item,
    required Map<String, int> categoryOrder,
    required Map<int, ItemRankStat> itemStats,
  }) {
    final categoryRank = categoryOrder[item.categoryId]?.toDouble() ?? 999.0;

    double itemRank = 999.0;
    var itemOverridden = false;
    var usingDefaultItem = true;
    int? itemSampleCount;
    if (item.catalogItemId != null) {
      final itemStat = itemStats[item.catalogItemId!];
      if (itemStat != null) {
        itemSampleCount = itemStat.sampleCount;
        itemOverridden = itemStat.overrideRank != null;
        usingDefaultItem = !itemOverridden &&
            itemStat.sampleCount < AppConstants.minSamplesForLearnedOrder;
        itemRank = effectiveRank(
          overrideRank: itemStat.overrideRank,
          medianRank: itemStat.medianRank,
          sampleCount: itemStat.sampleCount,
          fallback: 999.0,
        );
      }
    }

    final nameTie = item.displayName.toLowerCase().hashCode % 100 / 100.0;
    final sortKey = categoryRank * 10000 + itemRank * 100 + nameTie;

    return ItemSortDiagnostics(
      categoryRank: categoryRank,
      itemRank: itemRank,
      nameTie: nameTie,
      sortKey: sortKey,
      itemOverridden: itemOverridden,
      itemSampleCount: itemSampleCount,
      usingDefaultItem: usingDefaultItem,
    );
  }

  double sortKeyForItem({
    required ListItem item,
    required Map<String, int> categoryOrder,
    required Map<int, ItemRankStat> itemStats,
  }) {
    return diagnosticsForItem(
      item: item,
      categoryOrder: categoryOrder,
      itemStats: itemStats,
    ).sortKey;
  }

  Map<String, int> buildCategoryOrder(List<Category> categories) {
    final sorted = [...categories]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return {for (var i = 0; i < sorted.length; i++) sorted[i].id: i};
  }

  Map<String, List<ListItem>> groupActiveItems({
    required List<ListItem> items,
    required List<Category> categories,
    required List<ItemRankStat> itemRankStats,
  }) {
    final active = items.where((i) => !i.isCompleted).toList();
    final categoryOrder = buildCategoryOrder(categories);
    final itemStatsMap = {
      for (final s in itemRankStats) s.catalogItemId: s,
    };
    final categoryNames = {for (final c in categories) c.id: c.name};

    active.sort((a, b) {
      final catA = categoryOrder[a.categoryId] ?? 999;
      final catB = categoryOrder[b.categoryId] ?? 999;
      final catCmp = catA.compareTo(catB);
      if (catCmp != 0) return catCmp;

      // Category order wins; only compare item ranks within the same aisle.
      final diagA = diagnosticsForItem(
        item: a,
        categoryOrder: categoryOrder,
        itemStats: itemStatsMap,
      );
      final diagB = diagnosticsForItem(
        item: b,
        categoryOrder: categoryOrder,
        itemStats: itemStatsMap,
      );
      final withinA = diagA.itemContribution + diagA.nameTie;
      final withinB = diagB.itemContribution + diagB.nameTie;
      return withinA.compareTo(withinB);
    });

    final grouped = <String, List<ListItem>>{};
    for (final item in active) {
      final header = categoryNames[item.categoryId] ?? item.categoryId;
      grouped.putIfAbsent(header, () => []).add(item);
    }
    return grouped;
  }

  List<ListItem> sortCompletedItems(List<ListItem> items) {
    final completed = items.where((i) => i.isCompleted).toList()
      ..sort((a, b) {
        final aTime = a.completedAt ?? a.addedAt;
        final bTime = b.completedAt ?? b.addedAt;
        return aTime.compareTo(bTime);
      });
    return completed;
  }

  Map<int, List<CheckOffEvent>> _groupByTrip(List<CheckOffEvent> events) {
    final trips = <int, List<CheckOffEvent>>{};
    for (final event in events) {
      trips.putIfAbsent(event.tripId, () => []).add(event);
    }
    for (final trip in trips.values) {
      trip.sort((a, b) => a.sequenceIndex.compareTo(b.sequenceIndex));
    }
    return trips;
  }

  double _median(List<double> values) {
    if (values.isEmpty) return 0;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }
}
