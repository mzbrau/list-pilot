import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/repositories/learning_repository.dart';
import 'package:list_pilot/data/repositories/list_repository.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/repositories/shop_stats_repository.dart';
import 'package:list_pilot/features/lists/widgets/quick_list_switcher.dart';
import 'package:list_pilot/features/meal_manager/meal_manager_screen.dart';
import 'package:list_pilot/features/meal_planning/meal_plan_screen.dart';
import 'package:list_pilot/features/shopping_list/shopping_list_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuickListSwitcher visibility', () {
    late AppDatabase db;
    late ListRepository listRepo;
    late int defaultListId;
    late int otherListId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      final catalogRepo = CatalogRepository(db);
      listRepo = ListRepository(
        db,
        catalogRepo,
        LearningRepository(db),
        ShopStatsRepository(db),
      );
      defaultListId = await listRepo.createList('Groceries');
      otherListId = await listRepo.createList('Other');
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> pumpSwitcher(
      WidgetTester tester, {
      required QuickListDestination current,
      int? listId,
      bool mealManagerEnabled = true,
      bool mealPlanningEnabled = true,
      int? configuredDefaultListId,
    }) async {
      SharedPreferences.setMockInitialValues({
        'meal_manager_enabled': mealManagerEnabled,
        'meal_planning_enabled': mealPlanningEnabled,
        if (configuredDefaultListId != null)
          'default_shopping_list_id': configuredDefaultListId,
      });

      final container = ProviderContainer(
        overrides: [
          appInitProvider.overrideWith((ref) async {}),
          databaseProvider.overrideWithValue(db),
          listRepositoryProvider.overrideWithValue(listRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appInitProvider.future);
      await container.read(shoppingListsProvider.stream).first;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: QuickListSwitcher(
                current: current,
                listId: listId,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('hidden on non-default shopping list', (tester) async {
      await pumpSwitcher(
        tester,
        current: QuickListDestination.shopping,
        listId: otherListId,
      );

      expect(find.text('Shopping'), findsNothing);
      expect(find.text('Planning'), findsNothing);
      expect(find.text('Recipes'), findsNothing);
    });

    testWidgets('hidden on default shopping list when both meal features disabled',
        (tester) async {
      await pumpSwitcher(
        tester,
        current: QuickListDestination.shopping,
        listId: defaultListId,
        configuredDefaultListId: defaultListId,
        mealManagerEnabled: false,
        mealPlanningEnabled: false,
      );

      expect(find.text('Shopping'), findsNothing);
      expect(find.text('Planning'), findsNothing);
      expect(find.text('Recipes'), findsNothing);
    });

    testWidgets('visible on default shopping list when meal features enabled',
        (tester) async {
      await pumpSwitcher(
        tester,
        current: QuickListDestination.shopping,
        listId: defaultListId,
        configuredDefaultListId: defaultListId,
      );

      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Recipes'), findsOneWidget);
    });

    testWidgets('omits disabled meal segments on meal planning screen',
        (tester) async {
      await pumpSwitcher(
        tester,
        current: QuickListDestination.planning,
        mealManagerEnabled: false,
        mealPlanningEnabled: true,
      );

      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Recipes'), findsNothing);
    });
  });

  testWidgets('tapping Planning navigates to /meals', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async => db.close());

    final catalogRepo = CatalogRepository(db);
    final listRepo = ListRepository(
      db,
      catalogRepo,
      LearningRepository(db),
      ShopStatsRepository(db),
    );
    await listRepo.createList('Groceries');

    final mealRepo = MealRepository(db);
    final router = GoRouter(
      initialLocation: '/meal-manager',
      routes: [
        GoRoute(
          path: '/meal-manager',
          builder: (context, state) => const MealManagerScreen(),
        ),
        GoRoute(
          path: '/meals',
          builder: (context, state) => const MealPlanScreen(),
        ),
        GoRoute(
          path: '/list/:id',
          builder: (context, state) => ShoppingListScreen(
            listId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    final container = ProviderContainer(
      overrides: [
        appInitProvider.overrideWith((ref) async {}),
        databaseProvider.overrideWithValue(db),
        listRepositoryProvider.overrideWithValue(listRepo),
        mealRepositoryProvider.overrideWithValue(mealRepo),
        appInitProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appInitProvider.future);
    await container.read(shoppingListsProvider.stream).first;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), '/meal-manager');

    await tester.tap(find.text('Planning'));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), '/meals');
    expect(find.text('Meal Planning'), findsOneWidget);
  });

  testWidgets('meal plan screen no longer shows Export meals menu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async => db.close());

    final mealRepo = MealRepository(db);
    final catalogRepo = CatalogRepository(db);
    final listRepo = ListRepository(
      db,
      catalogRepo,
      LearningRepository(db),
      ShopStatsRepository(db),
    );

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        mealRepositoryProvider.overrideWithValue(mealRepo),
        listRepositoryProvider.overrideWithValue(listRepo),
        appInitProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const MealPlanScreen(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meal Planning'), findsOneWidget);
    expect(find.text('Export meals'), findsNothing);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });
}
