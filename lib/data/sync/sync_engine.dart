import 'dart:async';

import '../database/app_database.dart';
import 'firebase_initializer.dart';
import 'sync_auth_service.dart';
import 'sync_billing_service.dart';
import 'sync_listener_manager.dart';
import 'sync_pull_service.dart';
import 'sync_push_service.dart';
import 'sync_space_service.dart';

enum SyncEngineState { stopped, running, pausedNoPremium }

/// Coordinates push, pull, and scoped listeners while the app is open.
class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required SyncAuthService auth,
    required SyncBillingService billing,
    required SyncSpaceService spaceService,
    required SyncPushService pushService,
    required SyncPullService pullService,
    required SyncListenerManager listenerManager,
  })  : _db = db,
        _auth = auth,
        _billing = billing,
        _spaceService = spaceService,
        _pushService = pushService,
        _pullService = pullService,
        _listenerManager = listenerManager;

  final AppDatabase _db;
  final SyncAuthService _auth;
  final SyncBillingService _billing;
  final SyncSpaceService _spaceService;
  final SyncPushService _pushService;
  final SyncPullService _pullService;
  final SyncListenerManager _listenerManager;

  SyncEngineState _state = SyncEngineState.stopped;
  Timer? _pullTimer;
  Timer? _pushDebounce;
  String? _syncSpaceId;
  String? _deviceId;
  bool _premium = false;

  SyncEngineState get state => _state;

  Future<void> start({
    required String deviceId,
    required bool isPremium,
  }) async {
    await FirebaseInitializer.ensureInitialized();
    _deviceId = deviceId;
    _premium = isPremium;
    if (!_premium || !_auth.isSignedIn) {
      _state = SyncEngineState.pausedNoPremium;
      return;
    }

    _syncSpaceId =
        await _spaceService.getActiveSpaceId() ??
        await _spaceService.createOrGetPersonalSpace();
    await _db.setSyncMetadata(
      SyncSpaceService.activeSpaceKey,
      _syncSpaceId!,
    );

    _state = SyncEngineState.running;
    await _runCycle();
    _pullTimer?.cancel();
    _pullTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      _runCycle();
    });
  }

  Future<void> stop() async {
    _pullTimer?.cancel();
    _pullTimer = null;
    _pushDebounce?.cancel();
    _pushDebounce = null;
    await _listenerManager.stop();
    _state = SyncEngineState.stopped;
  }

  void setPremium(bool isPremium) {
    _premium = isPremium;
    if (!isPremium) {
      stop();
      _state = SyncEngineState.pausedNoPremium;
    }
  }

  Future<void> initialMerge() async {
    if (_syncSpaceId == null || !_premium) return;
    await _pullService.pullAll(_syncSpaceId!);
    await _flushPush(immediate: true);
  }

  void schedulePush({bool shoppingListItem = false}) {
    if (_state != SyncEngineState.running) return;
    _pushDebounce?.cancel();
    _pushDebounce = Timer(
      Duration(milliseconds: shoppingListItem ? 100 : 2000),
      () => _flushPush(),
    );
  }

  Future<void> _flushPush({bool immediate = false}) async {
    if (_state != SyncEngineState.running) return;
    final uid = _auth.currentUid;
    final spaceId = _syncSpaceId;
    final deviceId = _deviceId;
    if (uid == null || spaceId == null || deviceId == null) return;
    await _pushService.pushPending(
      syncSpaceId: spaceId,
      uid: uid,
      deviceId: deviceId,
    );
  }

  Future<void> _runCycle() async {
    if (_state != SyncEngineState.running) return;
    final spaceId = _syncSpaceId;
    if (spaceId == null) return;
    await _pullService.pullDelta(spaceId);
    await _flushPush(immediate: true);
  }

  Future<void> enableListRealtime(String listGlobalId) async {
    if (_state != SyncEngineState.running || _syncSpaceId == null) return;
    await _listenerManager.listenToShoppingList(
      syncSpaceId: _syncSpaceId!,
      listGlobalId: listGlobalId,
    );
  }

  Future<void> disableListRealtime() => _listenerManager.stop();

  Future<void> enableShoppingListSync(ShoppingList list) async {
    if (_syncSpaceId == null) {
      _syncSpaceId = await _spaceService.createOrGetPersonalSpace();
    }
    await _pushService.enqueueShoppingListSnapshot(list);
    schedulePush();
  }
}
