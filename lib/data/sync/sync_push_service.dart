import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'entity_serializers/shopping_list_serializers.dart';
import 'sync_entity_type.dart';
import 'sync_id_mapper.dart';

class SyncPushService {
  SyncPushService({
    required AppDatabase db,
    required SyncIdMapper mapper,
    required FirebaseFirestore firestore,
    required ShoppingListSerializer shoppingListSerializer,
    required ListItemSerializer listItemSerializer,
  })  : _db = db,
        _mapper = mapper,
        _firestore = firestore,
        _serializers = {
          SyncEntityType.shoppingList: shoppingListSerializer,
          SyncEntityType.listItem: listItemSerializer,
        };

  final AppDatabase _db;
  final SyncIdMapper _mapper;
  final FirebaseFirestore _firestore;
  final Map<SyncEntityType, EntitySerializer> _serializers;

  Future<int> pushPending({
    required String syncSpaceId,
    required String uid,
    required String deviceId,
  }) async {
    final pending = await _db.getPendingOutbox();
    if (pending.isEmpty) return 0;

    final batch = _firestore.batch();
    final completedIds = <int>[];
    var writes = 0;

    for (final entry in pending) {
      final type = SyncEntityType.fromWire(entry.entityType);
      if (type == null) {
        completedIds.add(entry.id);
        continue;
      }
      final serializer = _serializers[type];
      if (serializer == null) {
        completedIds.add(entry.id);
        continue;
      }

      final doc = await serializer.serialize(
        globalId: entry.globalId,
        uid: uid,
        deviceId: deviceId,
        syncSpaceId: syncSpaceId,
      );
      if (doc == null) {
        completedIds.add(entry.id);
        continue;
      }

      final ref = _firestore
          .collection('syncSpaces')
          .doc(syncSpaceId)
          .collection('entities')
          .doc(entry.globalId);
      batch.set(ref, doc.toFirestore(), SetOptions(merge: true));
      completedIds.add(entry.id);
      writes++;
      if (writes >= 400) break;
    }

    if (writes > 0) {
      await batch.commit();
    }
    await _db.removeOutboxEntries(completedIds);
    return writes;
  }

  Future<void> enqueueShoppingListSnapshot(ShoppingList list) async {
    final globalId = ensureGlobalId(list.globalId);
    if (list.globalId == null) {
      await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(list.id)))
          .write(ShoppingListsCompanion(globalId: Value(globalId)));
    }
    await _db.enqueueSyncOutbox(
      globalId: globalId,
      entityType: SyncEntityType.shoppingList.wireValue,
    );

    final items = await _db.getListItemsForList(list.id);
    for (final item in items) {
      final itemGlobalId = ensureGlobalId(item.globalId);
      if (item.globalId == null) {
        await (_db.update(_db.listItems)..where((t) => t.id.equals(item.id)))
            .write(ListItemsCompanion(globalId: Value(itemGlobalId)));
      }
      await _db.enqueueSyncOutbox(
        globalId: itemGlobalId,
        entityType: SyncEntityType.listItem.wireValue,
      );
    }
  }
}
