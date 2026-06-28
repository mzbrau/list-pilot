import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/services/ingredient_catalog_matcher.dart';
import 'package:list_pilot/data/services/ingredient_parser_service.dart';
import 'package:list_pilot/data/services/recipe_page_import_service.dart';
import 'package:list_pilot/features/meal_manager/meal_import_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('import preview renders after successful extract import',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});

    const html = '''
    <html><head><script type="application/ld+json">
    {"@type":"Recipe","name":"Test Soup","recipeIngredient":["2 cups stock"],"recipeInstructions":["Simmer"]}
    </script></head></html>
    ''';

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final mealRepo = MealRepository(db);
    final catalogRepo = CatalogRepository(db);
    final importService = RecipePageImportService(
      pageHtmlFetcher: (_) async => html,
    );

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
        recipePageImportServiceProvider.overrideWithValue(importService),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/import',
      routes: [
        GoRoute(
          path: '/import',
          builder: (context, state) => const MealImportScreen(
            mode: MealImportMode.extract,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Import recipe'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'https://example.com/recipe');
    await tester.tap(find.text('Import'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Needs review before save'), findsOneWidget);
    expect(find.text('Test Soup'), findsOneWidget);
  });
}
