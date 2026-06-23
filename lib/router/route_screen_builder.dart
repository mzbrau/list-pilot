import 'package:flutter/material.dart';

import '../features/catalog/catalog_item_detail_screen.dart';
import '../features/catalog/catalog_screen.dart';
import '../features/item_detail/item_detail_screen.dart';
import '../features/lists/lists_overview_screen.dart';
import '../features/meal_manager/meal_import_screen.dart';
import '../features/meal_manager/meal_manager_screen.dart';
import '../features/meal_manager/paprika_import_screen.dart';
import '../data/services/meal_plan_ai_suggest_service.dart';
import '../features/meal_planning/ai_meal_suggest_results_screen.dart';
import '../features/meal_planning/meal_calendar_screen.dart';
import '../features/meal_planning/meal_detail_screen.dart';
import '../features/meal_planning/meal_plan_screen.dart';
import '../features/receipts/receipt_detail_screen.dart';
import '../features/receipts/receipt_insights_screen.dart';
import '../features/receipts/receipts_list_screen.dart';
import '../features/shop_stats/shop_stats_screen.dart';
import '../features/shopping_list/shopping_list_screen.dart';
import '../features/take_away/take_away_list_screen.dart';
import '../features/take_away/take_away_menu_import_screen.dart';
import '../features/take_away/take_away_menu_screen.dart';
import '../features/take_away/take_away_order_plan_screen.dart';
import '../features/todo_list/todo_completed_history_screen.dart';
import '../features/todo_list/todo_list_screen.dart';
import '../features/todo_list/todo_task_detail_screen.dart';

Widget buildScreenForLocation(String location, {Object? extra}) {
  final uri = Uri.parse(location);
  final segments = uri.pathSegments;

  if (uri.path == '/' || segments.isEmpty) {
    return const ListsOverviewScreen();
  }

  if (uri.path == '/stats') {
    return const ShopStatsScreen();
  }

  if (uri.path == '/catalog') {
    return const CatalogScreen();
  }

  if (segments.first == 'catalog' && segments.length == 2) {
    final itemId = int.parse(segments[1]);
    return CatalogItemDetailScreen(itemId: itemId);
  }

  if (segments.first == 'meals') {
    if (segments.length == 1) {
      return const MealPlanScreen();
    }
    if (segments.length == 2 && segments[1] == 'calendar') {
      return const MealCalendarScreen();
    }
    if (segments.length == 2 && segments[1] == 'suggest') {
      final options = extra as MealPlanAiSuggestOptions?;
      if (options == null) {
        return const MealPlanScreen();
      }
      return AiMealSuggestResultsScreen(options: options);
    }
    if (segments.length == 2) {
      final mealId = int.parse(segments[1]);
      return MealDetailScreen(
        mealId: mealId,
        initialEditMode: extra == true,
        fromMealManager: false,
      );
    }
  }

  if (segments.first == 'meal-manager') {
    if (segments.length == 1) {
      return const MealManagerScreen();
    }
    if (segments.length == 2 && segments[1] == 'import') {
      return const MealImportScreen();
    }
    if (segments.length == 3 && segments[1] == 'import') {
      if (segments[2] == 'extract') {
        return const MealImportScreen(mode: MealImportMode.extract);
      }
      if (segments[2] == 'photo') {
        return const MealImportScreen(mode: MealImportMode.photo);
      }
      if (segments[2] == 'paprika') {
        return const PaprikaImportScreen();
      }
    }
    if (segments.length == 2) {
      final mealId = int.parse(segments[1]);
      return MealDetailScreen(
        mealId: mealId,
        initialEditMode: extra == true,
        fromMealManager: true,
      );
    }
  }

  if (segments.first == 'list' && segments.length >= 2) {
    final listId = int.parse(segments[1]);
    if (segments.length == 2) {
      return ShoppingListScreen(listId: listId);
    }
    if (segments.length == 4 && segments[2] == 'item') {
      final itemId = int.parse(segments[3]);
      return ItemDetailScreen(listId: listId, itemId: itemId);
    }
  }

  if (segments.first == 'todo' && segments.length >= 2) {
    final listId = int.parse(segments[1]);
    if (segments.length == 2) {
      return TodoListScreen(listId: listId);
    }
    if (segments.length == 3 && segments[2] == 'history') {
      return TodoCompletedHistoryScreen(listId: listId);
    }
    if (segments.length == 4 && segments[2] == 'task') {
      final taskId = int.parse(segments[3]);
      return TodoTaskDetailScreen(listId: listId, taskId: taskId);
    }
  }

  if (segments.first == 'take-away' && segments.length >= 2) {
    final listId = int.parse(segments[1]);
    if (segments.length == 2) {
      return TakeAwayListScreen(listId: listId);
    }
    if (segments.length == 3 && segments[2] == 'import') {
      return TakeAwayMenuImportScreen(listId: listId);
    }
    if (segments.length == 4 && segments[2] == 'menu') {
      final menuId = int.parse(segments[3]);
      return TakeAwayMenuScreen(listId: listId, menuId: menuId);
    }
    if (segments.length == 6 &&
        segments[2] == 'menu' &&
        segments[4] == 'order') {
      final menuId = int.parse(segments[3]);
      return TakeAwayOrderPlanScreen(listId: listId, menuId: menuId);
    }
  }

  if (segments.first == 'receipts' && segments.length >= 2) {
    final listId = int.parse(segments[1]);
    if (segments.length == 2) {
      return ReceiptsListScreen(listId: listId);
    }
    if (segments.length == 3 && segments[2] == 'insights') {
      return ReceiptInsightsScreen(listId: listId);
    }
    if (segments.length == 4 && segments[2] == 'receipt') {
      final receiptId = int.parse(segments[3]);
      return ReceiptDetailScreen(listId: listId, receiptId: receiptId);
    }
  }

  return const ListsOverviewScreen();
}
