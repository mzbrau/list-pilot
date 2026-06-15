import 'package:drift/drift.dart';

import '../database/app_database.dart';

class MealExportData {
  const MealExportData({
    required this.meals,
    required this.checkOffHistory,
  });

  final List<MealExportMeal> meals;
  final List<MealExportCheckOff> checkOffHistory;
}

class MealExportMeal {
  const MealExportMeal({
    required this.displayName,
    this.notes,
    required this.portions,
    this.recipeLink,
    required this.ingredients,
  });

  final String displayName;
  final String? notes;
  final int portions;
  final String? recipeLink;
  final List<MealExportIngredient> ingredients;
}

class MealExportIngredient {
  const MealExportIngredient({
    required this.displayName,
    required this.addToShoppingList,
  });

  final String displayName;
  final bool addToShoppingList;
}

class MealExportCheckOff {
  const MealExportCheckOff({
    required this.displayName,
    required this.checkedAt,
  });

  final String displayName;
  final DateTime checkedAt;
}

class MealRepository {
  MealRepository(this._db);

  final AppDatabase _db;

  Future<List<Meal>> searchMeals(String query, {int limit = 8}) {
    return _db.searchMeals(query, limit: limit);
  }

  Future<Meal?> findByName(String name) {
    return _db.findMealByName(name);
  }

  Future<Meal> getOrCreateMeal({
    required String displayName,
    bool isUserAdded = true,
  }) async {
    final existing = await findByName(displayName);
    if (existing != null) return existing;

    final id = await _db.into(_db.meals).insert(
          MealsCompanion.insert(
            name: displayName.trim().toLowerCase(),
            displayName: displayName.trim(),
            isUserAdded: Value(isUserAdded),
            createdAt: DateTime.now(),
          ),
        );

    return (await (_db.select(_db.meals)..where((t) => t.id.equals(id)))
        .getSingle());
  }

  Future<int> addMealToPlan(int mealId) async {
    return _db.into(_db.mealPlanItems).insert(
          MealPlanItemsCompanion.insert(
            mealId: mealId,
            addedAt: DateTime.now(),
          ),
        );
  }

  Future<void> setPlanItemCompleted(int planItemId, bool completed) async {
    final planItem = await (_db.select(_db.mealPlanItems)
          ..where((t) => t.id.equals(planItemId)))
        .getSingleOrNull();
    if (planItem == null) return;

    final now = DateTime.now();
    if (completed) {
      await (_db.update(_db.mealPlanItems)
            ..where((t) => t.id.equals(planItemId)))
          .write(
        MealPlanItemsCompanion(
          isCompleted: const Value(true),
          completedAt: Value(now),
        ),
      );
      await recordCheckOff(
        mealId: planItem.mealId,
        mealPlanItemId: planItemId,
        checkedAt: now,
      );
    } else {
      await (_db.update(_db.mealPlanItems)
            ..where((t) => t.id.equals(planItemId)))
          .write(
        const MealPlanItemsCompanion(
          isCompleted: Value(false),
          completedAt: Value(null),
        ),
      );
    }
  }

  Future<void> recordCheckOff({
    required int mealId,
    int? mealPlanItemId,
    DateTime? checkedAt,
  }) async {
    await _db.into(_db.mealCheckOffEvents).insert(
          MealCheckOffEventsCompanion.insert(
            mealId: mealId,
            mealPlanItemId: Value(mealPlanItemId),
            checkedAt: checkedAt ?? DateTime.now(),
          ),
        );
  }

  Future<void> updateMeal({
    required int id,
    String? displayName,
    String? photoPath,
    bool clearPhoto = false,
    String? notes,
    bool clearNotes = false,
    int? portions,
    String? recipeLink,
    bool clearRecipeLink = false,
  }) async {
    await (_db.update(_db.meals)..where((t) => t.id.equals(id))).write(
      MealsCompanion(
        name: displayName != null
            ? Value(displayName.trim().toLowerCase())
            : const Value.absent(),
        displayName:
            displayName != null ? Value(displayName.trim()) : const Value.absent(),
        photoPath: clearPhoto
            ? const Value(null)
            : photoPath != null
                ? Value(photoPath)
                : const Value.absent(),
        notes: clearNotes
            ? const Value(null)
            : notes != null
                ? Value(notes)
                : const Value.absent(),
        portions: portions != null ? Value(portions) : const Value.absent(),
        recipeLink: clearRecipeLink
            ? const Value(null)
            : recipeLink != null
                ? Value(recipeLink)
                : const Value.absent(),
      ),
    );
  }

