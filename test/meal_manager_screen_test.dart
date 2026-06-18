import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/services/meal_photo_service.dart';
import 'package:list_pilot/features/meal_manager/meal_manager_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpManager(
    WidgetTester tester, {
    required AppDatabase db,
    required MealRepository mealRepo,
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    addTearDown(() async => db.close());

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        mealRepositoryProvider.overrideWithValue(mealRepo),
        mealPhotoServiceProvider.overrideWithValue(MealPhotoService(mealRepo)),
        appInitProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MealManagerScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Meal manager shows meals and filters', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final mealRepo = MealRepository(db);

    await mealRepo.createMeal(
      displayName: 'Chicken Pie',
      tags: ['Dinner'],
    );
    await mealRepo.createMeal(displayName: 'Fruit Salad', tags: ['Dessert']);

    await pumpManager(tester, db: db, mealRepo: mealRepo);

    expect(find.text('Meal Manager'), findsOneWidget);
    expect(find.text('Chicken Pie'), findsOneWidget);
    expect(find.text('Fruit Salad'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'chicken');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Chicken Pie'), findsOneWidget);
    expect(find.text('Fruit Salad'), findsNothing);
  });

  testWidgets('FAB sheet shows code import without AI config', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final mealRepo = MealRepository(db);

    await pumpManager(tester, db: db, mealRepo: mealRepo);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create manually'), findsOneWidget);
    expect(find.text('Import from webpage'), findsOneWidget);
    expect(find.text('Import with AI'), findsNothing);
  });

  testWidgets('FAB sheet shows AI import when configured', (tester) async {
    SharedPreferences.setMockInitialValues({
      'ai_api_uri': 'https://api.example.com/v1',
      'ai_api_key': 'key',
      'ai_model_name': 'model',
    });

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final mealRepo = MealRepository(db);
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        mealRepositoryProvider.overrideWithValue(mealRepo),
        mealPhotoServiceProvider.overrideWithValue(MealPhotoService(mealRepo)),
        appInitProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MealManagerScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Import from webpage'), findsOneWidget);
    expect(find.text('Import with AI'), findsOneWidget);
  });
}
