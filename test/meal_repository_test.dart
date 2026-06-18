import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/services/ingredient_catalog_matcher.dart';

void main() {
  late AppDatabase db;
  late MealRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MealRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('getOrCreateMeal deduplicates by normalized name', () async {
    final first = await repo.getOrCreateMeal(displayName: 'Chicken Stir Fry');
    final second = await repo.getOrCreateMeal(displayName: 'chicken stir fry');

    expect(first.id, second.id);
    expect(first.isUserAdded, isTrue);
  });

  test('addMealToPlan and watchPlanItems', () async {
    final meal = await repo.getOrCreateMeal(displayName: 'Pasta');
    await repo.addMealToPlan(meal.id);

    final items = await repo.watchPlanItems().first;
    expect(items, hasLength(1));
    expect(items.first.meal.displayName, 'Pasta');
    expect(items.first.planItem.isCompleted, isFalse);
  });

  test('setPlanItemCompleted records check-off history', () async {
    final meal = await repo.getOrCreateMeal(displayName: 'Salad');
    final planItemId = await repo.addMealToPlan(meal.id);

    await repo.setPlanItemCompleted(planItemId, true);

    final items = await repo.watchPlanItems().first;
    expect(items.first.planItem.isCompleted, isTrue);
    expect(items.first.planItem.completedAt, isNotNull);

    final lastEaten = await repo.getLastEatenDate(meal.id);
    expect(lastEaten, isNotNull);

    final events = await repo.getCheckOffEventsInRange(
      DateTime(2020),
      DateTime(2030),
    );
    expect(events, hasLength(1));
    expect(events.first.mealId, meal.id);
  });

  test('unchecking plan item preserves check-off history', () async {
    final meal = await repo.getOrCreateMeal(displayName: 'Soup');
    final planItemId = await repo.addMealToPlan(meal.id);

    await repo.setPlanItemCompleted(planItemId, true);
    await repo.setPlanItemCompleted(planItemId, false);

    final items = await repo.watchPlanItems().first;
    expect(items.first.planItem.isCompleted, isFalse);

    final events = await repo.getCheckOffEventsInRange(
      DateTime(2020),
      DateTime(2030),
    );
    expect(events, hasLength(1));
  });

  test('ingredient CRUD and addToShoppingList flag', () async {
    final meal = await repo.getOrCreateMeal(displayName: 'Tacos');
    final ingredientId = await repo.addIngredient(
      mealId: meal.id,
      displayName: 'Salt',
      addToShoppingList: false,
    );

    var ingredients = await repo.getIngredientsForMeal(meal.id);
    expect(ingredients, hasLength(1));
    expect(ingredients.first.addToShoppingList, isFalse);

    await repo.updateIngredient(id: ingredientId, addToShoppingList: true);
    ingredients = await repo.getIngredientsForMeal(meal.id);
    expect(ingredients.first.addToShoppingList, isTrue);

    await repo.deleteIngredient(ingredientId);
    ingredients = await repo.getIngredientsForMeal(meal.id);
    expect(ingredients, isEmpty);
  });

  test('searchMeals uses prefix match', () async {
    await repo.getOrCreateMeal(displayName: 'Chicken Curry');
    await repo.getOrCreateMeal(displayName: 'Beef Stew');

    final results = await repo.searchMeals('chi');
    expect(results, hasLength(1));
    expect(results.first.displayName, 'Chicken Curry');
  });

  test('getAllMealsForExport includes meals and history', () async {
    final meal = await repo.getOrCreateMeal(displayName: 'Risotto');
    await repo.addIngredient(
      mealId: meal.id,
      displayName: 'Rice',
      addToShoppingList: true,
    );
    final planItemId = await repo.addMealToPlan(meal.id);
    await repo.setPlanItemCompleted(planItemId, true);

    final export = await repo.getAllMealsForExport();
    expect(export.meals, hasLength(1));
    expect(export.meals.first.displayName, 'Risotto');
    expect(export.meals.first.ingredients, hasLength(1));
    expect(export.checkOffHistory, hasLength(1));
    expect(export.checkOffHistory.first.displayName, 'Risotto');
  });

  test('steps CRUD and reorder', () async {
    final meal = await repo.createMeal(
      displayName: 'Pancakes',
      steps: ['Mix batter', 'Cook'],
    );

    var steps = await repo.getStepsForMeal(meal.id);
    expect(steps, hasLength(2));
    expect(steps.first.instruction, 'Mix batter');

    await repo.updateStep(id: steps.first.id, instruction: 'Mix dry ingredients');
    steps = await repo.getStepsForMeal(meal.id);
    expect(steps.first.instruction, 'Mix dry ingredients');

    await repo.reorderSteps(meal.id, [steps.last.id, steps.first.id]);
    steps = await repo.getStepsForMeal(meal.id);
    expect(steps.first.instruction, 'Cook');

    await repo.deleteStep(steps.first.id);
    steps = await repo.getStepsForMeal(meal.id);
    expect(steps, hasLength(1));
  });

  test('tags upsert and searchMealsWithTags', () async {
    final meal = await repo.createMeal(
      displayName: 'Roast Chicken',
      tags: ['Dinner', 'Chicken'],
    );

    final tags = await repo.getTagsForMeal(meal.id);
    expect(tags.map((t) => t.displayName), containsAll(['Dinner', 'Chicken']));

    await repo.setMealTags(meal.id, ['Dinner', 'Sunday']);
    final updated = await repo.getTagsForMeal(meal.id);
    expect(updated.map((t) => t.displayName), containsAll(['Dinner', 'Sunday']));
    expect(updated.map((t) => t.displayName), isNot(contains('Chicken')));

    final byTag = await repo.searchMealsWithTags('din');
    expect(byTag.map((m) => m.displayName), contains('Roast Chicken'));

    final byName = await repo.searchMealsWithTags('roast');
    expect(byName, hasLength(1));
  });

  test('searchMealsWithTags matches substring in name', () async {
    await repo.createMeal(displayName: 'Chicken Pie');

    final results = await repo.searchMealsWithTags('pie');
    expect(results, hasLength(1));
    expect(results.first.displayName, 'Chicken Pie');
  });

  test('searchMealsWithTags ranks prefix name matches first', () async {
    await repo.createMeal(displayName: 'Chicken Pie');
    await repo.createMeal(displayName: 'Apple Chicken');

    final results = await repo.searchMealsWithTags('chicken');
    expect(results, hasLength(2));
    expect(results.first.displayName, 'Chicken Pie');
    expect(results.last.displayName, 'Apple Chicken');
  });

  test('searchMealsWithTags matches substring in tags', () async {
    await repo.createMeal(
      displayName: 'Roast Beef',
      tags: ['Sunday Roast'],
    );

    final results = await repo.searchMealsWithTags('day');
    expect(results.map((m) => m.displayName), contains('Roast Beef'));
  });

  test('deleteMeal cascades steps and tags', () async {
    final meal = await repo.createMeal(
      displayName: 'Temp Meal',
      steps: ['Step 1'],
      tags: ['Test'],
    );
    await repo.deleteMeal(meal.id);

    final steps = await repo.getStepsForMeal(meal.id);
    final tags = await repo.getTagsForMeal(meal.id);
    expect(steps, isEmpty);
    expect(tags, isEmpty);
  });

  test('updatePlanItemScale persists scale factor', () async {
    final meal = await repo.getOrCreateMeal(displayName: 'Stew');
    final planItemId = await repo.addMealToPlan(meal.id);

    await repo.updatePlanItemScale(planItemId, 1.5);

    final items = await repo.watchPlanItems().first;
    expect(items.first.planItem.scaleFactor, 1.5);
  });

  test('createMeal with structured ingredients', () async {
    final meal = await repo.createMeal(
      displayName: 'Structured Recipe',
      ingredients: [
        const MealIngredientInput(
          displayName: 'Potatoes',
          quantityValue: 750,
          quantityUnit: 'g',
        ),
      ],
    );

    final ingredients = await repo.getIngredientsForMeal(meal.id);
    expect(ingredients, hasLength(1));
    expect(ingredients.first.displayName, 'Potatoes');
    expect(ingredients.first.quantityValue, 750);
    expect(ingredients.first.quantityUnit, 'g');
  });

  test('createMeal with full data', () async {
    final meal = await repo.createMeal(
      displayName: 'Full Recipe',
      notes: 'Tasty',
      portions: 2,
      recipeLink: 'https://example.com',
      ingredients: [
        const MealIngredientInput(displayName: 'Flour'),
        const MealIngredientInput(displayName: 'Eggs'),
      ],
      steps: ['Bake'],
      tags: ['Dessert'],
    );

    expect(meal.displayName, 'Full Recipe');
    expect(meal.portions, 2);
    expect((await repo.getIngredientsForMeal(meal.id)), hasLength(2));
    expect((await repo.getStepsForMeal(meal.id)), hasLength(1));
    expect((await repo.getTagsForMeal(meal.id)), hasLength(1));
  });
}
