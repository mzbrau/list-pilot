import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../services/ingredient_catalog_matcher.dart';

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
    required this.steps,
    required this.tags,
  });

  final String displayName;
  final String? notes;
  final int portions;
  final String? recipeLink;
  final List<MealExportIngredient> ingredients;
  final List<String> steps;
  final List<String> tags;
}

class MealExportIngredient {
  const MealExportIngredient({
    required this.displayName,
    required this.addToShoppingList,
    this.quantityValue,
    this.quantityUnit,
    this.catalogItemId,
  });

  final String displayName;
  final bool addToShoppingList;
  final double? quantityValue;
  final String? quantityUnit;
  final int? catalogItemId;
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
    final meal = await (_db.select(_db.meals)..where((t) => t.id.equals(mealId)))
        .getSingleOrNull();
    final scaleFactor = meal?.viewScaleFactor ?? 1.0;
    return _db.into(_db.mealPlanItems).insert(
          MealPlanItemsCompanion.insert(
            mealId: mealId,
            addedAt: DateTime.now(),
            scaleFactor: Value(scaleFactor),
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

  Future<void> updatePlanItemScale(int planItemId, double scaleFactor) async {
    final planItem = await (_db.select(_db.mealPlanItems)
          ..where((t) => t.id.equals(planItemId)))
        .getSingleOrNull();
    if (planItem == null) return;

    final clamped = scaleFactor.clamp(0.25, 10.0);
    await updateMealViewScale(planItem.mealId, clamped);
    await syncMealScaleToPlanItems(planItem.mealId, clamped);
  }

  Future<void> updateMealViewScale(int mealId, double scaleFactor) async {
    final clamped = scaleFactor.clamp(0.25, 10.0);
    await (_db.update(_db.meals)..where((t) => t.id.equals(mealId))).write(
      MealsCompanion(viewScaleFactor: Value(clamped)),
    );
  }

  Future<void> syncMealScaleToPlanItems(int mealId, double scaleFactor) async {
    final clamped = scaleFactor.clamp(0.25, 10.0);
    await (_db.update(_db.mealPlanItems)
          ..where((t) => t.mealId.equals(mealId)))
        .write(
      MealPlanItemsCompanion(scaleFactor: Value(clamped)),
    );
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
    await (_db.delete(_db.mealTagAssignments)
          ..where((t) => t.mealId.equals(mealId)))
        .go();
    await (_db.delete(_db.mealSteps)..where((t) => t.mealId.equals(mealId)))
        .go();
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

  Stream<List<Meal>> watchAllMeals() {
    return _db.watchAllMeals();
  }

  Future<List<Meal>> searchMealsWithTags(String query) {
    return _db.searchMealsWithTags(query);
  }

  Future<Meal> createMeal({
    required String displayName,
    String? notes,
    int portions = 4,
    String? recipeLink,
    List<MealIngredientInput> ingredients = const [],
    List<String> steps = const [],
    List<String> tags = const [],
    bool isUserAdded = true,
  }) async {
    final id = await _db.into(_db.meals).insert(
          MealsCompanion.insert(
            name: displayName.trim().toLowerCase(),
            displayName: displayName.trim(),
            notes: Value(notes),
            portions: Value(portions.clamp(1, 99)),
            recipeLink: Value(recipeLink),
            isUserAdded: Value(isUserAdded),
            createdAt: DateTime.now(),
          ),
        );

    for (final ingredient in ingredients) {
      final trimmed = ingredient.displayName.trim();
      if (trimmed.isEmpty) continue;
      await addIngredient(
        mealId: id,
        displayName: trimmed,
        catalogItemId: ingredient.catalogItemId,
        quantityValue: ingredient.quantityValue,
        quantityUnit: ingredient.quantityUnit,
        addToShoppingList: ingredient.addToShoppingList,
      );
    }

    await replaceSteps(id, steps);
    await setMealTags(id, tags);

    return (await (_db.select(_db.meals)..where((t) => t.id.equals(id)))
        .getSingle());
  }

  Future<void> replaceSteps(int mealId, List<String> instructions) async {
    await (_db.delete(_db.mealSteps)..where((t) => t.mealId.equals(mealId)))
        .go();
    var order = 0;
    for (final instruction in instructions) {
      final trimmed = instruction.trim();
      if (trimmed.isEmpty) continue;
      await _db.into(_db.mealSteps).insert(
            MealStepsCompanion.insert(
              mealId: mealId,
              stepOrder: order++,
              instruction: trimmed,
            ),
          );
    }
  }

  Future<int> addStep({
    required int mealId,
    required String instruction,
    int? stepOrder,
  }) async {
    final steps = await getStepsForMeal(mealId);
    final order = stepOrder ?? steps.length;
    return _db.into(_db.mealSteps).insert(
          MealStepsCompanion.insert(
            mealId: mealId,
            stepOrder: order,
            instruction: instruction.trim(),
          ),
        );
  }

  Future<void> updateStep({
    required int id,
    String? instruction,
    int? stepOrder,
  }) async {
    await (_db.update(_db.mealSteps)..where((t) => t.id.equals(id))).write(
      MealStepsCompanion(
        instruction:
            instruction != null ? Value(instruction.trim()) : const Value.absent(),
        stepOrder: stepOrder != null ? Value(stepOrder) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteStep(int id) async {
    await (_db.delete(_db.mealSteps)..where((t) => t.id.equals(id))).go();
  }

  Future<void> reorderSteps(int mealId, List<int> stepIdsInOrder) async {
    for (var i = 0; i < stepIdsInOrder.length; i++) {
      await updateStep(id: stepIdsInOrder[i], stepOrder: i);
    }
  }

  Future<List<MealStep>> getStepsForMeal(int mealId) {
    return _db.getStepsForMeal(mealId);
  }

  Stream<List<MealStep>> watchStepsForMeal(int mealId) {
    return _db.watchStepsForMeal(mealId);
  }

  Future<List<MealTag>> searchTags(String query, {int limit = 8}) {
    return _db.searchTags(query, limit: limit);
  }

  Future<List<MealTag>> getTagsForMeal(int mealId) {
    return _db.getTagsForMeal(mealId);
  }

  Stream<List<MealTag>> watchTagsForMeal(int mealId) {
    return _db.watchTagsForMeal(mealId);
  }

  Future<void> setMealTags(int mealId, List<String> tagNames) async {
    await (_db.delete(_db.mealTagAssignments)
          ..where((t) => t.mealId.equals(mealId)))
        .go();

    for (final raw in tagNames) {
      final display = raw.trim();
      if (display.isEmpty) continue;
      final normalized = display.toLowerCase();

      var tag = await (_db.select(_db.mealTags)
            ..where((t) => t.name.equals(normalized)))
          .getSingleOrNull();

      if (tag == null) {
        final tagId = await _db.into(_db.mealTags).insert(
              MealTagsCompanion.insert(
                name: normalized,
                displayName: display,
              ),
            );
        tag = await (_db.select(_db.mealTags)
              ..where((t) => t.id.equals(tagId)))
            .getSingle();
      }

      await _db.into(_db.mealTagAssignments).insert(
            MealTagAssignmentsCompanion.insert(
              mealId: mealId,
              tagId: tag.id,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
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
    double? quantityValue,
    String? quantityUnit,
    bool addToShoppingList = true,
  }) async {
    return _db.into(_db.mealIngredients).insert(
          MealIngredientsCompanion.insert(
            mealId: mealId,
            catalogItemId: Value(catalogItemId),
            displayName: displayName.trim(),
            quantityValue: quantityValue != null
                ? Value(quantityValue)
                : const Value.absent(),
            quantityUnit: quantityUnit != null
                ? Value(quantityUnit)
                : const Value.absent(),
            addToShoppingList: Value(addToShoppingList),
          ),
        );
  }

  Future<void> updateIngredient({
    required int id,
    String? displayName,
    int? catalogItemId,
    bool clearCatalogItem = false,
    double? quantityValue,
    String? quantityUnit,
    bool clearQuantity = false,
    bool? addToShoppingList,
  }) async {
    await (_db.update(_db.mealIngredients)..where((t) => t.id.equals(id))).write(
      MealIngredientsCompanion(
        displayName: displayName != null
            ? Value(displayName.trim())
            : const Value.absent(),
        catalogItemId: clearCatalogItem
            ? const Value(null)
            : catalogItemId != null
                ? Value(catalogItemId)
                : const Value.absent(),
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
      final steps = await getStepsForMeal(meal.id);
      final tags = await getTagsForMeal(meal.id);
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
                  quantityValue: i.quantityValue,
                  quantityUnit: i.quantityUnit,
                  catalogItemId: i.catalogItemId,
                ),
              )
              .toList(),
          steps: steps.map((s) => s.instruction).toList(),
          tags: tags.map((t) => t.displayName).toList(),
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
