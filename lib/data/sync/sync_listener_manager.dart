import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/sync_entity_document.dart';
import 'sync_applier.dart';
import 'sync_entity_type.dart';

typedef SyncListenerCallback = void Function(int appliedCount);

/// Manages scoped Firestore snapshot listeners for near-real-time shopping.
class SyncListenerManager {
  SyncListenerManager({
    required FirebaseFirestore firestore,
    required SyncApplier applier,
  })  : _firestore = firestore,
        _applier = applier;

  final FirebaseFirestore _firestore;
  final SyncApplier _applier;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? _activeListGlobalId;

  String? get activeListGlobalId => _activeListGlobalId;

  Future<void> listenToShoppingList({
    required String syncSpaceId,
    required String listGlobalId,
    SyncListenerCallback? onApplied,
  }) async {
    if (_activeListGlobalId == listGlobalId) return;
    await stop();

    _activeListGlobalId = listGlobalId;
    final query = _firestore
        .collection('syncSpaces')
        .doc(syncSpaceId)
        .collection('entities')
        .where('rootGlobalId', isEqualTo: listGlobalId)
        .where(
          'type',
          whereIn: [
            SyncEntityType.shoppingList.wireValue,
            SyncEntityType.listItem.wireValue,
          ],
        );

    _subscription = query.snapshots().listen((snapshot) async {
      var applied = 0;
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) continue;
        try {
          final entity = SyncEntityDocument.fromFirestore(
            change.doc.id,
            change.doc.data() ?? {},
          );
          if (await _applier.apply(entity)) {
            applied++;
          }
        } catch (_) {
          // Ignore malformed listener payloads.
        }
      }
      await _applier.applyPendingOrphans();
      if (applied > 0) {
        onApplied?.call(applied);
      }
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _activeListGlobalId = null;
  }
}
