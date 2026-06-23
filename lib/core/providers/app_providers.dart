import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/overview_display_item.dart';
import '../../core/models/overview_list_entry.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/learning_repository.dart';
import '../../data/repositories/list_repository.dart';
import '../../data/repositories/meal_repository.dart';
import '../../data/repositories/shop_stats_repository.dart';
import '../../data/repositories/todo_repository.dart';
import '../../data/repositories/take_away_repository.dart';
import '../../data/repositories/overview_order_repository.dart';
import '../../data/repositories/receipt_repository.dart';
import '../../data/seed/database_seeder.dart';
import '../../data/services/catalog_export_service.dart';
import '../../data/services/ingredient_catalog_matcher.dart';
import '../../data/services/ingredient_parser_service.dart';
import '../../data/services/meal_export_service.dart';
import '../../data/services/meal_import_service.dart';
import '../../data/services/meal_plan_ai_suggest_service.dart';
import '../../data/services/menu_import_service.dart';
import '../../data/services/receipt_ai_insights_service.dart';
import '../../data/services/receipt_import_service.dart';
import '../../data/services/receipt_insights_service.dart';
import '../../data/services/receipt_pdf_service.dart';
import '../../data/services/receipt_share_service.dart';
import '../../data/services/openai_models_service.dart';
import '../../data/services/meal_photo_service.dart';
import '../../data/services/recipe_page_import_service.dart';
import '../../data/services/todo_maintenance_service.dart';
import '../../data/services/todo_notification_service.dart';
import '../../router/app_router.dart';
import 'package:intl/intl.dart';
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

final mealPlanAiSuggestServiceProvider =
    Provider<MealPlanAiSuggestService>((ref) {
  return MealPlanAiSuggestService(aiConfig: ref.watch(aiConfigProvider));
});

final recipePageImportServiceProvider = Provider<RecipePageImportService>((ref) {
  return RecipePageImportService();
});

final ingredientCatalogMatcherProvider = Provider<IngredientCatalogMatcher>((ref) {
  return IngredientCatalogMatcher(
    ref.watch(catalogRepositoryProvider),
    const IngredientParserService(),
  );
});

final menuImportServiceProvider = Provider<MenuImportService>((ref) {
  return MenuImportService(aiConfig: ref.watch(aiConfigProvider));
});

final takeAwayRepositoryProvider = Provider<TakeAwayRepository>((ref) {
  return TakeAwayRepository(ref.watch(databaseProvider));
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(ref.watch(databaseProvider));
});

final overviewOrderRepositoryProvider = Provider<OverviewOrderRepository>((ref) {
  return OverviewOrderRepository(ref.watch(databaseProvider));
});

final receiptPdfServiceProvider = Provider<ReceiptPdfService>((ref) {
  return ReceiptPdfService();
});

final receiptItemEnrichmentServiceProvider =
    Provider<ReceiptItemEnrichmentService>((ref) {
  return ReceiptItemEnrichmentService(
    aiConfig: ref.watch(aiConfigProvider),
    catalogRepository: ref.watch(catalogRepositoryProvider),
    matcher: ref.watch(ingredientCatalogMatcherProvider),
  );
});

final receiptImportServiceProvider = Provider<ReceiptImportService>((ref) {
  return ReceiptImportService(
    repository: ref.watch(receiptRepositoryProvider),
    pdfService: ref.watch(receiptPdfServiceProvider),
    enrichmentService: ref.watch(receiptItemEnrichmentServiceProvider),
  );
});

final receiptInsightsServiceProvider = Provider<ReceiptInsightsService>((ref) {
  return ReceiptInsightsService();
});

