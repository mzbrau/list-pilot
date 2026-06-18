import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/core/constants/app_constants.dart';
import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/services/ingredient_catalog_matcher.dart';
import 'package:list_pilot/data/services/ingredient_parser_service.dart';
import 'package:list_pilot/features/meal_planning/widgets/meal_ingredient_edit_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MealIngredientEditSheet saves updated quantity, unit, and catalog',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final mealRepo = MealRepository(db);
    final catalogRepo = CatalogRepository(db);
    final chickenBreast = await catalogRepo.getOrCreate(
      displayName: 'Chicken Breast',
      categoryId: 'meat',
      isUserAdded: true,
    );

    final meal = await mealRepo.createMeal(
      displayName: 'Roast Dinner',
      ingredients: [
        const MealIngredientInput(
          displayName: 'Chicken',
          quantityValue: 1.34,
          quantityUnit: 'count',
        ),
      ],
    );
    final ingredient = (await mealRepo.getIngredientsForMeal(meal.id)).single;

    final container = ProviderContainer(
      overrides: [
        appInitProvider.overrideWith((ref) async {}),
        databaseProvider.overrideWithValue(db),
        mealRepositoryProvider.overrideWithValue(mealRepo),
        catalogRepositoryProvider.overrideWithValue(catalogRepo),
        ingredientCatalogMatcherProvider.overrideWithValue(
          IngredientCatalogMatcher(
            catalogRepo,
            const IngredientParserService(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return FilledButton(
                  onPressed: () {
                    MealIngredientEditSheet.show(
                      context,
                      ingredient: ingredient,
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Edit ingredient'), findsOneWidget);
    expect(find.text('Original: ×1.34 Chicken'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '1');
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(QuantityUnits.label(QuantityUnits.kg)).last,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Ingredient name'),
      'Chicken Breast',
    );
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Chicken Breast').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final updated = (await mealRepo.getIngredientsForMeal(meal.id)).single;
    expect(updated.displayName, chickenBreast.displayName);
    expect(updated.quantityValue, 1);
    expect(updated.quantityUnit, 'kg');
    expect(updated.catalogItemId, chickenBreast.id);
  });
}
