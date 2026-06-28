import 'package:drift/drift.dart';

import '../../core/utils/sync_id_generator.dart';
import '../database/app_database.dart';
import 'models/sync_entity_document.dart';
import 'sync_entity_type.dart';
import 'entity_serializers/shopping_list_serializers.dart';
import 'sync_id_mapper.dart';

/// Applies remote Firestore entity documents to SQLite using LWW.
class SyncApplier {
  SyncApplier(this._db, this._mapper);

  final AppDatabase _db;
  final SyncIdMapper _mapper;

  Future<bool> apply(SyncEntityDocument doc) async {
    switch (doc.type) {
      case SyncEntityType.shoppingList:
        return _applyShoppingList(doc);
      case SyncEntityType.listItem:
        return _applyListItem(doc);
      default:
        return false;
    }
  }

  Future<void> applyPendingOrphans() async {
    final orphans = await _db.getPendingOrphans();
    for (final orphan in orphans) {
      try {
        final doc = decodeOrphanDocument(orphan.entityJson);
        final applied = await apply(doc);
        if (applied) {
          await _db.removePendingOrphan(orphan.id);
        }
      } catch (_) {
        // Keep orphan for a later pass.
      }
    }
  }

  Future<bool> _applyShoppingList(SyncEntityDocument doc) async {
    final existing = await _db.getListByGlobalId(doc.globalId);
    if (existing != null && !_isRemoteNewer(doc, existing.updatedAt, existing.deletedAt)) {
      return false;
    }

    final payload = doc.payload;
    if (existing == null) {
      final now = doc.modifiedAt.toLocal();
      final id = await _db.into(_db.shoppingLists).insert(
            ShoppingListsCompanion.insert(
              globalId: Value(doc.globalId),
              name: payload['name'] as String? ?? 'Shopping list',
              createdAt: _parseDate(payload['createdAt']) ?? now,
              updatedAt: doc.modifiedAt.toLocal(),
              deletedAt: Value(doc.deletedAt?.toLocal()),
              syncEnabled: const Value(true),
              syncSpaceId: const Value.absent(),
              lastCheckOffAt: Value(_parseDate(payload['lastCheckOffAt'])),
              currentTripId: Value(payload['currentTripId'] as int? ?? 0),
              currentTripSequence:
                  Value(payload['currentTripSequence'] as int? ?? 0),
              activeShopStartedAt:
                  Value(_parseDate(payload['activeShopStartedAt'])),
            ),
          );
      _mapper.rememberShoppingList(doc.globalId, id);
      return true;
    }

    await (_db.update(_db.shoppingLists)
          ..where((t) => t.id.equals(existing.id)))
        .write(
      ShoppingListsCompanion(
        name: Value(payload['name'] as String? ?? existing.name),
        updatedAt: Value(doc.modifiedAt.toLocal()),
        deletedAt: Value(doc.deletedAt?.toLocal()),
        lastCheckOffAt: Value(_parseDate(payload['lastCheckOffAt'])),
        currentTripId: Value(payload['currentTripId'] as int? ?? existing.currentTripId),
        currentTripSequence: Value(
          payload['currentTripSequence'] as int? ?? existing.currentTripSequence,
        ),
        activeShopStartedAt:
            Value(_parseDate(payload['activeShopStartedAt'])),
        syncEnabled: const Value(true),
      ),
    );
    return true;
  }

  Future<bool> _applyListItem(SyncEntityDocument doc) async {
    final listGlobalId = doc.rootGlobalId;
    final listId = await _mapper.localShoppingListId(listGlobalId);
    if (listId == null) {
      await _db.addPendingOrphan(encodeOrphanDocument(doc));
      return false;
    }

    final existing = await _db.getListItemByGlobalId(doc.globalId);
    if (existing != null) {
      final localModified = existing.deletedAt ??
          existing.updatedAt ??
          existing.completedAt ??
          existing.addedAt;
      if (!_isRemoteNewer(doc, localModified, existing.deletedAt)) {
        return false;
      }
    }

    final payload = doc.payload;
    int? catalogItemId;
    final catalogGlobalId = payload['catalogItemGlobalId'] as String?;
    if (catalogGlobalId != null) {
      final catalog = await _db.customSelect(
        'SELECT id FROM catalog_items WHERE global_id = ?',
        variables: [Variable<String>(catalogGlobalId)],
        readsFrom: {_db.catalogItems},
      ).getSingleOrNull();
      catalogItemId = catalog?.read<int>('id');
    }

    if (existing == null) {
      final id = await _db.into(_db.listItems).insert(
            ListItemsCompanion.insert(
              globalId: Value(doc.globalId),
              listId: listId,
              catalogItemId: Value(catalogItemId),
              displayName: payload['displayName'] as String? ?? 'Item',
              categoryId: payload['categoryId'] as String? ?? 'other',
              quantityValue: Value(payload['quantityValue'] as double?),
              quantityUnit: Value(payload['quantityUnit'] as String?),
              isCompleted: Value(payload['isCompleted'] as bool? ?? false),
              completedAt: Value(_parseDate(payload['completedAt'])),
              addedAt: _parseDate(payload['addedAt']) ?? doc.modifiedAt.toLocal(),
              updatedAt: Value(doc.modifiedAt.toLocal()),
              deletedAt: Value(doc.deletedAt?.toLocal()),
            ),
          );
      _mapper.rememberListItem(doc.globalId, id);
      return true;
    }

    await (_db.update(_db.listItems)..where((t) => t.id.equals(existing.id)))
        .write(
      ListItemsCompanion(
        displayName: Value(payload['displayName'] as String? ?? existing.displayName),
        categoryId: Value(payload['categoryId'] as String? ?? existing.categoryId),
        catalogItemId: Value(catalogItemId),
        quantityValue: Value(payload['quantityValue'] as double?),
        quantityUnit: Value(payload['quantityUnit'] as String?),
        isCompleted: Value(payload['isCompleted'] as bool? ?? existing.isCompleted),
        completedAt: Value(_parseDate(payload['completedAt'])),
        updatedAt: Value(doc.modifiedAt.toLocal()),
        deletedAt: Value(doc.deletedAt?.toLocal()),
      ),
    );
    return true;
  }

  bool _isRemoteNewer(
    SyncEntityDocument remote,
    DateTime localModified,
    DateTime? localDeletedAt,
  ) {
    final remoteModified = remote.deletedAt ?? remote.modifiedAt;
    final localEffective = localDeletedAt ?? localModified;
    if (remoteModified.isAfter(localEffective.toUtc())) return true;
    if (remoteModified.isBefore(localEffective.toUtc())) return false;
    return remote.modifiedByDevice.compareTo('') >= 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value).toLocal();
    }
    return null;
  }
}
