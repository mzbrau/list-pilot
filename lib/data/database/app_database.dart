import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Categories,
  CatalogItems,
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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

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

  Future<List<Meal>> searchMeals(String query, {int limit = 8}) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return (select(meals)
            ..orderBy([(t) => OrderingTerm.asc(t.displayName)])
            ..limit(limit))
          .get();
    }
    return (select(meals)
          ..where((t) => t.name.like('$normalized%'))
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)])
          ..limit(limit))
        .get();
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
