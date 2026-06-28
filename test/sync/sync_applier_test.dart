import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/sync/models/sync_entity_document.dart';
import 'package:list_pilot/data/sync/sync_applier.dart';
import 'package:list_pilot/data/sync/sync_entity_type.dart';
import 'package:list_pilot/data/sync/sync_id_mapper.dart';

void main() {
  late AppDatabase db;
  late SyncApplier applier;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    applier = SyncApplier(db, SyncIdMapper(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('LWW inserts unknown shopping list', () async {
    final applied = await applier.apply(
      SyncEntityDocument(
        globalId: 'list-1',
        type: SyncEntityType.shoppingList,
        rootGlobalId: 'list-1',
        modifiedAt: DateTime.utc(2026, 6, 24, 12),
        modifiedBy: 'user-a',
        modifiedByDevice: 'device-a',
        payloadVersion: 1,
        payload: {'name': 'Groceries'},
      ),
    );

    expect(applied, isTrue);
    final list = await db.getListByGlobalId('list-1');
    expect(list?.name, 'Groceries');
    expect(list?.syncEnabled, isTrue);
  });

  test('LWW keeps newer local row when remote is older', () async {
    final now = DateTime.now();
    final listId = await db.into(db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            globalId: const Value('list-1'),
            name: 'Local name',
            createdAt: now,
            updatedAt: now.add(const Duration(hours: 1)),
            syncEnabled: const Value(true),
          ),
        );

    final applied = await applier.apply(
      SyncEntityDocument(
        globalId: 'list-1',
        type: SyncEntityType.shoppingList,
        rootGlobalId: 'list-1',
        modifiedAt: now.toUtc(),
        modifiedBy: 'user-b',
        modifiedByDevice: 'device-b',
        payloadVersion: 1,
        payload: {'name': 'Remote name'},
      ),
    );

    expect(applied, isFalse);
    final list = await db.getListById(listId);
    expect(list?.name, 'Local name');
  });

  test('orphan list item is queued until parent arrives', () async {
    await applier.apply(
      SyncEntityDocument(
        globalId: 'item-1',
        type: SyncEntityType.listItem,
        rootGlobalId: 'list-1',
        parentGlobalId: 'list-1',
        modifiedAt: DateTime.utc(2026, 6, 24, 12),
        modifiedBy: 'user-a',
        modifiedByDevice: 'device-a',
        payloadVersion: 1,
        payload: {'displayName': 'Milk', 'categoryId': 'dairy'},
      ),
    );

    expect(await db.getListItemByGlobalId('item-1'), isNull);
    expect((await db.getPendingOrphans()).length, 1);

    await applier.apply(
      SyncEntityDocument(
        globalId: 'list-1',
        type: SyncEntityType.shoppingList,
        rootGlobalId: 'list-1',
        modifiedAt: DateTime.utc(2026, 6, 24, 11),
        modifiedBy: 'user-a',
        modifiedByDevice: 'device-a',
        payloadVersion: 1,
        payload: {'name': 'Groceries'},
      ),
    );
    await applier.applyPendingOrphans();

    final item = await db.getListItemByGlobalId('item-1');
    expect(item?.displayName, 'Milk');
    expect((await db.getPendingOrphans()).length, 0);
  });
}