final receiptAiInsightsServiceProvider = Provider<ReceiptAiInsightsService>((ref) {
  return ReceiptAiInsightsService(aiConfig: ref.watch(aiConfigProvider));
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

final takeAwayListsProvider = StreamProvider<List<TakeAwayList>>((ref) {
  ref.watch(appInitProvider);
  return ref.watch(takeAwayRepositoryProvider).watchAllLists();
});

final receiptListsProvider = StreamProvider<List<ReceiptList>>((ref) {
  ref.watch(appInitProvider);
  return ref.watch(receiptRepositoryProvider).watchAllLists();
});

final overviewListsProvider =
    Provider<AsyncValue<List<OverviewListEntry>>>((ref) {
  final shoppingAsync = ref.watch(shoppingListsProvider);
  final todosAsync = ref.watch(todoListsProvider);
  final takeAwayAsync = ref.watch(takeAwayListsProvider);
  final receiptsAsync = ref.watch(receiptListsProvider);

  if (shoppingAsync.isLoading ||
      todosAsync.isLoading ||
      takeAwayAsync.isLoading ||
      receiptsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (shoppingAsync.hasError) {
    return AsyncValue.error(shoppingAsync.error!, shoppingAsync.stackTrace!);
  }
  if (todosAsync.hasError) {
    return AsyncValue.error(todosAsync.error!, todosAsync.stackTrace!);
  }
  if (takeAwayAsync.hasError) {
    return AsyncValue.error(takeAwayAsync.error!, takeAwayAsync.stackTrace!);
  }
  if (receiptsAsync.hasError) {
    return AsyncValue.error(receiptsAsync.error!, receiptsAsync.stackTrace!);
  }

  final merged = <OverviewListEntry>[
    ...shoppingAsync.value!.map(ShoppingListEntry.new),
    ...todosAsync.value!.map(TodoListEntry.new),
    ...takeAwayAsync.value!.map(TakeAwayListEntry.new),
    ...receiptsAsync.value!.map(ReceiptListEntry.new),
  ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  return AsyncValue.data(merged);
});

final overviewOrderMapProvider = StreamProvider<Map<String, int>>((ref) {
  ref.watch(appInitProvider);
  return ref.watch(overviewOrderRepositoryProvider).watchOrderMap();
});

final overviewDisplayItemsProvider =
    Provider<AsyncValue<List<OverviewDisplayItem>>>((ref) {
  final listsAsync = ref.watch(overviewListsProvider);
  final orderMapAsync = ref.watch(overviewOrderMapProvider);
  final mealManagerEnabled = ref.watch(mealManagerEnabledProvider);
  final mealPlanningEnabled = ref.watch(mealPlanningEnabledProvider);
  final dateFormat = DateFormat.MMMd().add_jm();

  if (listsAsync.isLoading || orderMapAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (listsAsync.hasError) {
    return AsyncValue.error(listsAsync.error!, listsAsync.stackTrace!);
  }
  if (orderMapAsync.hasError) {
    return AsyncValue.error(orderMapAsync.error!, orderMapAsync.stackTrace!);
  }

  final items = buildOverviewDisplayItems(
    mealManagerEnabled: mealManagerEnabled,
    mealPlanningEnabled: mealPlanningEnabled,
    userLists: listsAsync.value!,
    subtitleForEntry: (entry) =>
        'Updated ${dateFormat.format(entry.updatedAt)}',
  );

  return AsyncValue.data(
    sortOverviewDisplayItems(items, orderMapAsync.value ?? {}),
  );
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  ref.watch(appInitProvider);
  return ref.watch(catalogRepositoryProvider).getCategories();
});

class CatalogOverviewData {
  const CatalogOverviewData({
    required this.items,
    required this.categories,
    required this.aliasCounts,
  });

  final List<CatalogItem> items;
  final List<Category> categories;
  final Map<int, int> aliasCounts;
}

final allCatalogItemsProvider =
    FutureProvider<CatalogOverviewData>((ref) async {
  ref.watch(appInitProvider);
  final repo = ref.watch(catalogRepositoryProvider);
  final items = await repo.getAllCatalogItems();
  final categories = await repo.getCategories();
  final aliasCounts = await repo.getAliasCountsByCatalogItemId();
  return CatalogOverviewData(
    items: items,
    categories: categories,
    aliasCounts: aliasCounts,
  );
});

final catalogItemProvider =
    FutureProvider.family<CatalogItem?, int>((ref, id) async {
  ref.watch(appInitProvider);
  return ref.watch(catalogRepositoryProvider).getById(id);
});

final catalogItemAliasesProvider =
    FutureProvider.family<List<CatalogItemAlias>, int>((ref, id) async {
  ref.watch(appInitProvider);
  return ref.watch(catalogRepositoryProvider).getAliases(id);
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

final takeAwayListProvider =
    StreamProvider.family<TakeAwayList?, int>((ref, listId) {
  ref.watch(appInitProvider);
  final db = ref.watch(databaseProvider);
  return (db.select(db.takeAwayLists)..where((t) => t.id.equals(listId)))
      .watch()
      .map((rows) => rows.isEmpty ? null : rows.first);
});

final takeAwayMenusProvider =
    StreamProvider.family<List<TakeAwayMenu>, int>((ref, listId) {
  ref.watch(appInitProvider);
  return ref.watch(takeAwayRepositoryProvider).watchMenusForList(listId);
});

final takeAwayMenuProvider =
    StreamProvider.family<TakeAwayMenu?, int>((ref, menuId) {
  ref.watch(appInitProvider);
  return ref.watch(takeAwayRepositoryProvider).watchMenuById(menuId);
});

final takeAwayMenuItemsProvider =
    StreamProvider.family<List<TakeAwayMenuItem>, int>((ref, menuId) {
  ref.watch(appInitProvider);
  return ref.watch(takeAwayRepositoryProvider).watchMenuItems(menuId);
});

final takeAwayOrderProvider =
    StreamProvider.family<TakeAwayOrderWithLines?, int>((ref, menuId) {
  ref.watch(appInitProvider);
  return ref.watch(takeAwayRepositoryProvider).watchOrderWithLines(menuId);
});

final receiptListProvider = StreamProvider.family<ReceiptList?, int>((ref, listId) {
  ref.watch(appInitProvider);
  final db = ref.watch(databaseProvider);
  return (db.select(db.receiptLists)..where((t) => t.id.equals(listId)))
      .watch()
      .map((rows) => rows.isEmpty ? null : rows.first);
});

final receiptsForListProvider =
    StreamProvider.family<List<Receipt>, int>((ref, listId) {
  ref.watch(appInitProvider);
  return ref.watch(receiptRepositoryProvider).watchReceiptsForList(listId);
});

final receiptProvider = StreamProvider.family<Receipt?, int>((ref, receiptId) {
  ref.watch(appInitProvider);
  return ref.watch(receiptRepositoryProvider).watchReceiptById(receiptId);
});

final receiptLinesProvider =
    StreamProvider.family<List<ReceiptLine>, int>((ref, receiptId) {
  ref.watch(appInitProvider);
  return ref.watch(receiptRepositoryProvider).watchLinesForReceipt(receiptId);
});

final receiptAiInsightProvider =
    StreamProvider.family<ReceiptAiInsightRun?, int>((ref, listId) {
  ref.watch(appInitProvider);
  return ref.watch(receiptRepositoryProvider).watchLatestAiInsight(listId);
});

final receiptInsightsSnapshotProvider =
    FutureProvider.family<ReceiptInsightsSnapshot, int>((ref, listId) async {
  ref.watch(appInitProvider);
  ref.watch(receiptsForListProvider(listId));
  final receipts =
      await ref.watch(receiptRepositoryProvider).watchReceiptsForList(listId).first;
  final lines = await ref.watch(receiptRepositoryProvider).getLinesForList(listId);
  return ref.watch(receiptInsightsServiceProvider).build(
        receipts: receipts,
        lines: lines,
      );
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

/// Resolves which shopping list meal ingredients should be added to.
/// Uses the configured default when valid, otherwise the only list if there is
/// just one.
final effectiveDefaultShoppingListIdProvider = Provider<int?>((ref) {
  final configuredId = ref.watch(defaultShoppingListIdProvider);
  final lists = ref.watch(shoppingListsProvider).valueOrNull;
  if (lists == null || lists.isEmpty) return null;

  if (configuredId != null && lists.any((list) => list.id == configuredId)) {
    return configuredId;
  }

  if (lists.length == 1) {
    return lists.first.id;
  }

  return null;
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
  const AiConfig({
    this.apiUri,
    this.apiKey,
    this.modelName,
    this.photoImportModelName,
  });

  final String? apiUri;
  final String? apiKey;
  final String? modelName;
  final String? photoImportModelName;

  bool get isConfigured =>
      apiUri != null &&
      apiUri!.trim().isNotEmpty &&
      apiKey != null &&
      apiKey!.trim().isNotEmpty &&
      modelName != null &&
      modelName!.trim().isNotEmpty;

  String? get effectivePhotoImportModel {
    final photoModel = photoImportModelName?.trim();
    if (photoModel != null && photoModel.isNotEmpty) {
      return photoModel;
    }
    final model = modelName?.trim();
    if (model == null || model.isEmpty) return null;
    return model;
  }

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
      photoImportModelName:
          prefs.getString(AppConstants.aiPhotoImportModelNameKey),
    );
  }

  Future<void> update({
    String? apiUri,
    String? apiKey,
    String? modelName,
    String? photoImportModelName,
    bool clearPhotoImportModelName = false,
  }) async {
    state = AiConfig(
      apiUri: apiUri ?? state.apiUri,
      apiKey: apiKey ?? state.apiKey,
      modelName: modelName ?? state.modelName,
      photoImportModelName: clearPhotoImportModelName
          ? null
          : (photoImportModelName ?? state.photoImportModelName),
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
    if (clearPhotoImportModelName) {
      await prefs.remove(AppConstants.aiPhotoImportModelNameKey);
    } else if (photoImportModelName != null) {
      final trimmed = photoImportModelName.trim();
      if (trimmed.isEmpty) {
        await prefs.remove(AppConstants.aiPhotoImportModelNameKey);
      } else {
        await prefs.setString(
          AppConstants.aiPhotoImportModelNameKey,
          trimmed,
        );
      }
    }
  }
}

final mealPlanAiSuggestPrefsProvider =
    StateNotifierProvider<MealPlanAiSuggestPrefsNotifier, MealPlanAiSuggestOptions>(
        (ref) {
  return MealPlanAiSuggestPrefsNotifier();
});

class MealPlanAiSuggestPrefsNotifier
    extends StateNotifier<MealPlanAiSuggestOptions> {
  MealPlanAiSuggestPrefsNotifier() : super(const MealPlanAiSuggestOptions()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(AppConstants.mealPlanAiSuggestionCountKey) ?? 5;
    state = MealPlanAiSuggestOptions(
      query: prefs.getString(AppConstants.mealPlanAiQueryKey) ?? '',
      prioritizeNotMadeRecently:
          prefs.getBool(AppConstants.mealPlanAiPrioritizeRecentKey) ?? true,
      offerAlternatives:
          prefs.getBool(AppConstants.mealPlanAiOfferAlternativesKey) ?? false,
      suggestionCount: MealPlanAiSuggestOptions.suggestionCountChoices
              .contains(count)
          ? count
          : 5,
    );
  }

  Future<void> save(MealPlanAiSuggestOptions options) async {
    state = options;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.mealPlanAiQueryKey, options.query);
    await prefs.setBool(
      AppConstants.mealPlanAiPrioritizeRecentKey,
      options.prioritizeNotMadeRecently,
    );
    await prefs.setBool(
      AppConstants.mealPlanAiOfferAlternativesKey,
      options.offerAlternatives,
    );
    await prefs.setInt(
      AppConstants.mealPlanAiSuggestionCountKey,
      options.suggestionCount,
    );
  }
}

final recipeImportLanguageProvider =
    StateNotifierProvider<RecipeImportLanguageNotifier, RecipeImportLanguage>(
        (ref) {
  return RecipeImportLanguageNotifier();
});

class RecipeImportLanguageNotifier extends StateNotifier<RecipeImportLanguage> {
  RecipeImportLanguageNotifier() : super(defaultRecipeImportLanguage) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code =
        prefs.getString(AppConstants.recipeImportLanguageKey) ??
            defaultRecipeImportLanguageCode;
    state = recipeImportLanguageByCode(code);
  }

  Future<void> setLanguage(RecipeImportLanguage language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.recipeImportLanguageKey, language.code);
  }
}

final menuImportLanguageProvider =
    StateNotifierProvider<MenuImportLanguageNotifier, RecipeImportLanguage>(
        (ref) {
  return MenuImportLanguageNotifier();
});

class MenuImportLanguageNotifier extends StateNotifier<RecipeImportLanguage> {
  MenuImportLanguageNotifier() : super(defaultMenuImportLanguage) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code =
        prefs.getString(AppConstants.menuImportLanguageKey) ??
            defaultMenuImportLanguageCode;
    state = menuImportLanguageByCode(code);
  }

  Future<void> setLanguage(RecipeImportLanguage language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.menuImportLanguageKey, language.code);
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
