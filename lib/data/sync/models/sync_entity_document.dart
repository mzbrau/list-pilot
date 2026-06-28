import 'package:cloud_firestore/cloud_firestore.dart';

import '../sync_entity_type.dart';

/// Remote entity document stored in syncSpaces/{spaceId}/entities/{globalId}.
class SyncEntityDocument {
  const SyncEntityDocument({
    required this.globalId,
    required this.type,
    required this.rootGlobalId,
    this.parentGlobalId,
    required this.modifiedAt,
    this.deletedAt,
    required this.modifiedBy,
    required this.modifiedByDevice,
    required this.payloadVersion,
    required this.payload,
  });

  final String globalId;
  final SyncEntityType type;
  final String rootGlobalId;
  final String? parentGlobalId;
  final DateTime modifiedAt;
  final DateTime? deletedAt;
  final String modifiedBy;
  final String modifiedByDevice;
  final int payloadVersion;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.wireValue,
      'rootGlobalId': rootGlobalId,
      if (parentGlobalId != null) 'parentGlobalId': parentGlobalId,
      'modifiedAt': Timestamp.fromDate(modifiedAt.toUtc()),
      'deletedAt':
          deletedAt != null ? Timestamp.fromDate(deletedAt!.toUtc()) : null,
      'modifiedBy': modifiedBy,
      'modifiedByDevice': modifiedByDevice,
      'payloadVersion': payloadVersion,
      'payload': payload,
    };
  }

  factory SyncEntityDocument.fromFirestore(
    String globalId,
    Map<String, dynamic> data,
  ) {
    final type = SyncEntityType.fromWire(data['type'] as String? ?? '');
    if (type == null) {
      throw FormatException('Unknown sync entity type: ${data['type']}');
    }
    return SyncEntityDocument(
      globalId: globalId,
      type: type,
      rootGlobalId: data['rootGlobalId'] as String? ?? globalId,
      parentGlobalId: data['parentGlobalId'] as String?,
      modifiedAt: _readTimestamp(data['modifiedAt']),
      deletedAt: data['deletedAt'] != null
          ? _readTimestamp(data['deletedAt'])
          : null,
      modifiedBy: data['modifiedBy'] as String? ?? '',
      modifiedByDevice: data['modifiedByDevice'] as String? ?? '',
      payloadVersion: data['payloadVersion'] as int? ?? 1,
      payload: Map<String, dynamic>.from(data['payload'] as Map? ?? {}),
    );
  }

  static DateTime _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is String) return DateTime.parse(value).toUtc();
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
