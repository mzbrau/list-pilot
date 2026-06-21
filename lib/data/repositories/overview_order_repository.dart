import '../database/app_database.dart';

class OverviewOrderRepository {
  OverviewOrderRepository(this._db);

  final AppDatabase _db;

  Stream<Map<String, int>> watchOrderMap() {
    return _db.watchOverviewOrderEntries().map(
          (entries) => {
            for (final entry in entries) entry.itemKey: entry.sortOrder,
          },
        );
  }

  Future<void> moveItemToPosition({
    required String itemKey,
    required List<String> orderedKeys,
    required int newIndex,
  }) async {
    final ordered = orderedKeys.where((key) => key != itemKey).toList();
    final index = newIndex.clamp(0, ordered.length);
    ordered.insert(index, itemKey);

    await _db.transaction(() async {
      await _db.delete(_db.overviewOrderEntries).go();
      for (var i = 0; i < ordered.length; i++) {
        await _db.into(_db.overviewOrderEntries).insert(
              OverviewOrderEntriesCompanion.insert(
                itemKey: ordered[i],
                sortOrder: i,
              ),
            );
      }
    });
  }
}
