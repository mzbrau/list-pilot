import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/item_detail/item_detail_screen.dart';
import '../features/lists/lists_overview_screen.dart';
import '../features/meal_manager/meal_import_screen.dart';
import '../features/meal_manager/meal_manager_screen.dart';
import '../features/meal_planning/meal_calendar_screen.dart';
import '../features/meal_planning/meal_detail_screen.dart';
import '../features/meal_planning/meal_plan_screen.dart';
import '../features/shop_stats/shop_stats_screen.dart';
import '../features/shopping_list/shopping_list_screen.dart';
import '../features/todo_list/todo_completed_history_screen.dart';
import '../features/todo_list/todo_list_screen.dart';
import '../features/todo_list/todo_task_detail_screen.dart';
import '../features/take_away/take_away_list_screen.dart';
import '../features/take_away/take_away_menu_import_screen.dart';
import '../features/take_away/take_away_menu_screen.dart';
import '../features/take_away/take_away_order_plan_screen.dart';
import '../features/receipts/receipts_list_screen.dart';
import '../features/receipts/receipt_detail_screen.dart';
import '../features/receipts/receipt_insights_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ListsOverviewScreen(),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const ShopStatsScreen(),
      ),
      GoRoute(
        path: '/meals',
        builder: (context, state) => const MealPlanScreen(),
        routes: [
          GoRoute(
            path: 'calendar',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const MealCalendarScreen(),
          ),
          GoRoute(
            path: ':mealId',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final mealId = int.parse(state.pathParameters['mealId']!);
              final initialEditMode = state.extra == true;
              return MealDetailScreen(
                mealId: mealId,
                initialEditMode: initialEditMode,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/meal-manager',
        builder: (context, state) => const MealManagerScreen(),
        routes: [
          GoRoute(
            path: 'import',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const MealImportScreen(),
            routes: [
              GoRoute(
                path: 'extract',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) =>
                    const MealImportScreen(mode: MealImportMode.extract),
              ),
              GoRoute(
                path: 'photo',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) =>
                    const MealImportScreen(mode: MealImportMode.photo),
              ),
            ],
          ),
          GoRoute(
            path: ':mealId',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final mealId = int.parse(state.pathParameters['mealId']!);
              final initialEditMode = state.extra == true;
              return MealDetailScreen(
                mealId: mealId,
                initialEditMode: initialEditMode,
              );
            },
          ),
        ],
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
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final listId = int.parse(state.pathParameters['id']!);
              final itemId = int.parse(state.pathParameters['itemId']!);
              return ItemDetailScreen(listId: listId, itemId: itemId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/todo/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TodoListScreen(listId: id);
        },
        routes: [
          GoRoute(
            path: 'history',
            builder: (context, state) {
              final listId = int.parse(state.pathParameters['id']!);
              return TodoCompletedHistoryScreen(listId: listId);
            },
          ),
          GoRoute(
            path: 'task/:taskId',
            builder: (context, state) {
              final listId = int.parse(state.pathParameters['id']!);
              final taskId = int.parse(state.pathParameters['taskId']!);
              return TodoTaskDetailScreen(listId: listId, taskId: taskId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/take-away/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TakeAwayListScreen(listId: id);
        },
        routes: [
          GoRoute(
            path: 'import',
            builder: (context, state) {
              final listId = int.parse(state.pathParameters['id']!);
              return TakeAwayMenuImportScreen(listId: listId);
            },
          ),
          GoRoute(
            path: 'menu/:menuId',
            builder: (context, state) {
              final listId = int.parse(state.pathParameters['id']!);
              final menuId = int.parse(state.pathParameters['menuId']!);
              return TakeAwayMenuScreen(listId: listId, menuId: menuId);
            },
            routes: [
              GoRoute(
                path: 'order',
                builder: (context, state) {
                  final listId = int.parse(state.pathParameters['id']!);
                  final menuId = int.parse(state.pathParameters['menuId']!);
                  return TakeAwayOrderPlanScreen(
                    listId: listId,
                    menuId: menuId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/receipts/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ReceiptsListScreen(listId: id);
        },
        routes: [
          GoRoute(
            path: 'insights',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final listId = int.parse(state.pathParameters['id']!);
              return ReceiptInsightsScreen(listId: listId);
            },
          ),
          GoRoute(
            path: 'receipt/:receiptId',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final listId = int.parse(state.pathParameters['id']!);
              final receiptId = int.parse(state.pathParameters['receiptId']!);
              return ReceiptDetailScreen(listId: listId, receiptId: receiptId);
            },
          ),
        ],
      ),
    ],
  );
});
