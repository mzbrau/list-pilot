import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:list_pilot/core/constants/app_constants.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/repositories/learning_repository.dart';
import 'package:list_pilot/data/repositories/list_repository.dart';
import 'package:list_pilot/data/repositories/shop_stats_repository.dart';
import 'package:list_pilot/features/item_detail/item_detail_screen.dart';
import 'package:list_pilot/features/shop_stats/widgets/shop_stats_ticker.dart';
import 'package:list_pilot/features/shopping_list/shopping_list_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Shopping list shows AppBar title, count, back button, and item navigation',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'dairy',
            name: 'Dairy',
            sortOrder: 0,
          ),
        );

    final catalogId = await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'milk',
            displayName: 'Milk',
            categoryId: 'dairy',
            createdAt: DateTime.now(),
          ),
        );

    final listId = await db.into(db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            name: 'Supermarket',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    final now = DateTime.now();
    await db.batch((batch) {
      batch.insert(
        db.listItems,
        ListItemsCompanion.insert(
          listId: listId,
          catalogItemId: Value(catalogId),
          displayName: 'Milk',
          categoryId: 'dairy',
          addedAt: now,
        ),
      );
      batch.insert(
        db.listItems,
        ListItemsCompanion.insert(
          listId: listId,
          catalogItemId: Value(catalogId),
          displayName: 'Cheese',
          categoryId: 'dairy',
          addedAt: now,
        ),
      );
      batch.insert(
        db.listItems,
        ListItemsCompanion.insert(
          listId: listId,
          catalogItemId: Value(catalogId),
          displayName: 'Yogurt',
          categoryId: 'dairy',
          isCompleted: const Value(true),
          completedAt: Value(now),
          addedAt: now,
        ),
      );
    });

    final catalogRepo = CatalogRepository(db);
    final learningRepo = LearningRepository(db);
    final shopStatsRepo = ShopStatsRepository(db);
    final listRepo = ListRepository(db, catalogRepo, learningRepo, shopStatsRepo);

    final overrides = [
      databaseProvider.overrideWithValue(db),
      catalogRepositoryProvider.overrideWithValue(catalogRepo),
      learningRepositoryProvider.overrideWithValue(learningRepo),
      listRepositoryProvider.overrideWithValue(listRepo),
      appInitProvider.overrideWith((ref) async {}),
    ];

    late GoRouter router;
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
        GoRoute(
          path: '/list/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ShoppingListScreen(listId: id);
          },
          routes: [
            GoRoute(
              path: 'item/:itemId',
              builder: (context, state) {
                final listRouteId = int.parse(state.pathParameters['id']!);
                final itemId = int.parse(state.pathParameters['itemId']!);
                return ItemDetailScreen(listId: listRouteId, itemId: itemId);
              },
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.push('/list/$listId');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Supermarket'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('Dairy (2)'), findsOneWidget);
    expect(find.byType(BackButtonIcon), findsOneWidget);

    await tester.tap(find.text('Milk'));
    await tester.pumpAndSettle();

    expect(find.text('Item details'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await db.close();
    await tester.pump();
  });

  testWidgets('Shopping list back button returns home when stack has no parent route',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    final listId = await db.into(db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            name: 'Orphaned list',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    final catalogRepo = CatalogRepository(db);
    final learningRepo = LearningRepository(db);
    final shopStatsRepo = ShopStatsRepository(db);
    final listRepo = ListRepository(db, catalogRepo, learningRepo, shopStatsRepo);

    late GoRouter router;
    router = GoRouter(
      initialLocation: '/list/$listId',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
        GoRoute(
          path: '/list/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ShoppingListScreen(listId: id);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          catalogRepositoryProvider.overrideWithValue(catalogRepo),
          learningRepositoryProvider.overrideWithValue(learningRepo),
          listRepositoryProvider.overrideWithValue(listRepo),
          appInitProvider.overrideWith((ref) async {}),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orphaned list'), findsOneWidget);
    expect(find.byType(BackButtonIcon), findsOneWidget);

    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Orphaned list'), findsNothing);

    await db.close();
  });

  testWidgets('Shop stats ticker shows when enabled and shop is active',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.shopStatsEnabledKey: true,
    });

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final startedAt = DateTime.now().subtract(const Duration(minutes: 5));

    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'dairy',
            name: 'Dairy',
            sortOrder: 0,
          ),
        );

    final catalogId = await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'milk',
            displayName: 'Milk',
            categoryId: 'dairy',
            createdAt: DateTime.now(),
          ),
        );

    final listId = await db.into(db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            name: 'Supermarket',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            activeShopStartedAt: Value(startedAt),
          ),
        );

    final now = DateTime.now();
    await db.batch((batch) {
      batch.insert(
        db.listItems,
        ListItemsCompanion.insert(
          listId: listId,
          catalogItemId: Value(catalogId),
          displayName: 'Milk',
          categoryId: 'dairy',
          addedAt: now,
        ),
      );
      batch.insert(
        db.listItems,
        ListItemsCompanion.insert(
          listId: listId,
          catalogItemId: Value(catalogId),
          displayName: 'Cheese',
          categoryId: 'dairy',
          isCompleted: const Value(true),
          completedAt: Value(now),
          addedAt: now,
        ),
      );
    });

    final catalogRepo = CatalogRepository(db);
    final learningRepo = LearningRepository(db);
    final shopStatsRepo = ShopStatsRepository(db);
    final listRepo = ListRepository(db, catalogRepo, learningRepo, shopStatsRepo);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          catalogRepositoryProvider.overrideWithValue(catalogRepo),
          learningRepositoryProvider.overrideWithValue(learningRepo),
          listRepositoryProvider.overrideWithValue(listRepo),
          shopStatsRepositoryProvider.overrideWithValue(shopStatsRepo),
          appInitProvider.overrideWith((ref) async {}),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => ShoppingListScreen(listId: listId),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ShopStatsTicker), findsOneWidget);
    expect(find.textContaining('vs avg'), findsOneWidget);

    await db.close();
  });

  testWidgets('Shop stats ticker hidden when feature disabled', (tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.shopStatsEnabledKey: false,
    });

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final startedAt = DateTime.now().subtract(const Duration(minutes: 5));

    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'dairy',
            name: 'Dairy',
            sortOrder: 0,
          ),
        );

    final catalogId = await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'milk',
            displayName: 'Milk',
            categoryId: 'dairy',
            createdAt: DateTime.now(),
          ),
        );

    final listId = await db.into(db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            name: 'Supermarket',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            activeShopStartedAt: Value(startedAt),
          ),
        );

    final now = DateTime.now();
    await db.into(db.listItems).insert(
          ListItemsCompanion.insert(
            listId: listId,
            catalogItemId: Value(catalogId),
            displayName: 'Milk',
            categoryId: 'dairy',
            addedAt: now,
          ),
        );

    final catalogRepo = CatalogRepository(db);
    final learningRepo = LearningRepository(db);
    final shopStatsRepo = ShopStatsRepository(db);
    final listRepo = ListRepository(db, catalogRepo, learningRepo, shopStatsRepo);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          catalogRepositoryProvider.overrideWithValue(catalogRepo),
          learningRepositoryProvider.overrideWithValue(learningRepo),
          listRepositoryProvider.overrideWithValue(listRepo),
          shopStatsRepositoryProvider.overrideWithValue(shopStatsRepo),
          appInitProvider.overrideWith((ref) async {}),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => ShoppingListScreen(listId: listId),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ShopStatsTicker), findsNothing);

    await db.close();
  });
}
