import 'package:drift/drift.dart';

import '../database/app_database.dart';

class TakeAwayMenuItemDraft {
  const TakeAwayMenuItemDraft({
    this.itemNumber,
    required this.name,
    required this.priceDisplay,
    this.priceAmount,
  });

  final String? itemNumber;
  final String name;
  final String priceDisplay;
  final double? priceAmount;
}

class TakeAwayRepository {
  TakeAwayRepository(this._db);

  final AppDatabase _db;

  Stream<List<TakeAwayList>> watchAllLists() => _db.watchAllTakeAwayLists();

  Future<TakeAwayList?> getListById(int id) => _db.getTakeAwayListById(id);

  Future<int> createList(String name) async {
    final now = DateTime.now();
    return _db.into(_db.takeAwayLists).insert(
          TakeAwayListsCompanion.insert(
            name: name.trim(),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> renameList(int id, String name) async {
    await (_db.update(_db.takeAwayLists)..where((t) => t.id.equals(id))).write(
      TakeAwayListsCompanion(
        name: Value(name.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateListBackgroundColor(int id, int? backgroundColor) async {
    await (_db.update(_db.takeAwayLists)..where((t) => t.id.equals(id))).write(
      TakeAwayListsCompanion(
        backgroundColor: Value(backgroundColor),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteList(int id) async {
    final menus = await (_db.select(_db.takeAwayMenus)
          ..where((t) => t.listId.equals(id)))
        .get();
    for (final menu in menus) {
      await deleteMenu(menu.id);
    }
    await (_db.delete(_db.takeAwayLists)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<TakeAwayMenu>> watchMenusForList(int listId) =>
      _db.watchMenusForList(listId);

  Future<TakeAwayMenu?> getMenuById(int id) => _db.getTakeAwayMenuById(id);

  Stream<TakeAwayMenu?> watchMenuById(int id) => _db.watchTakeAwayMenuById(id);

  Stream<List<TakeAwayMenuItem>> watchMenuItems(int menuId) =>
      _db.watchMenuItems(menuId);

  Stream<TakeAwayOrderWithLines?> watchOrderWithLines(int menuId) =>
      _db.watchOrderWithLines(menuId);

  Future<int> createMenuFromImport({
    required int listId,
    required String restaurantName,
    String? location,
    String? mapsUrl,
    String? website,
    String? phone,
    String? menuUrl,
    String? currency,
    required List<TakeAwayMenuItemDraft> items,
    bool finalize = true,
  }) async {
    final now = DateTime.now();
    final menuId = await _db.into(_db.takeAwayMenus).insert(
          TakeAwayMenusCompanion.insert(
            listId: listId,
            restaurantName: restaurantName.trim(),
            location: Value(location?.trim()),
            mapsUrl: Value(mapsUrl?.trim()),
            website: Value(website?.trim()),
            phone: Value(phone?.trim()),
            menuUrl: Value(menuUrl?.trim()),
            currency: Value(currency?.trim()),
            isFinalized: Value(finalize),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await replaceMenuItems(menuId, items);
    await _touchListUpdated(listId);
    return menuId;
  }

  Future<void> updateMenu({
    required int menuId,
    required String restaurantName,
    String? location,
    String? mapsUrl,
    String? website,
    String? phone,
    String? menuUrl,
    String? currency,
  }) async {
    final menu = await getMenuById(menuId);
    if (menu == null) return;
    final now = DateTime.now();
    await (_db.update(_db.takeAwayMenus)..where((t) => t.id.equals(menuId)))
        .write(
      TakeAwayMenusCompanion(
        restaurantName: Value(restaurantName.trim()),
        location: Value(location?.trim()),
        mapsUrl: Value(mapsUrl?.trim()),
        website: Value(website?.trim()),
        phone: Value(phone?.trim()),
        menuUrl: Value(menuUrl?.trim()),
        currency: Value(currency?.trim()),
        updatedAt: Value(now),
      ),
    );
    await _touchListUpdated(menu.listId);
  }

  Future<void> finalizeMenu(int menuId) async {
    final menu = await getMenuById(menuId);
    if (menu == null) return;
    await (_db.update(_db.takeAwayMenus)..where((t) => t.id.equals(menuId)))
        .write(
      TakeAwayMenusCompanion(
        isFinalized: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _touchListUpdated(menu.listId);
  }

  Future<void> setMenuEditing(int menuId) async {
    final menu = await getMenuById(menuId);
    if (menu == null) return;
    await (_db.update(_db.takeAwayMenus)..where((t) => t.id.equals(menuId)))
        .write(
      TakeAwayMenusCompanion(
        isFinalized: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteMenu(int menuId) async {
    final menu = await getMenuById(menuId);
    if (menu == null) return;

    final order = await (_db.select(_db.takeAwayOrders)
          ..where((t) => t.menuId.equals(menuId)))
        .getSingleOrNull();
    if (order != null) {
      await (_db.delete(_db.takeAwayOrderLines)
            ..where((t) => t.orderId.equals(order.id)))
          .go();
      await (_db.delete(_db.takeAwayOrders)
            ..where((t) => t.id.equals(order.id)))
          .go();
    }

    await (_db.delete(_db.takeAwayMenuItems)
          ..where((t) => t.menuId.equals(menuId)))
        .go();
    await (_db.delete(_db.takeAwayMenus)..where((t) => t.id.equals(menuId)))
        .go();
    await _touchListUpdated(menu.listId);
  }

  Future<void> replaceMenuItems(
    int menuId,
    List<TakeAwayMenuItemDraft> items,
  ) async {
    await (_db.delete(_db.takeAwayMenuItems)
          ..where((t) => t.menuId.equals(menuId)))
        .go();
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      await _db.into(_db.takeAwayMenuItems).insert(
            TakeAwayMenuItemsCompanion.insert(
              menuId: menuId,
              itemNumber: Value(item.itemNumber?.trim()),
              name: item.name.trim(),
              priceDisplay: item.priceDisplay.trim().isEmpty
                  ? '—'
                  : item.priceDisplay.trim(),
              priceAmount: Value(item.priceAmount),
              sortOrder: Value(i),
            ),
          );
    }
    final menu = await getMenuById(menuId);
    if (menu != null) {
      await (_db.update(_db.takeAwayMenus)..where((t) => t.id.equals(menuId)))
          .write(TakeAwayMenusCompanion(updatedAt: Value(DateTime.now())));
      await _touchListUpdated(menu.listId);
    }
  }

  Future<void> addOrIncrementLine(int menuId, int menuItemId) async {
    final orderId = await _getOrCreateOrderId(menuId);
    final existing = await (_db.select(_db.takeAwayOrderLines)
          ..where(
            (t) =>
                t.orderId.equals(orderId) & t.menuItemId.equals(menuItemId),
          ))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.takeAwayOrderLines)
            ..where((t) => t.id.equals(existing.id)))
          .write(
        TakeAwayOrderLinesCompanion(
          quantity: Value(existing.quantity + 1),
        ),
      );
    } else {
      await _db.into(_db.takeAwayOrderLines).insert(
            TakeAwayOrderLinesCompanion.insert(
              orderId: orderId,
              menuItemId: menuItemId,
              quantity: const Value(1),
            ),
          );
    }
    await _touchOrderUpdated(menuId);
  }

  Future<void> setLineQuantity(
    int menuId,
    int menuItemId,
    int quantity,
  ) async {
    final orderId = await _getOrCreateOrderId(menuId);
    if (quantity <= 0) {
      await (_db.delete(_db.takeAwayOrderLines)
            ..where(
              (t) =>
                  t.orderId.equals(orderId) & t.menuItemId.equals(menuItemId),
            ))
          .go();
    } else {
      final existing = await (_db.select(_db.takeAwayOrderLines)
            ..where(
              (t) =>
                  t.orderId.equals(orderId) & t.menuItemId.equals(menuItemId),
            ))
          .getSingleOrNull();
      if (existing != null) {
        await (_db.update(_db.takeAwayOrderLines)
              ..where((t) => t.id.equals(existing.id)))
            .write(TakeAwayOrderLinesCompanion(quantity: Value(quantity)));
      } else {
        await _db.into(_db.takeAwayOrderLines).insert(
              TakeAwayOrderLinesCompanion.insert(
                orderId: orderId,
                menuItemId: menuItemId,
                quantity: Value(quantity),
              ),
            );
      }
    }
    await _touchOrderUpdated(menuId);
  }

  Future<void> clearOrder(int menuId) async {
    final order = await (_db.select(_db.takeAwayOrders)
          ..where((t) => t.menuId.equals(menuId)))
        .getSingleOrNull();
    if (order == null) return;
    await (_db.delete(_db.takeAwayOrderLines)
          ..where((t) => t.orderId.equals(order.id)))
        .go();
    await _touchOrderUpdated(menuId);
  }

  Future<int> _getOrCreateOrderId(int menuId) async {
    final existing = await (_db.select(_db.takeAwayOrders)
          ..where((t) => t.menuId.equals(menuId)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return _db.into(_db.takeAwayOrders).insert(
          TakeAwayOrdersCompanion.insert(
            menuId: menuId,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _touchOrderUpdated(int menuId) async {
    final now = DateTime.now();
    final orderId = await _getOrCreateOrderId(menuId);
    await (_db.update(_db.takeAwayOrders)..where((t) => t.id.equals(orderId)))
        .write(TakeAwayOrdersCompanion(updatedAt: Value(now)));
    final menu = await getMenuById(menuId);
    if (menu != null) {
      await _touchListUpdated(menu.listId);
    }
  }

  Future<void> _touchListUpdated(int listId) async {
    await (_db.update(_db.takeAwayLists)..where((t) => t.id.equals(listId)))
        .write(TakeAwayListsCompanion(updatedAt: Value(DateTime.now())));
  }
}
