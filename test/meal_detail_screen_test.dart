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
import 'package:list_pilot/features/meal_planning/widgets/meal_detail_other_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MealDetailOtherTab.openRecipeLink', () {
    test('normalizeRecipeLinkUri prepends https when scheme is missing', () {
      final uri = MealDetailOtherTab.normalizeRecipeLinkUri('example.com/recipe');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'https');
      expect(uri.host, 'example.com');
      expect(uri.path, '/recipe');
    });

    test('normalizeRecipeLinkUri preserves existing scheme', () {
      final uri =
          MealDetailOtherTab.normalizeRecipeLinkUri('https://example.com/a');
      expect(uri, isNotNull);
      expect(uri!.toString(), 'https://example.com/a');
    });

    test('normalizeRecipeLinkUri returns null for empty input', () {
      expect(MealDetailOtherTab.normalizeRecipeLinkUri(''), isNull);
      expect(MealDetailOtherTab.normalizeRecipeLinkUri('   '), isNull);
    });
  });

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

    final mealTags = await mealRepo.getTagsForMeal(meal.id);
    expect(mealTags.map((t) => t.displayName), contains('Dinner'));

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

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Test Meal'), findsWidgets);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Salt'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Other'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Recipe link'), findsOneWidget);
    expect(find.text('Yummy'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Steps'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Cook it'), findsOneWidget);

    final stepField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Step 1',
    );
    await tester.enterText(stepField, 'Simmer gently');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Simmer gently'), findsOneWidget);
    expect(find.text('Cook it'), findsNothing);
  });
}
