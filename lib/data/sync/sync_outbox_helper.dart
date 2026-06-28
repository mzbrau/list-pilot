import '../database/app_database.dart';
import 'sync_entity_type.dart';
import 'sync_engine.dart';

/// Helper for repositories to enqueue local changes for sync.
class SyncOutboxHelper {
  SyncOutboxHelper(this._db, this._engine);

  final AppDatabase _db;
  final SyncEngine? _engine;

  Future<void> enqueueIfSynced({
    required String? globalId,
    required SyncEntityType entityType,
    required bool syncEnabled,
    bool shoppingListItem = false,
  }) async {
    if (!syncEnabled || globalId == null || globalId.isEmpty) return;
    await _db.coalesceOutboxEntry(globalId);
    await _db.enqueueSyncOutbox(
      globalId: globalId,
      entityType: entityType.wireValue,
    );
    _engine?.schedulePush(shoppingListItem: shoppingListItem);
  }
}
