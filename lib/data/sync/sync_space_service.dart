import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/sync_id_generator.dart';
import 'sync_auth_service.dart';

class SyncSpaceService {
  SyncSpaceService({
    required FirebaseFirestore firestore,
    required SyncAuthService auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final SyncAuthService _auth;

  static const activeSpaceKey = 'active_sync_space_id';

  Future<String> createOrGetPersonalSpace() async {
    final uid = _auth.currentUid;
    if (uid == null) {
      throw StateError('Must be signed in to create a sync space');
    }

    final userSyncRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('private')
        .doc('sync');
    final userSync = await userSyncRef.get();
    final existing = userSync.data()?['activeSyncSpaceId'] as String?;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final spaceId = generateSyncId();
    final batch = _firestore.batch();
    final spaceRef = _firestore.collection('syncSpaces').doc(spaceId);
    batch.set(spaceRef.collection('meta').doc('info'), {
      'memberUids': [uid],
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': uid,
      'schemaVersion': 1,
    });
    batch.set(userSyncRef, {
      'activeSyncSpaceId': spaceId,
    }, SetOptions(merge: true));
    batch.set(
      _firestore.collection('users').doc(uid).collection('profile').doc('info'),
      {
        'email': _auth.currentUser?.email,
        'displayName': _auth.currentUser?.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
    return spaceId;
  }

  Future<String?> getActiveSpaceId() async {
    final uid = _auth.currentUid;
    if (uid == null) return null;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('private')
        .doc('sync')
        .get();
    return doc.data()?['activeSyncSpaceId'] as String?;
  }

  Future<void> joinSpaceByInviteCode(String inviteCode) async {
    final uid = _auth.currentUid;
    if (uid == null) {
      throw StateError('Must be signed in to join a sync space');
    }

    final inviteDoc = await _firestore
        .collection('invites')
        .doc(inviteCode.trim())
        .get();
    if (!inviteDoc.exists) {
      throw StateError('Invite code not found');
    }
    final data = inviteDoc.data()!;
    final spaceId = data['syncSpaceId'] as String?;
    final expiresAt = data['expiresAt'] as Timestamp?;
    if (spaceId == null) {
      throw StateError('Invalid invite');
    }
    if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
      throw StateError('Invite has expired');
    }

    final metaRef = _firestore
        .collection('syncSpaces')
        .doc(spaceId)
        .collection('meta')
        .doc('info');
    await metaRef.set({
      'memberUids': FieldValue.arrayUnion([uid]),
    }, SetOptions(merge: true));

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('private')
        .doc('sync')
        .set({'activeSyncSpaceId': spaceId}, SetOptions(merge: true));
  }

  Future<String> createInviteCode(String syncSpaceId, {Duration? ttl}) async {
    final uid = _auth.currentUid;
    if (uid == null) {
      throw StateError('Must be signed in to create invites');
    }
    final code = generateSyncId().split('-').first;
    await _firestore.collection('invites').doc(code).set({
      'syncSpaceId': syncSpaceId,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(ttl ?? const Duration(days: 7)),
      ),
    });
    return code;
  }

  Future<List<String>> getMemberUids(String syncSpaceId) async {
    final doc = await _firestore
        .collection('syncSpaces')
        .doc(syncSpaceId)
        .collection('meta')
        .doc('info')
        .get();
    final members = doc.data()?['memberUids'];
    if (members is List) {
      return members.cast<String>();
    }
    return const [];
  }
}
