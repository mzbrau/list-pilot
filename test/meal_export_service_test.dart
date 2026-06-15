import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/services/meal_export_service.dart';

void main() {
  test('buildMealExportPayload produces expected JSON structure', () {
    final payload = buildMealExportPayload(
      MealExportData(
        meals: const [
          MealExportMeal(
            displayName: 'Chicken stir fry',
            notes: 'Quick weeknight meal',
            portions: 4,
            recipeLink: 'https://example.com/recipe',
            ingredients: [
              MealExportIngredient(
                displayName: 'Chicken breast',
                addToShoppingList: true,
              ),
              MealExportIngredient(
                displayName: 'Salt',
                addToShoppingList: false,
              ),
            ],
          ),
        ],
        checkOffHistory: [
          MealExportCheckOff(
            displayName: 'Chicken stir fry',
            checkedAt: DateTime.utc(2026, 6, 10, 18, 30),
          ),
        ],
      ),
    );

    expect(payload['meals'], isA<List>());
    expect(payload['checkOffHistory'], isA<List>());

    final meals = payload['meals'] as List;
    expect(meals, hasLength(1));
    expect(meals.first['displayName'], 'Chicken stir fry');
    expect(meals.first['portions'], 4);
    expect(meals.first['notes'], 'Quick weeknight meal');
    expect(meals.first['recipeLink'], 'https://example.com/recipe');

    final ingredients = meals.first['ingredients'] as List;
    expect(ingredients, hasLength(2));
    expect(ingredients.first['addToShoppingList'], isTrue);
    expect(ingredients.last['addToShoppingList'], isFalse);

    final history = payload['checkOffHistory'] as List;
    expect(history, hasLength(1));
    expect(history.first['displayName'], 'Chicken stir fry');
    expect(history.first['checkedAt'], isA<String>());
    expect(payload['exportedAt'], isA<String>());
  });
}
