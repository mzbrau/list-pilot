import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/shop_stats_repository.dart';

void main() {
  late AppDatabase db;
  late ShopStatsRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ShopStatsRepository(db);

    await db.into(db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            name: 'Test Store',
            createdAt: DateTime(2025, 1, 1),
            updatedAt: DateTime(2025, 1, 1),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('starts session on first check-off', () async {
    final result = await repo.onItemCheckedOff(
      listId: 1,
      remainingAfter: 2,
      totalItems: 3,
      checkedAt: DateTime(2025, 1, 1, 10, 0, 30),
    );

    expect(result, isNull);

    final list = await db.getListById(1);
    expect(list?.activeShopStartedAt, DateTime(2025, 1, 1, 10, 0, 30));
  });

  test('completes shop on last check-off and saves record', () async {
    await repo.onItemCheckedOff(
      listId: 1,
      remainingAfter: 2,
      totalItems: 3,
      checkedAt: DateTime(2025, 1, 1, 10, 0),
    );

    final result = await repo.onItemCheckedOff(
      listId: 1,
      remainingAfter: 1,
      totalItems: 3,
      checkedAt: DateTime(2025, 1, 1, 10, 5),
    );
    expect(result, isNull);

    final completion = await repo.onItemCheckedOff(
      listId: 1,
      remainingAfter: 0,
      totalItems: 3,
      checkedAt: DateTime(2025, 1, 1, 10, 10),
    );

    expect(completion, isNotNull);
    expect(completion!.itemCount, 3);
    expect(completion.duration, const Duration(minutes: 10));
    expect(completion.msPerItem.inMilliseconds, 200000);

    final list = await db.getListById(1);
    expect(list?.activeShopStartedAt, isNull);

    final records = await repo.getRecordsForList(1);
    expect(records, hasLength(1));
    expect(records.first.itemCount, 3);
  });

  test('abandonSession clears active shop without saving', () async {
    await repo.onItemCheckedOff(
      listId: 1,
      remainingAfter: 1,
      totalItems: 2,
      checkedAt: DateTime(2025, 1, 1, 10, 0),
    );

    await repo.abandonSession(1);

    final list = await db.getListById(1);
    expect(list?.activeShopStartedAt, isNull);

    final records = await repo.getRecordsForList(1);
    expect(records, isEmpty);
  });

  test('comparison marks first shop as personal best', () async {
    final result = await repo.onItemCheckedOff(
      listId: 1,
      remainingAfter: 0,
      totalItems: 1,
      checkedAt: DateTime(2025, 1, 1, 10, 1),
    );

    expect(result!.comparison.isPersonalBest, isTrue);
    expect(result.comparison.shopNumber, 1);
    expect(result.comparison.rank, 1);
    expect(result.comparison.previousDeltaMs, isNull);
  });

  test('getLongTermAverageMsPerItem requires at least two shops', () async {
    await repo.onItemCheckedOff(
      listId: 1,
      remainingAfter: 1,
      totalItems: 2,
      checkedAt: DateTime(2025, 1, 1, 10, 0),
    );
    await repo.onItemCheckedOff(
      listId: 1,
      remainingAfter: 0,
      totalItems: 2,
      checkedAt: DateTime(2025, 1, 1, 10, 2),
    );

    expect(await repo.getLongTermAverageMsPerItem(1), isNull);

    await repo.onItemCheckedOff(
      listId: 1,
      remainingAfter: 1,
      totalItems: 2,
      checkedAt: DateTime(2025, 1, 1, 11, 0),
    );
    await repo.onItemCheckedOff(
      listId: 1,
      remainingAfter: 0,
      totalItems: 2,
      checkedAt: DateTime(2025, 1, 1, 11, 4),
    );

    final average = await repo.getLongTermAverageMsPerItem(1);
    expect(average, isNotNull);
    expect(average, 90000);
  });
}