  Future<void> deleteMealFromPlan(int planItemId) async {
    await (_db.delete(_db.mealPlanItems)
          ..where((t) => t.id.equals(planItemId)))
        .go();
  }

  Future<void> clearCompletedPlanItems() async {
    await (_db.delete(_db.mealPlanItems)
          ..where((t) => t.isCompleted.equals(true)))
        .go();
  }

  Future<void> deleteMeal(int mealId) async {
    await (_db.delete(_db.mealIngredients)
          ..where((t) => t.mealId.equals(mealId)))
        .go();
    await (_db.delete(_db.mealCheckOffEvents)
          ..where((t) => t.mealId.equals(mealId)))
        .go();
    await (_db.delete(_db.mealPlanItems)
          ..where((t) => t.mealId.equals(mealId)))
        .go();
    await (_db.delete(_db.meals)..where((t) => t.id.equals(mealId))).go();
  }

  Stream<List<MealPlanItemWithMeal>> watchPlanItems() {
    return _db.watchMealPlanItems();
  }

  Stream<Meal?> watchMeal(int mealId) {
    return (_db.select(_db.meals)..where((t) => t.id.equals(mealId)))
        .watchSingleOrNull();
  }

  Future<Meal?> getMealById(int id) {
    return _db.getMealById(id);
  }

  Future<DateTime?> getLastEatenDate(int mealId) {
    return _db.getLastEatenDate(mealId);
  }

  Future<List<MealIngredient>> getIngredientsForMeal(int mealId) {
    return _db.getIngredientsForMeal(mealId);
  }

  Stream<List<MealIngredient>> watchIngredientsForMeal(int mealId) {
    return _db.watchIngredientsForMeal(mealId);
  }

  Future<int> addIngredient({
    required int mealId,
    required String displayName,
    int? catalogItemId,
    bool addToShoppingList = true,
  }) async {
    return _db.into(_db.mealIngredients).insert(
          MealIngredientsCompanion.insert(
            mealId: mealId,
            catalogItemId: Value(catalogItemId),
            displayName: displayName.trim(),
            addToShoppingList: Value(addToShoppingList),
          ),
        );
  }

  Future<void> updateIngredient({
    required int id,
    bool? addToShoppingList,
  }) async {
    await (_db.update(_db.mealIngredients)..where((t) => t.id.equals(id))).write(
      MealIngredientsCompanion(
        addToShoppingList: addToShoppingList != null
            ? Value(addToShoppingList)
            : const Value.absent(),
      ),
    );
  }

  Future<void> deleteIngredient(int id) async {
    await (_db.delete(_db.mealIngredients)..where((t) => t.id.equals(id)))
        .go();
  }

  Stream<List<MealCheckOffEventWithMeal>> watchMealsEatenOnDate(DateTime date) {
    return _db.watchMealsEatenOnDate(date);
  }

  Future<List<MealCheckOffEvent>> getCheckOffEventsInRange(
    DateTime start,
    DateTime end,
  ) {
    return _db.getCheckOffEventsInRange(start, end);
  }

  Future<MealExportData> getAllMealsForExport() async {
    final allMeals = await (_db.select(_db.meals)
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
        .get();

    final meals = <MealExportMeal>[];
    for (final meal in allMeals) {
      final ingredients = await getIngredientsForMeal(meal.id);
      meals.add(
        MealExportMeal(
          displayName: meal.displayName,
          notes: meal.notes,
          portions: meal.portions,
          recipeLink: meal.recipeLink,
          ingredients: ingredients
              .map(
                (i) => MealExportIngredient(
                  displayName: i.displayName,
                  addToShoppingList: i.addToShoppingList,
                ),
              )
              .toList(),
        ),
      );
    }

    final events = await (_db.select(_db.mealCheckOffEvents)
          ..orderBy([(t) => OrderingTerm.asc(t.checkedAt)]))
        .get();

    final checkOffHistory = <MealExportCheckOff>[];
    for (final event in events) {
      final meal = await getMealById(event.mealId);
      if (meal == null) continue;
      checkOffHistory.add(
        MealExportCheckOff(
          displayName: meal.displayName,
          checkedAt: event.checkedAt,
        ),
      );
    }

    return MealExportData(meals: meals, checkOffHistory: checkOffHistory);
  }
}
