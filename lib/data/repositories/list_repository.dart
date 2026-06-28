import 'package:drift/drift.dart';

import '../../core/utils/device_id_service.dart';
import '../../core/utils/sync_id_generator.dart';
import '../database/app_database.dart';
import '../sync/sync_entity_type.dart';
import '../sync/sync_outbox_helper.dart';
import 'catalog_repository.dart';
import 'learning_repository.dart';
import 'shop_stats_repository.dart';

class ListRepository {
  ListRepository(
    this._db,
    this._catalog,
    this._learning,
    this._shopStats, {
    SyncOutboxHelper? syncOutbox,
    DeviceIdService? deviceId,
  })  : _syncOutbox = syncOutbox,
        _deviceId = deviceId;

  final AppDatabase _db;
  final CatalogRepository _catalog;
  final LearningRepository _learning;
  final ShopStatsRepository _shopStats;
  final SyncOutboxHelper? _syncOutbox;
  final DeviceIdService? _deviceId;

  Stream<List<ShoppingList>> watchAllLists() => _db.watchAllLists();

  Future<ShoppingList?> getListById(int id) => _db.getListById(id);

  Future<int> createList(String name) async {
    final now = DateTime.now();
    return _db.into(_db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            globalId: Value(generateSyncId()),
            name: name.trim(),
            createdAt: now,
            updatedAt: now,
            modifiedByDevice: Value(_deviceId?.deviceId),
          ),
        );
  }

  Future<void> renameList(int id, String name) async {
    final now = DateTime.now();
    final list = await getListById(id);
    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(id))).write(
      ShoppingListsCompanion(
        name: Value(name.trim()),
        updatedAt: Value(now),
        modifiedByDevice: Value(_deviceId?.deviceId),
      ),
    );
    await _enqueueList(list, shoppingListItem: false);
  }

  Future<void> deleteList(int id) async {
    final list = await getListById(id);
    if (list?.syncEnabled == true) {
      final now = DateTime.now();
      await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(id)))
          .write(
        ShoppingListsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncEnabled: const Value(false),
          modifiedByDevice: Value(_deviceId?.deviceId),
        ),
      );
      await _enqueueList(list, shoppingListItem: false);
      return;
    }

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
    double? quantityValue,
    String? quantityUnit,
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

    final list = await getListById(listId);
    final itemId = await _db.into(_db.listItems).insert(
          ListItemsCompanion.insert(
            globalId: Value(generateSyncId()),
            listId: listId,
            catalogItemId: Value(resolvedCatalogId),
            displayName: displayName.trim(),
            categoryId: resolvedCategoryId,
            quantityValue: quantityValue != null
                ? Value(quantityValue)
                : const Value.absent(),
            quantityUnit: quantityUnit != null
                ? Value(quantityUnit)
                : const Value.absent(),
            addedAt: now,
            updatedAt: Value(now),
            modifiedByDevice: Value(_deviceId?.deviceId),
          ),
        );

    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
        .write(
      ShoppingListsCompanion(
        updatedAt: Value(now),
        modifiedByDevice: Value(_deviceId?.deviceId),
      ),
    );

    final item = await getListItemById(itemId);
    await _enqueueItem(list, item, shoppingListItem: true);
    return itemId;
  }

  Future<void> addItemFromCatalog({
    required int listId,
    required CatalogItem catalogItem,
    double? quantityValue,
    String? quantityUnit,
  }) {
    return addItem(
      listId: listId,
      displayName: catalogItem.displayName,
      categoryId: catalogItem.categoryId,
      catalogItemId: catalogItem.id,
      quantityValue: quantityValue,
      quantityUnit: quantityUnit,
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
    final item = await getListItemById(id);
    final list = item != null ? await getListById(item.listId) : null;
    final now = DateTime.now();
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
        updatedAt: Value(now),
        modifiedByDevice: Value(_deviceId?.deviceId),
      ),
    );
    await _enqueueItem(list, item, shoppingListItem: true);
  }

  Future<void> deleteListItem(int id) async {
    final item = await getListItemById(id);
    final list = item != null ? await getListById(item.listId) : null;
    if (list?.syncEnabled == true && item?.globalId != null) {
      final now = DateTime.now();
      await (_db.update(_db.listItems)..where((t) => t.id.equals(id))).write(
        ListItemsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          modifiedByDevice: Value(_deviceId?.deviceId),
        ),
      );
      await _enqueueItem(list, item, shoppingListItem: true);
      return;
    }
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
    final list = await getListById(listId);
    final item = await getListItemById(itemId);
    if (completed) {
      await _learning.recordCheckOff(listId: listId, listItemId: itemId);
      await (_db.update(_db.listItems)..where((t) => t.id.equals(itemId)))
          .write(
        ListItemsCompanion(
          isCompleted: const Value(true),
          completedAt: Value(now),
          updatedAt: Value(now),
          modifiedByDevice: Value(_deviceId?.deviceId),
        ),
      );
    } else {
      await (_db.update(_db.listItems)..where((t) => t.id.equals(itemId)))
          .write(
        ListItemsCompanion(
          isCompleted: const Value(false),
          completedAt: const Value(null),
          updatedAt: Value(now),
          modifiedByDevice: Value(_deviceId?.deviceId),
        ),
      );
    }

    await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
        .write(
      ShoppingListsCompanion(
        updatedAt: Value(now),
        lastCheckOffAt: completed ? Value(now) : const Value.absent(),
        modifiedByDevice: Value(_deviceId?.deviceId),
      ),
    );

    await _enqueueItem(list, item, shoppingListItem: true);
    await _enqueueList(list, shoppingListItem: false);

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

    final list = await getListById(listId);
    final completedItems = await (_db.select(_db.listItems)
          ..where(
            (t) => t.listId.equals(listId) & t.isCompleted.equals(true),
          ))
        .get();

    if (list?.syncEnabled == true) {
      final now = DateTime.now();
      for (final item in completedItems) {
        await (_db.update(_db.listItems)..where((t) => t.id.equals(item.id)))
            .write(
          ListItemsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            modifiedByDevice: Value(_deviceId?.deviceId),
          ),
        );
        await _enqueueItem(list, item, shoppingListItem: true);
      }
    } else {
      await (_db.delete(_db.listItems)
            ..where((t) => t.listId.equals(listId) & t.isCompleted.equals(true)))
          .go();
    }

    final shoppingList = await getListById(listId);
    if (shoppingList != null) {
      await (_db.update(_db.shoppingLists)..where((t) => t.id.equals(listId)))
          .write(
        ShoppingListsCompanion(
          currentTripId: Value(shoppingList.currentTripId + 1),
          currentTripSequence: const Value(0),
          updatedAt: Value(DateTime.now()),
          modifiedByDevice: Value(_deviceId?.deviceId),
        ),
      );
      await _enqueueList(shoppingList, shoppingListItem: false);
    }
  }

  Future<void> resetLearnedOrder(int listId) =>
      _learning.resetLearnedOrder(listId);

  Future<void> _enqueueList(
    ShoppingList? list, {
    required bool shoppingListItem,
  }) async {
    if (list == null || !list.syncEnabled || list.globalId == null) return;
    await _syncOutbox?.enqueueIfSynced(
      globalId: list.globalId,
      entityType: SyncEntityType.shoppingList,
      syncEnabled: true,
      shoppingListItem: shoppingListItem,
    );
  }

  Future<void> _enqueueItem(
    ShoppingList? list,
    ListItem? item, {
    required bool shoppingListItem,
  }) async {
    if (list == null ||
        item == null ||
        !list.syncEnabled ||
        item.globalId == null) {
      return;
    }
    await _syncOutbox?.enqueueIfSynced(
      globalId: item.globalId,
      entityType: SyncEntityType.listItem,
      syncEnabled: true,
      shoppingListItem: shoppingListItem,
    );
  }
}
