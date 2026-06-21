import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/overview_order_repository.dart';

void main() {
  group('OverviewOrderRepository', () {
    late AppDatabase db;
    late OverviewOrderRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = OverviewOrderRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('moveItemToPosition reorders keys and persists sequential sort orders',
        () async {
      const keys = ['meal_manager', 'shopping:1', 'todo:2', 'meal_planning'];

      await repo.moveItemToPosition(
        itemKey: 'meal_planning',
        orderedKeys: keys,
        newIndex: 0,
      );

      final orderMap = await repo.watchOrderMap().first;
      expect(orderMap['meal_planning'], 0);
      expect(orderMap['meal_manager'], 1);
      expect(orderMap['shopping:1'], 2);
      expect(orderMap['todo:2'], 3);
    });

    test('moveItemToPosition adjusts index when moving down', () async {
      const keys = ['a', 'b', 'c'];

      await repo.moveItemToPosition(
        itemKey: 'a',
        orderedKeys: keys,
        newIndex: 3,
      );

      final orderMap = await repo.watchOrderMap().first;
      expect(orderMap.keys.toList(), ['b', 'c', 'a']);
      expect(orderMap['b'], 0);
      expect(orderMap['c'], 1);
      expect(orderMap['a'], 2);
    });

    test('watchOrderMap emits updated order after reorder', () async {
      final emissions = <Map<String, int>>[];
      final subscription = repo.watchOrderMap().listen(emissions.add);

      await repo.moveItemToPosition(
        itemKey: 'todo:1',
        orderedKeys: const ['shopping:1', 'todo:1'],
        newIndex: 0,
      );

      await Future<void>.delayed(Duration.zero);

      expect(emissions.last['todo:1'], 0);
      expect(emissions.last['shopping:1'], 1);

      await subscription.cancel();
    });
  });
}
