import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/learning_repository.dart';
import '../../data/repositories/list_repository.dart';
import '../../data/repositories/meal_repository.dart';
import '../../data/repositories/shop_stats_repository.dart';
import '../../data/seed/database_seeder.dart';
import '../../data/services/catalog_export_service.dart';
import '../../data/services/meal_export_service.dart';
import '../../data/services/meal_photo_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(databaseProvider));
});

final catalogExportServiceProvider = Provider<CatalogExportService>((ref) {
  return CatalogExportService(ref.watch(catalogRepositoryProvider));
});

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository(ref.watch(databaseProvider));
});

final mealPhotoServiceProvider = Provider<MealPhotoService>((ref) {
  return MealPhotoService(ref.watch(mealRepositoryProvider));
});

final mealExportServiceProvider = Provider<MealExportService>((ref) {
  return MealExportService(ref.watch(mealRepositoryProvider));
});

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepository(ref.watch(databaseProvider));
});

final shopStatsRepositoryProvider = Provider<ShopStatsRepository>((ref) {
  return ShopStatsRepository(ref.watch(databaseProvider));
});

final listRepositoryProvider = Provider<ListRepository>((ref) {
  return ListRepository(
    ref.watch(databaseProvider),
    ref.watch(catalogRepositoryProvider),
    ref.watch(learningRepositoryProvider),
    ref.watch(shopStatsRepositoryProvider),
  );
});

final databaseSeederProvider = Provider<DatabaseSeeder>((ref) {
  return DatabaseSeeder(ref.watch(databaseProvider));
});

final appInitProvider = FutureProvider<void>((ref) async {
  final seeder = ref.watch(databaseSeederProvider);
  await seeder.seedIfNeeded();
});

final appVersionProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

final shoppingListsProvider = StreamProvider<List<ShoppingList>>((ref) {
  ref.watch(appInitProvider);
  return ref.watch(listRepositoryProvider).watchAllLists();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  ref.watch(appInitProvider);
  return ref.watch(catalogRepositoryProvider).getCategories();
});

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(AppConstants.themeModeKey);
    if (value == 'light') state = ThemeMode.light;
    if (value == 'dark') state = ThemeMode.dark;
    if (value == 'system') state = ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final name = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(AppConstants.themeModeKey, name);
  }
}

final shopStatsEnabledProvider =
    StateNotifierProvider<ShopStatsEnabledNotifier, bool>((ref) {
  return ShopStatsEnabledNotifier(ref.watch(shopStatsRepositoryProvider));
});

class ShopStatsEnabledNotifier extends StateNotifier<bool> {
  ShopStatsEnabledNotifier(this._shopStats) : super(false) {
    _load();
  }

  final ShopStatsRepository _shopStats;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.shopStatsEnabledKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    if (state == enabled) return;

    if (!enabled) {
      await _shopStats.abandonAllSessions();
    }

    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.shopStatsEnabledKey, enabled);
  }
}

final shoppingListProvider =
    StreamProvider.family<ShoppingList?, int>((ref, listId) {
  ref.watch(appInitProvider);
  final db = ref.watch(databaseProvider);
  return (db.select(db.shoppingLists)..where((t) => t.id.equals(listId)))
      .watch()
      .map((rows) => rows.isEmpty ? null : rows.first);
});

final listItemsProvider =
    StreamProvider.family<List<ListItem>, int>((ref, listId) {
  ref.watch(appInitProvider);
  return ref.watch(listRepositoryProvider).watchListItems(listId);
});

final listItemProvider =
    FutureProvider.family<ListItem?, int>((ref, itemId) async {
  ref.watch(appInitProvider);
  return ref.watch(listRepositoryProvider).getListItemById(itemId);
});

final categoryRankStatsProvider =
    StreamProvider.family<List<CategoryRankStat>, int>((ref, listId) {
  ref.watch(appInitProvider);
  final db = ref.watch(databaseProvider);
  return (db.select(db.categoryRankStats)
        ..where((t) => t.listId.equals(listId)))
      .watch();
});

final itemRankStatsProvider =
    StreamProvider.family<List<ItemRankStat>, int>((ref, listId) {
  ref.watch(appInitProvider);
  final db = ref.watch(databaseProvider);
  return (db.select(db.itemRankStats)..where((t) => t.listId.equals(listId)))
      .watch();
});

final catalogSearchProvider =
    FutureProvider.family<List<CatalogItem>, String>((ref, query) async {
  ref.watch(appInitProvider);
  if (query.trim().isEmpty) return [];
  return ref.watch(catalogRepositoryProvider).search(query);
});

final shopStatsRecordsProvider =
    StreamProvider<List<ShopStatsRecord>>((ref) {
  ref.watch(appInitProvider);
  return ref.watch(shopStatsRepositoryProvider).watchAllRecords();
});

final shopStatsRecordsForListProvider =
    StreamProvider.family<List<ShopStatsRecord>, int>((ref, listId) {
  ref.watch(appInitProvider);
  return ref.watch(shopStatsRepositoryProvider).watchRecordsForList(listId);
});

final shopStatsAverageMsPerItemProvider =
    FutureProvider.family<int?, int>((ref, listId) {
  ref.watch(appInitProvider);
  return ref.watch(shopStatsRepositoryProvider).getLongTermAverageMsPerItem(listId);
});

final defaultShoppingListIdProvider =
    StateNotifierProvider<DefaultShoppingListIdNotifier, int?>((ref) {
  return DefaultShoppingListIdNotifier();
});

class DefaultShoppingListIdNotifier extends StateNotifier<int?> {
  DefaultShoppingListIdNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(AppConstants.defaultShoppingListIdKey);
    state = value;
  }

  Future<void> setListId(int? listId) async {
    state = listId;
    final prefs = await SharedPreferences.getInstance();
    if (listId == null) {
      await prefs.remove(AppConstants.defaultShoppingListIdKey);
    } else {
      await prefs.setInt(AppConstants.defaultShoppingListIdKey, listId);
    }
  }
}

final mealPlanItemsProvider =
    StreamProvider<List<MealPlanItemWithMeal>>((ref) {
  ref.watch(appInitProvider);
  return ref.watch(mealRepositoryProvider).watchPlanItems();
});

final mealProvider = StreamProvider.family<Meal?, int>((ref, mealId) {
  ref.watch(appInitProvider);
  return ref.watch(mealRepositoryProvider).watchMeal(mealId);
});

final mealIngredientsProvider =
    StreamProvider.family<List<MealIngredient>, int>((ref, mealId) {
  ref.watch(appInitProvider);
  return ref.watch(mealRepositoryProvider).watchIngredientsForMeal(mealId);
});

final lastEatenDateProvider =
    FutureProvider.family<DateTime?, int>((ref, mealId) async {
  ref.watch(appInitProvider);
  ref.watch(mealPlanItemsProvider);
  return ref.watch(mealRepositoryProvider).getLastEatenDate(mealId);
});

final mealsEatenOnDateProvider =
    StreamProvider.family<List<MealCheckOffEventWithMeal>, DateTime>(
        (ref, date) {
  ref.watch(appInitProvider);
  return ref.watch(mealRepositoryProvider).watchMealsEatenOnDate(date);
});
