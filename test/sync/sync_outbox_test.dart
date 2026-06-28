import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/sync/sync_entity_type.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  test('outbox coalesces duplicate global IDs', () async {
    await db.enqueueSyncOutbox(
      globalId: 'a',
      entityType: SyncEntityType.listItem.wireValue,
    );
    await db.enqueueSyncOutbox(
      globalId: 'a',
      entityType: SyncEntityType.listItem.wireValue,
    );

    expect((await db.getPendingOutbox()).length, 2);
    await db.coalesceOutboxEntry('a');
    expect((await db.getPendingOutbox()).length, 1);
  });

  test('sync metadata round-trips', () async {
    await db.setSyncMetadata('pull_watermark', '2026-06-24T00:00:00.000Z');
    final value = await db.getSyncMetadata('pull_watermark');
    expect(value, '2026-06-24T00:00:00.000Z');
  });
}
