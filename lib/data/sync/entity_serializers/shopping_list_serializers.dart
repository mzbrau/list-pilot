import 'dart:convert';

import '../../../core/utils/sync_id_generator.dart';
import '../../database/app_database.dart';
import '../models/sync_entity_document.dart';
import '../sync_entity_type.dart';
import '../sync_id_mapper.dart';

abstract class EntitySerializer {
  SyncEntityType get entityType;
  Future<SyncEntityDocument?> serialize({
    required String globalId,
    required String uid,
    required String deviceId,
    required String syncSpaceId,
  });
}

class ShoppingListSerializer implements EntitySerializer {
  ShoppingListSerializer(this._db, this._mapper);

  final AppDatabase _db;
  final SyncIdMapper _mapper;

  @override
  SyncEntityType get entityType => SyncEntityType.shoppingList;

  @override
  Future<SyncEntityDocument?> serialize({
    required String globalId,
    required String uid,
    required String deviceId,
    required String syncSpaceId,
  }) async {
    final list = await _db.getListByGlobalId(globalId);
    if (list == null || !list.syncEnabled) return null;
    final modifiedAt = list.deletedAt ?? list.updatedAt;
    return SyncEntityDocument(
      globalId: globalId,
      type: SyncEntityType.shoppingList,
      rootGlobalId: globalId,
      modifiedAt: modifiedAt,
      deletedAt: list.deletedAt,
      modifiedBy: uid,
      modifiedByDevice: deviceId,
      payloadVersion: 1,
      payload: {
        'name': list.name,
        'createdAt': list.createdAt.toUtc().toIso8601String(),
        'lastCheckOffAt': list.lastCheckOffAt?.toUtc().toIso8601String(),
        'currentTripId': list.currentTripId,
        'currentTripSequence': list.currentTripSequence,
        'activeShopStartedAt':
            list.activeShopStartedAt?.toUtc().toIso8601String(),
        'syncEnabled': list.syncEnabled,
      },
    );
  }
}

class ListItemSerializer implements EntitySerializer {
  ListItemSerializer(this._db, this._mapper);

  final AppDatabase _db;
  final SyncIdMapper _mapper;

  @override
  SyncEntityType get entityType => SyncEntityType.listItem;

  @override
  Future<SyncEntityDocument?> serialize({
    required String globalId,
    required String uid,
    required String deviceId,
    required String syncSpaceId,
  }) async {
    final item = await _db.getListItemByGlobalId(globalId);
    if (item == null || item.globalId == null) return null;
    final list = await _db.getListById(item.listId);
    if (list == null || !list.syncEnabled || list.globalId == null) {
      return null;
    }

    String? catalogItemGlobalId;
    if (item.catalogItemId != null) {
      final catalog = await _db.getCatalogItemById(item.catalogItemId!);
      if (catalog != null && catalog.isUserAdded && catalog.globalId != null) {
        catalogItemGlobalId = catalog.globalId;
      }
    }

    final modifiedAt = item.deletedAt ??
        item.updatedAt ??
        item.completedAt ??
        item.addedAt;

    return SyncEntityDocument(
      globalId: globalId,
      type: SyncEntityType.listItem,
      rootGlobalId: list.globalId!,
      parentGlobalId: list.globalId,
      modifiedAt: modifiedAt,
      deletedAt: item.deletedAt,
      modifiedBy: uid,
      modifiedByDevice: deviceId,
      payloadVersion: 1,
      payload: {
        'displayName': item.displayName,
        'categoryId': item.categoryId,
        if (catalogItemGlobalId != null)
          'catalogItemGlobalId': catalogItemGlobalId,
        'quantityValue': item.quantityValue,
        'quantityUnit': item.quantityUnit,
        'isCompleted': item.isCompleted,
        'completedAt': item.completedAt?.toUtc().toIso8601String(),
        'addedAt': item.addedAt.toUtc().toIso8601String(),
      },
    );
  }
}

String encodeOrphanDocument(SyncEntityDocument doc) {
  final map = doc.toFirestore();
  map['modifiedAt'] = doc.modifiedAt.toUtc().toIso8601String();
  if (doc.deletedAt != null) {
    map['deletedAt'] = doc.deletedAt!.toUtc().toIso8601String();
  }
  return jsonEncode({'globalId': doc.globalId, ...map});
}

SyncEntityDocument decodeOrphanDocument(String json) {
  final map = jsonDecode(json) as Map<String, dynamic>;
  final globalId = map.remove('globalId') as String;
  return SyncEntityDocument.fromFirestore(globalId, map);
}

String ensureGlobalId(String? existing) =>
    (existing == null || existing.isEmpty) ? generateSyncId() : existing;
