import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/app_database.dart';
import 'models/sync_entity_document.dart';
import 'sync_applier.dart';

class SyncPullService {
  SyncPullService({
    required AppDatabase db,
    required FirebaseFirestore firestore,
    required SyncApplier applier,
  })  : _db = db,
        _firestore = firestore,
        _applier = applier;

  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final SyncApplier _applier;

  static const watermarkKey = 'pull_watermark';

  Future<int> pullDelta(String syncSpaceId) async {
    final watermarkRaw = await _db.getSyncMetadata(watermarkKey);
    final watermark = watermarkRaw != null
        ? DateTime.parse(watermarkRaw).toUtc()
        : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    final query = _firestore
        .collection('syncSpaces')
        .doc(syncSpaceId)
        .collection('entities')
        .where('modifiedAt', isGreaterThan: Timestamp.fromDate(watermark))
        .orderBy('modifiedAt')
        .limit(500);

    final snapshot = await query.get();
    var applied = 0;
    DateTime? maxModified;

    for (final doc in snapshot.docs) {
      try {
        final entity = SyncEntityDocument.fromFirestore(doc.id, doc.data());
        if (await _applier.apply(entity)) {
          applied++;
        }
        if (maxModified == null || entity.modifiedAt.isAfter(maxModified)) {
          maxModified = entity.modifiedAt;
        }
      } catch (_) {
        // Skip malformed remote documents.
      }
    }

    await _applier.applyPendingOrphans();

    if (maxModified != null) {
      await _db.setSyncMetadata(
        watermarkKey,
        maxModified.toUtc().toIso8601String(),
      );
    }

    return applied;
  }

  Future<int> pullAll(String syncSpaceId) async {
    await _db.setSyncMetadata(
      watermarkKey,
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toIso8601String(),
    );
    return pullDelta(syncSpaceId);
  }
}
