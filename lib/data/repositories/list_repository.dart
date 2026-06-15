import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'catalog_repository.dart';
import 'learning_repository.dart';
import 'shop_stats_repository.dart';

class ListRepository {
  ListRepository(
    this._db,
    this._catalog,
    this._learning,
    this._shopStats,
  );

  final AppDatabase _db;
  final CatalogRepository _catalog;
  final LearningRepository _learning;
  final ShopStatsRepository _shopStats;

  Stream<List<ShoppingList>> watchAllLists() => _db.watchAllLists();

  Future<ShoppingList?> getListById(int id) => _db.getListById(id);

  Future<int> createList(String name) async {
    final now = DateTime.now();
    return _db.into(_db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            name: name.trim(),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> renameList(int id, String name) async {
    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(id))).write(
      ShoppingListsCompanion(
        name: Value(name.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteList(int id) async {
    await (_db.delete(_db.checkOffEvents)..where((t) => t.listId.equals(id)))
        .go();
    await (_db.delete(_db.categoryRankStats)..where((t) => t.listId.equals(id)))
        .go();
    await (_db.delete(_db.itemRankStats)..where((t) => t.listId.equals(id)))
        .go();
    await _shopStats.deleteRecordsForList(id);
    await (_db.delete(_db.listItems)..where((t) => t.listId.equals(id))).go();
    await (_db.delete(_db.shoppingLists)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<ListItem>> watchListItems(int listId) =>
      _db.watchListItems(listId);

  Future<ListItem?> getListItemById(int id) => _db.getListItemById(id);

  Future<int> activeItemCount(int listId) => _db.activeItemCount(listId);

  Future<int> addItem({
    required int listId,
    required String displayName,
    String? categoryId,
    int? catalogItemId,
  }) async {
    final now = DateTime.now();
    String resolvedCategoryId = categoryId ?? 'other';
    int? resolvedCatalogId = catalogItemId;

    if (resolvedCatalogId == null) {
      final catalogItem = await _catalog.getOrCreate(
        displayName: displayName,
        categoryId: resolvedCategoryId,
        isUserAdded: true,
      );
      resolvedCatalogId = catalogItem.id;
      resolvedCategoryId = catalogItem.categoryId;
    }

    final itemId = await _db.into(_db.listItems).insert(
          ListItemsCompanion.insert(
            listId: listId,
            catalogItemId: Value(resolvedCatalogId),
            displayName: displayName.trim(),
            categoryId: resolvedCategoryId,
            addedAt: now,
          ),
        );

    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
        .write(ShoppingListsCompanion(updatedAt: Value(now)));

    return itemId;
  }

  Future<void> addItemFromCatalog({
    required int listId,
    required CatalogItem catalogItem,
  }) {
    return addItem(
      listId: listId,
      displayName: catalogItem.displayName,
      categoryId: catalogItem.categoryId,
      catalogItemId: catalogItem.id,
    );
  }

  Future<void> updateListItem({
    required int id,
    String? displayName,
    String? categoryId,
    double? quantityValue,
    String? quantityUnit,
    bool clearQuantity = false,
  }) async {
    await (_db.update(_db.listItems)..where((t) => t.id.equals(id))).write(
      ListItemsCompanion(
        displayName: displayName != null
            ? Value(displayName.trim())
            : const Value.absent(),
        categoryId:
            categoryId != null ? Value(categoryId) : const Value.absent(),
        quantityValue: clearQuantity
            ? const Value(null)
            : quantityValue != null
                ? Value(quantityValue)
                : const Value.absent(),
        quantityUnit: clearQuantity
            ? const Value(null)
            : quantityUnit != null
                ? Value(quantityUnit)
                : const Value.absent(),
      ),
    );
  }

  Future<void> deleteListItem(int id) async {
    await (_db.delete(_db.listItems)..where((t) => t.id.equals(id))).go();
  }

  Future<ShopCompletionResult?> setItemCompleted(
    int listId,
    int itemId,
    bool completed, {
    bool shopStatsEnabled = false,
    int? remainingAfter,
    int? totalItems,
  }) async {
    final now = DateTime.now();
    if (completed) {
      await _learning.recordCheckOff(listId: listId, listItemId: itemId);
      await (_db.update(_db.listItems)..where((t) => t.id.equals(itemId)))
          .write(
        ListItemsCompanion(
          isCompleted: const Value(true),
          completedAt: Value(now),
        ),
      );
    } else {
      await (_db.update(_db.listItems)..where((t) => t.id.equals(itemId)))
          .write(
        const ListItemsCompanion(
          isCompleted: Value(false),
          completedAt: Value(null),
        ),
      );
    }

    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
        .write(
      ShoppingListsCompanion(
        updatedAt: Value(now),
        lastCheckOffAt: completed ? Value(now) : const Value.absent(),
      ),
    );

    if (shopStatsEnabled && completed && remainingAfter != null && totalItems != null) {
      return _shopStats.onItemCheckedOff(
        listId: listId,
        remainingAfter: remainingAfter,
        totalItems: totalItems,
        checkedAt: now,
      );
    }

    return null;
  }

  Future<void> clearCompleted(
    int listId, {
    bool shopStatsEnabled = false,
  }) async {
    if (shopStatsEnabled) {
      await _shopStats.abandonSession(listId);
    }

    await (_db.delete(_db.listItems)
          ..where((t) => t.listId.equals(listId) & t.isCompleted.equals(true)))
        .go();

    final shoppingList = await getListById(listId);
    if (shoppingList != null) {
      await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
          .write(
        ShoppingListsCompanion(
          currentTripId: Value(shoppingList.currentTripId + 1),
          currentTripSequence: const Value(0),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> resetLearnedOrder(int listId) =>
      _learning.resetLearnedOrder(listId);
}
