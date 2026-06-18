import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/overview_list_entry.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/learning_repository.dart';
import '../../data/repositories/list_repository.dart';
import '../../data/repositories/meal_repository.dart';
import '../../data/repositories/shop_stats_repository.dart';
import '../../data/repositories/todo_repository.dart';
import '../../data/seed/database_seeder.dart';
import '../../data/services/catalog_export_service.dart';
import '../../data/services/meal_export_service.dart';
import '../../data/services/meal_import_service.dart';
import '../../data/services/openai_models_service.dart';
import '../../data/services/meal_photo_service.dart';
import '../../data/services/todo_maintenance_service.dart';
import '../../data/services/todo_notification_service.dart';
import '../../router/app_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

final mealImportServiceProvider = Provider<MealImportService>((ref) {
  return MealImportService(aiConfig: ref.watch(aiConfigProvider));
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

final notificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

final todoNotificationServiceProvider =
    Provider<TodoNotificationService>((ref) {
  return TodoNotificationService(ref.watch(notificationsPluginProvider));
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final notifications = ref.watch(todoNotificationServiceProvider);
  return TodoRepository(
    ref.watch(databaseProvider),
    onCancelReminder: notifications.cancelReminder,
  );
});

final todoMaintenanceServiceProvider =
    Provider<TodoMaintenanceService>((ref) {
  return TodoMaintenanceService(
    ref.watch(todoRepositoryProvider),
    ref.watch(todoNotificationServiceProvider),
  );
});

final databaseSeederProvider = Provider<DatabaseSeeder>((ref) {
  return DatabaseSeeder(ref.watch(databaseProvider));
});

final appInitProvider = FutureProvider<void>((ref) async {
  final seeder = ref.watch(databaseSeederProvider);
  await seeder.seedIfNeeded();
  await ref.watch(todoMaintenanceServiceProvider).runMaintenance();

  if (!TodoNotificationService.isSupported) return;

  try {
    final router = ref.read(routerProvider);
    final notifications = ref.read(todoNotificationServiceProvider);
    await notifications.initialize(
      onNotificationTap: (payload) {
        if (payload == null) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          final listId = (data['listId'] as num?)?.toInt();
          final taskId = (data['taskId'] as num?)?.toInt();
          if (listId != null && taskId != null) {
            router.push('/todo/$listId/task/$taskId');
          }
        } catch (e) {
          debugPrint('Notification tap handling failed: $e');
        }
      },
    );
    await notifications.rescheduleAll(ref.read(todoRepositoryProvider));
  } catch (e, stack) {
    debugPrint('Notification initialization failed: $e\n$stack');
  }
});

final appVersionProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

final shoppingListsProvider = StreamProvider<List<ShoppingList>>((ref) {
  ref.watch(appInitProvider);
  return ref.watch(listRepositoryProvider).watchAllLists();
});

final todoListsProvider = StreamProvider<List<TodoList>>((ref) {
  ref.watch(appInitProvider);
  return ref.watch(todoRepositoryProvider).watchAllLists();
});

final overviewListsProvider =
    Provider<AsyncValue<List<OverviewListEntry>>>((ref) {
  final shoppingAsync = ref.watch(shoppingListsProvider);
  final todosAsync = ref.watch(todoListsProvider);

  if (shoppingAsync.isLoading || todosAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (shoppingAsync.hasError) {
    return AsyncValue.error(shoppingAsync.error!, shoppingAsync.stackTrace!);
  }
  if (todosAsync.hasError) {
    return AsyncValue.error(todosAsync.error!, todosAsync.stackTrace!);
  }

  final merged = <OverviewListEntry>[
    ...shoppingAsync.value!.map(ShoppingListEntry.new),
    ...todosAsync.value!.map(TodoListEntry.new),
  ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  return AsyncValue.data(merged);
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

final todoListProvider = StreamProvider.family<TodoList?, int>((ref, listId) {
  ref.watch(appInitProvider);
  final db = ref.watch(databaseProvider);
  return (db.select(db.todoLists)..where((t) => t.id.equals(listId)))
      .watch()
      .map((rows) => rows.isEmpty ? null : rows.first);
});

final todoItemsProvider =
    StreamProvider.family<List<TodoItem>, int>((ref, listId) {
  ref.watch(appInitProvider);
  return ref.watch(todoRepositoryProvider).watchListItems(listId);
});

final todoTaskProvider =
    StreamProvider.family<TodoItem?, int>((ref, taskId) {
  ref.watch(appInitProvider);
  return ref.watch(todoRepositoryProvider).watchTaskById(taskId);
});

final todoArchivedProvider =
    StreamProvider.family<List<TodoCompletedArchiveData>, int>((ref, listId) {
  ref.watch(appInitProvider);
  return ref.watch(todoRepositoryProvider).watchArchivedCompleted(listId);
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

final mealManagerEnabledProvider =
    StateNotifierProvider<MealManagerEnabledNotifier, bool>((ref) {
  return MealManagerEnabledNotifier();
});

class MealManagerEnabledNotifier extends StateNotifier<bool> {
  MealManagerEnabledNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.mealManagerEnabledKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.mealManagerEnabledKey, enabled);
  }
}

final mealPlanningEnabledProvider =
    StateNotifierProvider<MealPlanningEnabledNotifier, bool>((ref) {
  return MealPlanningEnabledNotifier();
});

class MealPlanningEnabledNotifier extends StateNotifier<bool> {
  MealPlanningEnabledNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.mealPlanningEnabledKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.mealPlanningEnabledKey, enabled);
  }
}

class AiConfig {
  const AiConfig({this.apiUri, this.apiKey, this.modelName});

  final String? apiUri;
  final String? apiKey;
  final String? modelName;

  bool get isConfigured =>
      apiUri != null &&
      apiUri!.trim().isNotEmpty &&
      apiKey != null &&
      apiKey!.trim().isNotEmpty &&
      modelName != null &&
      modelName!.trim().isNotEmpty;

  static bool isOpenAiUri(String? uri) {
    final host = Uri.tryParse(uri?.trim() ?? '')?.host.toLowerCase();
    return host == 'api.openai.com';
  }

  bool get isOpenAiEndpoint => isOpenAiUri(apiUri);

  String get maskedApiKey {
    final len = apiKey?.trim().length ?? 0;
    if (len == 0) return '';
    return '*' * len.clamp(8, 24);
  }
}

final aiConfigProvider =
    StateNotifierProvider<AiConfigNotifier, AiConfig>((ref) {
  return AiConfigNotifier();
});

class AiConfigNotifier extends StateNotifier<AiConfig> {
  AiConfigNotifier() : super(const AiConfig()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AiConfig(
      apiUri: prefs.getString(AppConstants.aiApiUriKey),
      apiKey: prefs.getString(AppConstants.aiApiKeyKey),
      modelName: prefs.getString(AppConstants.aiModelNameKey),
    );
  }

  Future<void> update({
    String? apiUri,
    String? apiKey,
    String? modelName,
  }) async {
    state = AiConfig(
      apiUri: apiUri ?? state.apiUri,
      apiKey: apiKey ?? state.apiKey,
      modelName: modelName ?? state.modelName,
    );
    final prefs = await SharedPreferences.getInstance();
    if (apiUri != null) {
      await prefs.setString(AppConstants.aiApiUriKey, apiUri);
    }
    if (apiKey != null) {
      await prefs.setString(AppConstants.aiApiKeyKey, apiKey);
    }
    if (modelName != null) {
      await prefs.setString(AppConstants.aiModelNameKey, modelName);
    }
  }
}

class OpenAiModelsState {
  const OpenAiModelsState({
    this.models = const [],
    this.isLoading = false,
    this.error,
  });

  final List<String> models;
  final bool isLoading;
  final String? error;

  OpenAiModelsState copyWith({
    List<String>? models,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OpenAiModelsState(
      models: models ?? this.models,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final openAiModelsServiceProvider = Provider<OpenAiModelsService>((ref) {
  return OpenAiModelsService();
});

final openAiModelsProvider =
    StateNotifierProvider<OpenAiModelsNotifier, OpenAiModelsState>((ref) {
  return OpenAiModelsNotifier(ref.watch(openAiModelsServiceProvider));
});

class OpenAiModelsNotifier extends StateNotifier<OpenAiModelsState> {
  OpenAiModelsNotifier(this._service) : super(const OpenAiModelsState()) {
    loadCached();
  }

  final OpenAiModelsService _service;
  bool _cacheLoaded = false;

  Future<void> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.openAiModelsCacheKey);
    if (raw == null || raw.isEmpty) {
      _cacheLoaded = true;
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _cacheLoaded = true;
        return;
      }
      final models = decoded
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (models.isNotEmpty) {
        state = state.copyWith(models: models, clearError: true);
      }
    } catch (_) {
      // Ignore invalid cache.
    } finally {
      _cacheLoaded = true;
    }
  }

  Future<void> ensureLoaded({
    required String apiUri,
    required String apiKey,
  }) async {
    if (!_cacheLoaded) await loadCached();
    if (state.models.isNotEmpty || state.isLoading) return;
    await _fetch(apiUri: apiUri, apiKey: apiKey);
  }

  Future<void> refresh({
    required String apiUri,
    required String apiKey,
  }) async {
    if (!_cacheLoaded) await loadCached();
    await _fetch(apiUri: apiUri, apiKey: apiKey, force: true);
  }

  Future<void> _fetch({
    required String apiUri,
    required String apiKey,
    bool force = false,
  }) async {
    if (apiUri.trim().isEmpty || apiKey.trim().isEmpty) {
      state = state.copyWith(
        error: 'API URI and key are required to load models',
      );
      return;
    }

    if (!force && state.models.isNotEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final models = await _service.fetchModels(
        apiUri: apiUri,
        apiKey: apiKey,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.openAiModelsCacheKey,
        jsonEncode(models),
      );
      state = OpenAiModelsState(models: models);
    } on OpenAiModelsException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load models: $e',
      );
    }
  }
}

enum MealManagerLayoutMode { list, tiles }

final mealManagerLayoutModeProvider =
    StateNotifierProvider<MealManagerLayoutModeNotifier, MealManagerLayoutMode>(
        (ref) {
  return MealManagerLayoutModeNotifier();
});

class MealManagerLayoutModeNotifier
    extends StateNotifier<MealManagerLayoutMode> {
  MealManagerLayoutModeNotifier() : super(MealManagerLayoutMode.list) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(AppConstants.mealManagerLayoutModeKey);
    if (value == 'tiles') state = MealManagerLayoutMode.tiles;
  }

  Future<void> setMode(MealManagerLayoutMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.mealManagerLayoutModeKey,
      mode == MealManagerLayoutMode.tiles ? 'tiles' : 'list',
    );
  }
}

final mealManagerMealsProvider = StreamProvider<List<Meal>>((ref) {
  ref.watch(appInitProvider);
  return ref.watch(mealRepositoryProvider).watchAllMeals();
});

final mealStepsProvider =
    StreamProvider.family<List<MealStep>, int>((ref, mealId) {
  ref.watch(appInitProvider);
  return ref.watch(mealRepositoryProvider).watchStepsForMeal(mealId);
});

final mealTagsProvider =
    StreamProvider.family<List<MealTag>, int>((ref, mealId) {
  ref.watch(appInitProvider);
  return ref.watch(mealRepositoryProvider).watchTagsForMeal(mealId);
});
