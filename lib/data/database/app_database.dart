import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';
import '../services/ingredient_parser_service.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Categories,
  CatalogItems,
  CatalogItemAliases,
  CatalogItemExclusions,
  ShoppingLists,
  ListItems,
  CheckOffEvents,
  CategoryRankStats,
  ItemRankStats,
  ShopStatsRecords,
  Meals,
  MealPlanItems,
  MealIngredients,
  MealCheckOffEvents,
  MealSteps,
  MealTags,
  MealTagAssignments,
  TodoLists,
  TodoItems,
  TodoCompletedArchive,
  TakeAwayLists,
  TakeAwayMenus,
  TakeAwayMenuItems,
  TakeAwayOrders,
  TakeAwayOrderLines,
  ReceiptLists,
  Receipts,
  ReceiptLines,
  ReceiptAiInsightRuns,
  OverviewOrderEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(
              shoppingLists,
              shoppingLists.activeShopStartedAt,
            );
            await m.createTable(shopStatsRecords);
          }
          if (from < 3) {
            await m.createTable(meals);
            await m.createTable(mealPlanItems);
            await m.createTable(mealIngredients);
            await m.createTable(mealCheckOffEvents);
          }
          if (from < 4) {
            await m.createTable(mealSteps);
            await m.createTable(mealTags);
            await m.createTable(mealTagAssignments);
          }
          if (from < 5) {
            await m.createTable(todoLists);
            await m.createTable(todoItems);
            await m.createTable(todoCompletedArchive);
          }
          if (from < 6) {
            await m.createTable(takeAwayLists);
            await m.createTable(takeAwayMenus);
            await m.createTable(takeAwayMenuItems);
            await m.createTable(takeAwayOrders);
            await m.createTable(takeAwayOrderLines);
          }
          if (from < 7) {
            await m.addColumn(mealIngredients, mealIngredients.quantityValue);
            await m.addColumn(mealIngredients, mealIngredients.quantityUnit);
            await m.addColumn(mealPlanItems, mealPlanItems.scaleFactor);
            await _backfillMealIngredientQuantities(m.database);
          }
          if (from < 8) {
            await m.createTable(receiptLists);
            await m.createTable(receipts);
            await m.createTable(receiptLines);
            await m.createTable(receiptAiInsightRuns);
          }
          if (from < 9) {
            await m.createTable(overviewOrderEntries);
          }
          if (from < 10) {
            await m.createTable(catalogItemAliases);
            await m.createTable(catalogItemExclusions);
          }
          if (from < 11) {
            await m.addColumn(meals, meals.viewScaleFactor);
          }
          if (from < 12) {
            await m.addColumn(meals, meals.prepTimeMinutes);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'list_pilot');
  }

  Future<bool> hasCategories() async {
    final count = await customSelect(
      'SELECT COUNT(*) AS c FROM categories',
      readsFrom: {categories},
    ).getSingle();
    return count.read<int>('c') > 0;
  }

  Future<bool> hasCatalogItems() async {
    final count = await customSelect(
      'SELECT COUNT(*) AS c FROM catalog_items',
      readsFrom: {catalogItems},
    ).getSingle();
    return count.read<int>('c') > 0;
  }

  Future<List<CatalogItem>> searchCatalog(String query, {int limit = 8}) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return (select(catalogItems)
            ..orderBy([(t) => OrderingTerm.asc(t.displayName)])
            ..limit(limit))
          .get();
    }
    return (select(catalogItems)
          ..where((t) => t.name.like('$normalized%'))
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)])
          ..limit(limit))
        .get();
  }

  Future<CatalogItem?> findCatalogByName(String name) {
    final normalized = name.trim().toLowerCase();
    return (select(catalogItems)..where((t) => t.name.equals(normalized)))
        .getSingleOrNull();
  }

  Future<CatalogItem?> findCatalogByToken(String token) {
    final normalized = token.trim().toLowerCase();
    if (normalized.isEmpty) return Future.value(null);
    return (select(catalogItems)..where((t) => t.name.equals(normalized)))
        .getSingleOrNull();
  }

  Future<CatalogItem?> findCatalogByAlias(String alias) async {
    final normalized = alias.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final aliasRow = await (select(catalogItemAliases)
          ..where((t) => t.alias.equals(normalized)))
        .getSingleOrNull();
    if (aliasRow == null) return null;

    return getCatalogItemById(aliasRow.catalogItemId);
  }

  Future<CatalogItem?> findCatalogByNameOrAlias(String name) async {
    final byName = await findCatalogByName(name);
    if (byName != null) return byName;
    return findCatalogByAlias(name);
  }

  Future<CatalogItem?> getCatalogItemById(int id) {
    return (select(catalogItems)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<CatalogItem>> getAllCatalogItemsOrdered() {
    return (select(catalogItems)
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
        .get();
  }

  Future<List<CatalogItem>> searchCatalogAndAliases(
    String query, {
    int limit = 8,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return searchCatalog(query, limit: limit);
    }

    final byName = await (select(catalogItems)
          ..where((t) => t.name.like('$normalized%'))
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
        .get();

    final aliasRows = await (select(catalogItemAliases)
          ..where((t) => t.alias.like('$normalized%')))
        .get();

    final aliasItemIds = aliasRows.map((row) => row.catalogItemId).toSet();
    final aliasItems = aliasItemIds.isEmpty
        ? <CatalogItem>[]
        : await (select(catalogItems)
              ..where((t) => t.id.isIn(aliasItemIds.toList())))
            .get();

    final seenIds = <int>{};
    final results = <CatalogItem>[];
    for (final item in [...byName, ...aliasItems]) {
      if (seenIds.add(item.id)) {
        results.add(item);
      }
    }

    results.sort((a, b) => a.displayName.compareTo(b.displayName));
    if (results.length > limit) {
      return results.sublist(0, limit);
    }
    return results;
  }

  Future<List<CatalogItemAlias>> getAliasesForCatalogItem(int catalogItemId) {
    return (select(catalogItemAliases)
          ..where((t) => t.catalogItemId.equals(catalogItemId))
          ..orderBy([(t) => OrderingTerm.asc(t.alias)]))
        .get();
  }

  Future<Map<int, int>> getAliasCountsByCatalogItemId() async {
    final rows = await customSelect(
      'SELECT catalog_item_id AS item_id, COUNT(*) AS alias_count '
      'FROM catalog_item_aliases GROUP BY catalog_item_id',
      readsFrom: {catalogItemAliases},
    ).get();

    return {
      for (final row in rows)
        row.read<int>('item_id'): row.read<int>('alias_count'),
    };
  }

  Future<bool> isCatalogNameExcluded(String name) async {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    final row = await (select(catalogItemExclusions)
          ..where((t) => t.name.equals(normalized)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> addCatalogExclusion(String name) {
    final normalized = name.trim().toLowerCase();
    return into(catalogItemExclusions).insert(
      CatalogItemExclusionsCompanion.insert(name: normalized),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> clearCatalogItemReferences(int catalogItemId) async {
    await (update(listItems)
          ..where((t) => t.catalogItemId.equals(catalogItemId)))
        .write(const ListItemsCompanion(catalogItemId: Value(null)));
    await (update(mealIngredients)
          ..where((t) => t.catalogItemId.equals(catalogItemId)))
        .write(const MealIngredientsCompanion(catalogItemId: Value(null)));
    await (update(receiptLines)
          ..where((t) => t.catalogItemId.equals(catalogItemId)))
        .write(const ReceiptLinesCompanion(catalogItemId: Value(null)));
  }

  Future<void> deleteCatalogItemById(int id) async {
    await (delete(catalogItems)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<ShoppingList>> watchAllLists() {
    return (select(shoppingLists)
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  Future<ShoppingList?> getListById(int id) {
    return (select(shoppingLists)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<ListItem>> watchListItems(int listId) {
    return (select(listItems)..where((t) => t.listId.equals(listId))).watch();
  }

  Future<ListItem?> getListItemById(int id) {
    return (select(listItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> activeItemCount(int listId) async {
    final count = await customSelect(
      'SELECT COUNT(*) AS c FROM list_items WHERE list_id = ? AND is_completed = 0',
      variables: [Variable<int>(listId)],
      readsFrom: {listItems},
    ).getSingle();
    return count.read<int>('c');
  }

  Future<List<Category>> getAllCategories() {
    return (select(categories)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<List<CheckOffEvent>> getCheckOffEventsForList(int listId) {
    return (select(checkOffEvents)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.asc(t.checkedAt)]))
        .get();
  }

  Future<List<CategoryRankStat>> getCategoryRankStats(int listId) {
    return (select(categoryRankStats)
          ..where((t) => t.listId.equals(listId)))
        .get();
  }

  Future<List<ItemRankStat>> getItemRankStats(int listId) {
    return (select(itemRankStats)..where((t) => t.listId.equals(listId))).get();
  }

  Future<void> upsertCategoryRankStat(CategoryRankStatsCompanion stat) {
    return into(categoryRankStats).insert(
      stat,
      onConflict: DoUpdate(
        (old) => stat,
        target: [categoryRankStats.listId, categoryRankStats.categoryId],
      ),
    );
  }

  Future<void> upsertItemRankStat(ItemRankStatsCompanion stat) {
    return into(itemRankStats).insert(
      stat,
      onConflict: DoUpdate(
        (old) => stat,
        target: [itemRankStats.listId, itemRankStats.catalogItemId],
      ),
    );
  }

  Future<void> clearRankStatsForList(int listId) async {
    await (delete(categoryRankStats)..where((t) => t.listId.equals(listId)))
        .go();
    await (delete(itemRankStats)..where((t) => t.listId.equals(listId))).go();
  }

  Future<List<Meal>> searchMeals(String query, {int limit = 8}) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return (select(meals)
            ..orderBy([(t) => OrderingTerm.asc(t.displayName)])
            ..limit(limit))
          .get();
    }
    final results = await (select(meals)
          ..where((t) => t.name.like('%$normalized%')))
        .get();
    results.sort((a, b) {
      final aPrefix = a.name.startsWith(normalized);
      final bPrefix = b.name.startsWith(normalized);
      if (aPrefix != bPrefix) return aPrefix ? -1 : 1;
      return a.displayName.compareTo(b.displayName);
    });
    return results.take(limit).toList();
  }

  Future<Meal?> findMealByName(String name) {
    final normalized = name.trim().toLowerCase();
    return (select(meals)..where((t) => t.name.equals(normalized)))
        .getSingleOrNull();
  }

  Future<Meal?> getMealById(int id) {
    return (select(meals)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<MealPlanItemWithMeal>> watchMealPlanItems() {
    final query = select(mealPlanItems).join([
      innerJoin(meals, meals.id.equalsExp(mealPlanItems.mealId)),
    ])
      ..orderBy([
        OrderingTerm.asc(mealPlanItems.isCompleted),
        OrderingTerm.asc(mealPlanItems.addedAt),
      ]);
    return query.watch().map((rows) {
      return rows
          .map(
            (row) => MealPlanItemWithMeal(
              planItem: row.readTable(mealPlanItems),
              meal: row.readTable(meals),
            ),
          )
          .toList();
    });
  }

  Future<DateTime?> getLastEatenDate(int mealId) async {
    final result = await (select(mealCheckOffEvents)
          ..where((t) => t.mealId.equals(mealId))
          ..orderBy([(t) => OrderingTerm.desc(t.checkedAt)])
          ..limit(1))
        .getSingleOrNull();
    return result?.checkedAt;
  }

  Stream<List<MealCheckOffEventWithMeal>> watchMealsEatenOnDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final query = select(mealCheckOffEvents).join([
      innerJoin(meals, meals.id.equalsExp(mealCheckOffEvents.mealId)),
    ])
      ..where(mealCheckOffEvents.checkedAt.isBetweenValues(start, end))
      ..orderBy([OrderingTerm.asc(mealCheckOffEvents.checkedAt)]);
    return query.watch().map((rows) {
      return rows
          .map(
            (row) => MealCheckOffEventWithMeal(
              event: row.readTable(mealCheckOffEvents),
              meal: row.readTable(meals),
            ),
          )
          .toList();
    });
  }

  Future<List<MealCheckOffEvent>> getCheckOffEventsInRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(mealCheckOffEvents)
          ..where((t) => t.checkedAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.asc(t.checkedAt)]))
        .get();
  }

  Future<List<MealIngredient>> getIngredientsForMeal(int mealId) {
    return (select(mealIngredients)
          ..where((t) => t.mealId.equals(mealId))
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
        .get();
  }

  Stream<List<MealIngredient>> watchIngredientsForMeal(int mealId) {
    return (select(mealIngredients)
          ..where((t) => t.mealId.equals(mealId))
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
        .watch();
  }

  Stream<List<Meal>> watchAllMeals() {
    return (select(meals)
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
        .watch();
  }

  Future<List<Meal>> searchMealsWithTags(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return (select(meals)
            ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
          .get();
    }
    final rows = await customSelect(
      '''
      SELECT DISTINCT m.*
      FROM meals m
      LEFT JOIN meal_tag_assignments mta ON mta.meal_id = m.id
      LEFT JOIN meal_tags mt ON mt.id = mta.tag_id
      WHERE m.name LIKE ? OR mt.name LIKE ?
      ORDER BY
        CASE WHEN m.name LIKE ? THEN 0 ELSE 1 END,
        m.display_name ASC
      ''',
      variables: [
        Variable<String>('%$normalized%'),
        Variable<String>('%$normalized%'),
        Variable<String>('$normalized%'),
      ],
      readsFrom: {meals, mealTagAssignments, mealTags},
    ).get();
    return rows
        .map(
          (row) => Meal(
            id: row.read<int>('id'),
            name: row.read<String>('name'),
            displayName: row.read<String>('display_name'),
            photoPath: row.read<String?>('photo_path'),
            notes: row.read<String?>('notes'),
            portions: row.read<int>('portions'),
            recipeLink: row.read<String?>('recipe_link'),
            isUserAdded: row.read<bool>('is_user_added'),
            createdAt: row.read<DateTime>('created_at'),
            viewScaleFactor: row.read<double>('view_scale_factor'),
          ),
        )
        .toList();
  }

  Future<List<MealStep>> getStepsForMeal(int mealId) {
    return (select(mealSteps)
          ..where((t) => t.mealId.equals(mealId))
          ..orderBy([(t) => OrderingTerm.asc(t.stepOrder)]))
        .get();
  }

  Stream<List<MealStep>> watchStepsForMeal(int mealId) {
    return (select(mealSteps)
          ..where((t) => t.mealId.equals(mealId))
          ..orderBy([(t) => OrderingTerm.asc(t.stepOrder)]))
        .watch();
  }

  Future<List<MealTag>> searchTags(String query, {int limit = 8}) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return (select(mealTags)
            ..orderBy([(t) => OrderingTerm.asc(t.displayName)])
            ..limit(limit))
          .get();
    }
    return (select(mealTags)
          ..where((t) => t.name.like('$normalized%'))
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)])
          ..limit(limit))
        .get();
  }

  Future<List<MealTag>> getTagsForMeal(int mealId) {
    final query = select(mealTags).join([
      innerJoin(
        mealTagAssignments,
        mealTagAssignments.tagId.equalsExp(mealTags.id),
      ),
    ])
      ..where(mealTagAssignments.mealId.equals(mealId))
      ..orderBy([OrderingTerm.asc(mealTags.displayName)]);
    return query.get().then(
          (rows) => rows.map((row) => row.readTable(mealTags)).toList(),
        );
  }

  Stream<List<MealTag>> watchTagsForMeal(int mealId) {
    final query = select(mealTags).join([
      innerJoin(
        mealTagAssignments,
        mealTagAssignments.tagId.equalsExp(mealTags.id),
      ),
    ])
      ..where(mealTagAssignments.mealId.equals(mealId))
      ..orderBy([OrderingTerm.asc(mealTags.displayName)]);
    return query.watch().map(
          (rows) => rows.map((row) => row.readTable(mealTags)).toList(),
        );
  }

  Stream<List<TodoList>> watchAllTodoLists() {
    return (select(todoLists)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<TodoList?> getTodoListById(int id) {
    return (select(todoLists)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<TodoItem>> watchTodoItems(int listId) {
    return (select(todoItems)..where((t) => t.listId.equals(listId))).watch();
  }

  Future<TodoItem?> getTodoItemById(int id) {
    return (select(todoItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<TodoItem?> watchTodoItemById(int id) {
    return (select(todoItems)..where((t) => t.id.equals(id)))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<List<TodoItem>> getTodoItemsWithReminders() {
    return (select(todoItems)
          ..where((t) => t.reminderAt.isNotNull() & t.isCompleted.equals(false)))
        .get();
  }

  Stream<List<TodoCompletedArchiveData>> watchArchivedCompleted(int listId) {
    return (select(todoCompletedArchive)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .watch();
  }

  Future<List<String>> searchTodoTaskTitles(
    int listId,
    String query, {
    int limit = 8,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    final activeRows = await customSelect(
      '''
      SELECT DISTINCT display_name FROM todo_items
      WHERE list_id = ? AND LOWER(display_name) LIKE ?
      ''',
      variables: [
        Variable<int>(listId),
        Variable<String>('$normalized%'),
      ],
      readsFrom: {todoItems},
    ).get();

    final archiveRows = await customSelect(
      '''
      SELECT DISTINCT display_name FROM todo_completed_archive
      WHERE list_id = ? AND LOWER(display_name) LIKE ?
      ''',
      variables: [
        Variable<int>(listId),
        Variable<String>('$normalized%'),
      ],
      readsFrom: {todoCompletedArchive},
    ).get();

    final names = <String>{};
    for (final row in activeRows) {
      names.add(row.read<String>('display_name'));
    }
    for (final row in archiveRows) {
      names.add(row.read<String>('display_name'));
    }
    final sorted = names.toList()..sort();
    return sorted.take(limit).toList();
  }

  Stream<List<TakeAwayList>> watchAllTakeAwayLists() {
    return (select(takeAwayLists)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<TakeAwayList?> getTakeAwayListById(int id) {
    return (select(takeAwayLists)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<TakeAwayMenu>> watchMenusForList(int listId) {
    return (select(takeAwayMenus)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<TakeAwayMenu?> getTakeAwayMenuById(int id) {
    return (select(takeAwayMenus)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<TakeAwayMenu?> watchTakeAwayMenuById(int id) {
    return (select(takeAwayMenus)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Stream<List<TakeAwayMenuItem>> watchMenuItems(int menuId) {
    return (select(takeAwayMenuItems)
          ..where((t) => t.menuId.equals(menuId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<List<TakeAwayMenuItem>> getMenuItems(int menuId) {
    return (select(takeAwayMenuItems)
          ..where((t) => t.menuId.equals(menuId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Stream<TakeAwayOrderWithLines?> watchOrderWithLines(int menuId) {
    final orderQuery = select(takeAwayOrders)
      ..where((t) => t.menuId.equals(menuId));
    return orderQuery.watchSingleOrNull().asyncExpand((order) {
      if (order == null) {
        return Stream.value(null);
      }
      final linesQuery = select(takeAwayOrderLines).join([
        innerJoin(
          takeAwayMenuItems,
          takeAwayMenuItems.id.equalsExp(takeAwayOrderLines.menuItemId),
        ),
      ])
        ..where(takeAwayOrderLines.orderId.equals(order.id))
        ..orderBy([OrderingTerm.asc(takeAwayMenuItems.sortOrder)]);
      return linesQuery.watch().map((rows) {
        final lines = rows
            .map(
              (row) => TakeAwayOrderLineWithItem(
                line: row.readTable(takeAwayOrderLines),
                menuItem: row.readTable(takeAwayMenuItems),
              ),
            )
            .toList();
        return TakeAwayOrderWithLines(order: order, lines: lines);
      });
    });
  }

  Future<int> countOrderLinesForMenu(int menuId) async {
    final order = await (select(takeAwayOrders)
          ..where((t) => t.menuId.equals(menuId)))
        .getSingleOrNull();
    if (order == null) return 0;
    final count = await customSelect(
      'SELECT COUNT(*) AS c FROM take_away_order_lines WHERE order_id = ?',
      variables: [Variable<int>(order.id)],
      readsFrom: {takeAwayOrderLines},
    ).getSingle();
    return count.read<int>('c');
  }

  Stream<List<ReceiptList>> watchAllReceiptLists() {
    return (select(receiptLists)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<ReceiptList?> getReceiptListById(int id) {
    return (select(receiptLists)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<Receipt>> watchReceiptsForList(int listId) {
    return (select(receipts)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.desc(t.purchasedAt)]))
        .watch();
  }

  Future<Receipt?> getReceiptById(int id) {
    return (select(receipts)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<Receipt?> watchReceiptById(int id) {
    return (select(receipts)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Stream<List<ReceiptLine>> watchLinesForReceipt(int receiptId) {
    return (select(receiptLines)
          ..where((t) => t.receiptId.equals(receiptId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<List<ReceiptLine>> getLinesForReceipt(int receiptId) {
    return (select(receiptLines)
          ..where((t) => t.receiptId.equals(receiptId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<Receipt?> findDuplicateReceipt({
    required int listId,
    required DateTime purchasedAt,
    String? receiptNumber,
  }) async {
    final dayStart = DateTime(
      purchasedAt.year,
      purchasedAt.month,
      purchasedAt.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));
    final query = select(receipts)
      ..where(
        (t) =>
            t.listId.equals(listId) &
            t.purchasedAt.isBiggerOrEqualValue(dayStart) &
            t.purchasedAt.isSmallerThanValue(dayEnd),
      );
    if (receiptNumber != null && receiptNumber.isNotEmpty) {
      query.where((t) => t.receiptNumber.equals(receiptNumber));
    }
    return query.getSingleOrNull();
  }

  Future<List<ReceiptLineWithReceipt>> getLinesForList(int listId) async {
    final query = select(receiptLines).join([
      innerJoin(receipts, receipts.id.equalsExp(receiptLines.receiptId)),
    ])
      ..where(receipts.listId.equals(listId));
    final rows = await query.get();
    return rows
        .map(
          (row) => ReceiptLineWithReceipt(
            line: row.readTable(receiptLines),
            receipt: row.readTable(receipts),
          ),
        )
        .toList();
  }

  Stream<ReceiptAiInsightRun?> watchLatestAiInsight(int listId) {
    return (select(receiptAiInsightRuns)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.desc(t.generatedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<OverviewOrderEntry>> watchOverviewOrderEntries() {
    return (select(overviewOrderEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }
}

Future<void> _backfillMealIngredientQuantities(GeneratedDatabase db) async {
  const parser = IngredientParserService();
  final rows = await db.customSelect(
    'SELECT id, display_name FROM meal_ingredients',
  ).get();

  for (final row in rows) {
    final id = row.read<int>('id');
    final displayName = row.read<String>('display_name');
    final parsed = parser.parse(displayName);
    if (parsed.itemName.isEmpty) continue;

    final hasQty = parsed.quantityValue != null && parsed.quantityUnit != null;
    await db.customUpdate(
      'UPDATE meal_ingredients SET display_name = ?, quantity_value = ?, quantity_unit = ? WHERE id = ?',
      variables: [
        Variable<String>(parsed.itemName),
        hasQty ? Variable<double>(parsed.quantityValue!) : const Variable(null),
        hasQty ? Variable<String>(parsed.quantityUnit!) : const Variable(null),
        Variable<int>(id),
      ],
      updates: {},
    );
  }
}

class MealPlanItemWithMeal {
  const MealPlanItemWithMeal({required this.planItem, required this.meal});

  final MealPlanItem planItem;
  final Meal meal;
}

class MealCheckOffEventWithMeal {
  const MealCheckOffEventWithMeal({required this.event, required this.meal});

  final MealCheckOffEvent event;
  final Meal meal;
}

class TakeAwayOrderLineWithItem {
  const TakeAwayOrderLineWithItem({required this.line, required this.menuItem});

  final TakeAwayOrderLine line;
  final TakeAwayMenuItem menuItem;
}

class TakeAwayOrderWithLines {
  const TakeAwayOrderWithLines({required this.order, required this.lines});

  final TakeAwayOrder order;
  final List<TakeAwayOrderLineWithItem> lines;
}

class ReceiptLineWithReceipt {
  const ReceiptLineWithReceipt({required this.line, required this.receipt});

  final ReceiptLine line;
  final Receipt receipt;
}
