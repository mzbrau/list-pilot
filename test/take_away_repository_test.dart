import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/take_away_repository.dart';

void main() {
  late AppDatabase db;
  late TakeAwayRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TakeAwayRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('createList and createMenuFromImport', () async {
    final listId = await repo.createList('Local takeaways');
    final menuId = await repo.createMenuFromImport(
      listId: listId,
      restaurantName: 'Pizza Place',
      location: 'Main St',
      items: const [
        TakeAwayMenuItemDraft(
          itemNumber: '1',
          name: 'Margherita',
          priceDisplay: '99 kr',
          priceAmount: 99,
        ),
      ],
    );

    final menu = await repo.getMenuById(menuId);
    expect(menu?.restaurantName, 'Pizza Place');
    expect(menu?.isFinalized, isTrue);

    final items = await repo.watchMenuItems(menuId).first;
    expect(items, hasLength(1));
    expect(items.first.name, 'Margherita');
  });

  test('addOrIncrementLine increments quantity', () async {
    final listId = await repo.createList('Orders');
    final menuId = await repo.createMenuFromImport(
      listId: listId,
      restaurantName: 'Cafe',
      items: const [
        TakeAwayMenuItemDraft(
          name: 'Coffee',
          priceDisplay: '35 kr',
          priceAmount: 35,
        ),
      ],
    );
    final itemId = (await repo.watchMenuItems(menuId).first).first.id;

    await repo.addOrIncrementLine(menuId, itemId);
    await repo.addOrIncrementLine(menuId, itemId);

    final order = await repo.watchOrderWithLines(menuId).first;
    expect(order?.lines, hasLength(1));
    expect(order?.lines.first.line.quantity, 2);
  });

  test('setLineQuantity zero removes line', () async {
    final listId = await repo.createList('Orders');
    final menuId = await repo.createMenuFromImport(
      listId: listId,
      restaurantName: 'Cafe',
      items: const [
        TakeAwayMenuItemDraft(
          name: 'Tea',
          priceDisplay: '30 kr',
          priceAmount: 30,
        ),
      ],
    );
    final itemId = (await repo.watchMenuItems(menuId).first).first.id;

    await repo.addOrIncrementLine(menuId, itemId);
    await repo.setLineQuantity(menuId, itemId, 0);

    final order = await repo.watchOrderWithLines(menuId).first;
    expect(order?.lines, isEmpty);
  });

  test('clearOrder removes all lines but keeps order row', () async {
    final listId = await repo.createList('Orders');
    final menuId = await repo.createMenuFromImport(
      listId: listId,
      restaurantName: 'Diner',
      items: const [
        TakeAwayMenuItemDraft(name: 'Burger', priceDisplay: '80 kr', priceAmount: 80),
        TakeAwayMenuItemDraft(name: 'Fries', priceDisplay: '30 kr', priceAmount: 30),
      ],
    );
    final items = await repo.watchMenuItems(menuId).first;

    await repo.addOrIncrementLine(menuId, items[0].id);
    await repo.addOrIncrementLine(menuId, items[1].id);
    await repo.clearOrder(menuId);

    final order = await repo.watchOrderWithLines(menuId).first;
    expect(order?.lines, isEmpty);
    expect(order?.order.menuId, menuId);
  });

  test('order updatedAt changes when lines change', () async {
    final listId = await repo.createList('Orders');
    final menuId = await repo.createMenuFromImport(
      listId: listId,
      restaurantName: 'Sushi',
      items: const [
        TakeAwayMenuItemDraft(name: 'Roll', priceDisplay: '50 kr', priceAmount: 50),
      ],
    );
    final itemId = (await repo.watchMenuItems(menuId).first).first.id;

    await repo.addOrIncrementLine(menuId, itemId);
    final firstUpdated =
        (await repo.watchOrderWithLines(menuId).first)!.order.updatedAt;

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.addOrIncrementLine(menuId, itemId);
    final secondUpdated =
        (await repo.watchOrderWithLines(menuId).first)!.order.updatedAt;

    expect(
      secondUpdated.millisecondsSinceEpoch,
      greaterThanOrEqualTo(firstUpdated.millisecondsSinceEpoch),
    );
  });

  test('deleteList cascades menus and orders', () async {
    final listId = await repo.createList('Temp');
    final menuId = await repo.createMenuFromImport(
      listId: listId,
      restaurantName: 'Gone',
      items: const [
        TakeAwayMenuItemDraft(name: 'Soup', priceDisplay: '40 kr'),
      ],
    );
    final itemId = (await repo.watchMenuItems(menuId).first).first.id;
    await repo.addOrIncrementLine(menuId, itemId);

    await repo.deleteList(listId);

    expect(await repo.getListById(listId), isNull);
    expect(await repo.getMenuById(menuId), isNull);
  });

  test('setMenuEditing and finalizeMenu toggle isFinalized', () async {
    final listId = await repo.createList('Edit');
    final menuId = await repo.createMenuFromImport(
      listId: listId,
      restaurantName: 'Editable',
      items: const [
        TakeAwayMenuItemDraft(name: 'Salad', priceDisplay: '60 kr'),
      ],
    );

    expect((await repo.getMenuById(menuId))?.isFinalized, isTrue);

    await repo.setMenuEditing(menuId);
    expect((await repo.getMenuById(menuId))?.isFinalized, isFalse);

    await repo.finalizeMenu(menuId);
    expect((await repo.getMenuById(menuId))?.isFinalized, isTrue);
  });

  test('updateListBackgroundColor sets and clears color', () async {
    final listId = await repo.createList('Colored list');
    const colorValue = 0xFFBBDEFB;

    await repo.updateListBackgroundColor(listId, colorValue);
    expect((await repo.getListById(listId))?.backgroundColor, colorValue);

    await repo.updateListBackgroundColor(listId, null);
    expect((await repo.getListById(listId))?.backgroundColor, isNull);
  });
}
