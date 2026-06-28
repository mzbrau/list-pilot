import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates stable UUID v4 identifiers for syncable entities.
String generateSyncId() => _uuid.v4();
