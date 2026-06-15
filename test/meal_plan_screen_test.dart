import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/repositories/learning_repository.dart';
import 'package:list_pilot/data/repositories/list_repository.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/repositories/shop_stats_repository.dart';
import 'package:list_pilot/data/services/meal_export_service.dart';
import 'package:list_pilot/data/services/meal_photo_service.dart';
import 'package:list_pilot/features/meal_planning/meal_plan_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Meal plan screen shows meal and last eaten info', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final mealRepo = MealRepository(db);

    final meal = await mealRepo.getOrCreateMeal(displayName: 'Spaghetti');
    await mealRepo.addMealToPlan(meal.id);
    final planItemId = await mealRepo.addMealToPlan(meal.id);
    await mealRepo.setPlanItemCompleted(planItemId, true);

    final catalogRepo = CatalogRepository(db);
    final learningRepo = LearningRepository(db);
    final shopStatsRepo = ShopStatsRepository(db);
    final listRepo = ListRepository(
      db,
      catalogRepo,
      learningRepo,
      shopStatsRepo,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          mealRepositoryProvider.overrideWithValue(mealRepo),
          mealPhotoServiceProvider.overrideWithValue(MealPhotoService(mealRepo)),
          mealExportServiceProvider.overrideWithValue(MealExportService(mealRepo)),
          catalogRepositoryProvider.overrideWithValue(catalogRepo),
          listRepositoryProvider.overrideWithValue(listRepo),
          appInitProvider.overrideWith((ref) async {}),
        ],
        child: const MaterialApp(
          home: MealPlanScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Meal Planning'), findsOneWidget);
    expect(find.text('Spaghetti'), findsWidgets);
    expect(find.textContaining('Last eaten'), findsWidgets);
    expect(find.textContaining('servings'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await db.close();
    await tester.pump();
  });
}
