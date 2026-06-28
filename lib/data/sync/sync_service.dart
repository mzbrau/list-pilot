import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../core/utils/device_id_service.dart';
import '../database/app_database.dart';
import 'entity_serializers/shopping_list_serializers.dart';
import 'sync_applier.dart';
import 'sync_auth_service.dart';
import 'sync_billing_service.dart';
import 'sync_engine.dart';
import 'sync_entity_type.dart';
import 'sync_id_mapper.dart';
import 'sync_listener_manager.dart';
import 'sync_outbox_helper.dart';
import 'sync_pull_service.dart';
import 'sync_push_service.dart';
import 'sync_space_service.dart';
import 'sync_storage_service.dart';

/// Facade wiring all sync components for dependency injection.
class SyncService {
  SyncService._({
    required AppDatabase db,
    required DeviceIdService deviceId,
    required this.auth,
    required this.billing,
    required this.spaceService,
    required this.idMapper,
    required this.applier,
    required this.pushService,
    required this.pullService,
    required this.listenerManager,
    required this.storage,
    required this.engine,
    required this.outbox,
  })  : _db = db,
        _deviceId = deviceId;

  factory SyncService({
    required AppDatabase db,
    required DeviceIdService deviceId,
    SyncAuthService? auth,
    FirebaseFirestore? firestore,
  }) {
    final resolvedAuth = auth ?? SyncAuthService();
    final resolvedFirestore = firestore ?? FirebaseFirestore.instance;
    final mapper = SyncIdMapper(db);
    final applier = SyncApplier(db, mapper);
    final push = SyncPushService(
      db: db,
      mapper: mapper,
      firestore: resolvedFirestore,
      shoppingListSerializer: ShoppingListSerializer(db, mapper),
      listItemSerializer: ListItemSerializer(db, mapper),
    );
    final pull = SyncPullService(
      db: db,
      firestore: resolvedFirestore,
      applier: applier,
    );
    final listener = SyncListenerManager(
      firestore: resolvedFirestore,
      applier: applier,
    );
    final billing = SyncBillingService(firestore: resolvedFirestore);
    final space = SyncSpaceService(
      firestore: resolvedFirestore,
      auth: resolvedAuth,
    );
    final engine = SyncEngine(
      db: db,
      auth: resolvedAuth,
      billing: billing,
      spaceService: space,
      pushService: push,
      pullService: pull,
      listenerManager: listener,
    );
    return SyncService._(
      db: db,
      deviceId: deviceId,
      auth: resolvedAuth,
      billing: billing,
      spaceService: space,
      idMapper: mapper,
      applier: applier,
      pushService: push,
      pullService: pull,
      listenerManager: listener,
      storage: SyncStorageService(),
      engine: engine,
      outbox: SyncOutboxHelper(db, engine),
    );
  }

  final AppDatabase _db;
  final DeviceIdService _deviceId;

  final SyncAuthService auth;
  final SyncBillingService billing;
  final SyncSpaceService spaceService;
  final SyncIdMapper idMapper;
  final SyncApplier applier;
  final SyncPushService pushService;
  final SyncPullService pullService;
  final SyncListenerManager listenerManager;
  final SyncStorageService storage;
  final SyncEngine engine;
  final SyncOutboxHelper outbox;

  Future<void> startIfEligible({required bool isPremium}) async {
    await engine.start(deviceId: _deviceId.deviceId, isPremium: isPremium);
  }

  Future<void> stop() => engine.stop();

  Future<void> setListSyncEnabled({
    required int listId,
    required bool enabled,
    String? syncSpaceId,
  }) async {
    final list = await _db.getListById(listId);
    if (list == null) return;

    final globalId = ensureGlobalId(list.globalId);
    final spaceId = syncSpaceId ??
        await spaceService.getActiveSpaceId() ??
        await spaceService.createOrGetPersonalSpace();

    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
        .write(
      ShoppingListsCompanion(
        globalId: Value(globalId),
        syncEnabled: Value(enabled),
        syncSpaceId: Value(enabled ? spaceId : null),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (enabled) {
      final updated = await _db.getListById(listId);
      if (updated != null) {
        await engine.initialMerge();
        await pushService.enqueueShoppingListSnapshot(updated);
        engine.schedulePush();
      }
    } else {
      await outbox.enqueueIfSynced(
        globalId: globalId,
        entityType: SyncEntityType.shoppingList,
        syncEnabled: true,
      );
      final now = DateTime.now();
      await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
          .write(
        ShoppingListsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      engine.schedulePush();
    }
  }

  Future<String> createInvite() async {
    final spaceId =
        await spaceService.getActiveSpaceId() ??
        await spaceService.createOrGetPersonalSpace();
    return spaceService.createInviteCode(spaceId);
  }

  Future<void> joinWithInvite(String code) async {
    await spaceService.joinSpaceByInviteCode(code);
    await engine.initialMerge();
  }
}
