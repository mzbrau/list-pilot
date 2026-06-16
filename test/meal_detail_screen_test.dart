import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/services/meal_photo_service.dart';
import 'package:list_pilot/features/meal_planning/meal_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Meal detail shows tabs and toggles edit mode', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final mealRepo = MealRepository(db);
    final catalogRepo = CatalogRepository(db);

    final meal = await mealRepo.createMeal(
      displayName: 'Test Meal',
      ingredients: ['Salt'],
      steps: ['Cook it'],
      tags: ['Dinner'],
      notes: 'Yummy',
    );

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        mealRepositoryProvider.overrideWithValue(mealRepo),
        mealPhotoServiceProvider.overrideWithValue(MealPhotoService(mealRepo)),
        catalogRepositoryProvider.overrideWithValue(catalogRepo),
        appInitProvider.overrideWith((ref) async {}),
        lastEatenDateProvider.overrideWith((ref, mealId) async => null),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: MealDetailScreen(mealId: meal.id),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Meal'), findsWidgets);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Salt'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Other'));
    await tester.pumpAndSettle();
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Yummy'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Steps'));
    await tester.pumpAndSettle();
    expect(find.text('Cook it'), findsOneWidget);
  });
}
