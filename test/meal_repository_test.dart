import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';

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
}
