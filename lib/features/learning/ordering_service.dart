import '../../core/constants/app_constants.dart';
import '../../data/database/app_database.dart';

class CategoryRankResult {
  const CategoryRankResult({
    required this.categoryId,
    required this.medianRank,
    required this.sampleCount,
  });

  final String categoryId;
  final double medianRank;
  final int sampleCount;
}

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

class OrderingService {
  List<CategoryRankResult> computeCategoryRanks({
    required List<CheckOffEvent> events,
    required List<String> defaultCategoryOrder,
  }) {
    final trips = _groupByTrip(events);
    final categoryFirstRanks = <String, List<double>>{};

    for (final tripEvents in trips.values) {
      if (tripEvents.isEmpty) continue;

      final weight = tripEvents.first.weight;
      final seenCategories = <String>{};
      var rank = 0;

      for (final event in tripEvents) {
        if (seenCategories.contains(event.categoryId)) continue;
        seenCategories.add(event.categoryId);
        categoryFirstRanks
            .putIfAbsent(event.categoryId, () => [])
            .add(rank * weight);
        rank++;
      }
    }

    return categoryFirstRanks.entries.map((entry) {
      final median = _median(entry.value);
      return CategoryRankResult(
        categoryId: entry.key,
        medianRank: median,
        sampleCount: entry.value.length,
      );
    }).toList();
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

  double sortKeyForItem({
    required ListItem item,
    required Map<String, int> defaultCategoryOrder,
    required Map<String, CategoryRankStat> categoryStats,
    required Map<int, ItemRankStat> itemStats,
  }) {
    final defaultCatRank =
        defaultCategoryOrder[item.categoryId]?.toDouble() ?? 999.0;

    final catStat = categoryStats[item.categoryId];
    final categoryRank = (catStat != null &&
            catStat.sampleCount >= AppConstants.minSamplesForLearnedOrder)
        ? catStat.medianRank
        : defaultCatRank;

    double itemRank = 999.0;
    if (item.catalogItemId != null) {
      final itemStat = itemStats[item.catalogItemId!];
      if (itemStat != null &&
          itemStat.sampleCount >= AppConstants.minSamplesForLearnedOrder) {
        itemRank = itemStat.medianRank;
      }
    }

    final nameTie = item.displayName.toLowerCase().hashCode % 100 / 100.0;
    return categoryRank * 10000 + itemRank * 100 + nameTie;
  }

  Map<String, int> buildDefaultCategoryOrder(List<Category> categories) {
    final sorted = [...categories]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return {for (var i = 0; i < sorted.length; i++) sorted[i].id: i};
  }

  Map<String, List<ListItem>> groupActiveItems({
    required List<ListItem> items,
    required List<Category> categories,
    required List<CategoryRankStat> categoryRankStats,
    required List<ItemRankStat> itemRankStats,
  }) {
    final active = items.where((i) => !i.isCompleted).toList();
    final defaultOrder = buildDefaultCategoryOrder(categories);
    final catStatsMap = {for (final s in categoryRankStats) s.categoryId: s};
    final itemStatsMap = {
      for (final s in itemRankStats) s.catalogItemId: s,
    };
    final categoryNames = {for (final c in categories) c.id: c.name};

    active.sort((a, b) {
      final keyA = sortKeyForItem(
        item: a,
        defaultCategoryOrder: defaultOrder,
        categoryStats: catStatsMap,
        itemStats: itemStatsMap,
      );
      final keyB = sortKeyForItem(
        item: b,
        defaultCategoryOrder: defaultOrder,
        categoryStats: catStatsMap,
        itemStats: itemStatsMap,
      );
      return keyA.compareTo(keyB);
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
