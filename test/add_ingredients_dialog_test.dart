import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/repositories/learning_repository.dart';
import 'package:list_pilot/data/repositories/list_repository.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/repositories/shop_stats_repository.dart';
import 'package:list_pilot/data/services/ingredient_parser_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('effectiveDefaultShoppingListId uses only list when default unset', () async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final catalogRepo = CatalogRepository(db);
    final listRepo = ListRepository(
      db,
      catalogRepo,
      LearningRepository(db),
      ShopStatsRepository(db),
    );
    final listId = await listRepo.createList('Groceries');

    final container = ProviderContainer(
      overrides: [
        appInitProvider.overrideWith((ref) async {}),
        databaseProvider.overrideWithValue(db),
        listRepositoryProvider.overrideWithValue(listRepo),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    await container.read(appInitProvider.future);
    await container.read(shoppingListsProvider.stream).first;

    expect(container.read(effectiveDefaultShoppingListIdProvider), listId);
  });

  test('effectiveDefaultShoppingListId ignores stale configured id', () async {
    SharedPreferences.setMockInitialValues({
      'default_shopping_list_id': 99,
    });
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final catalogRepo = CatalogRepository(db);
    final listRepo = ListRepository(
      db,
      catalogRepo,
      LearningRepository(db),
      ShopStatsRepository(db),
    );
    final listId = await listRepo.createList('Groceries');

    final container = ProviderContainer(
      overrides: [
        appInitProvider.overrideWith((ref) async {}),
        databaseProvider.overrideWithValue(db),
        listRepositoryProvider.overrideWithValue(listRepo),
        defaultShoppingListIdProvider.overrideWith(
          (ref) => _FixedDefaultShoppingListNotifier(99),
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    await container.read(appInitProvider.future);
    await container.read(shoppingListsProvider.stream).first;

    expect(container.read(effectiveDefaultShoppingListIdProvider), listId);
  });

  test('addItemFromMealPlan writes items to the resolved shopping list', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final mealRepo = MealRepository(db);
    final catalogRepo = CatalogRepository(db);
    final listRepo = ListRepository(
      db,
      catalogRepo,
      LearningRepository(db),
      ShopStatsRepository(db),
    );

    final listId = await listRepo.createList('Groceries');
    final meal = await mealRepo.getOrCreateMeal(displayName: 'Pasta');
    await mealRepo.addIngredient(
      mealId: meal.id,
      displayName: 'Tomatoes',
      quantityValue: 400,
      quantityUnit: 'g',
    );

    final scaledQty = scaleQuantity(400, 1.5);
    await listRepo.addItem(
      listId: listId,
      displayName: 'Tomatoes',
      quantityValue: scaledQty,
      quantityUnit: 'g',
    );

    final items = await listRepo.watchListItems(listId).first;
    expect(items, hasLength(1));
    expect(items.first.displayName, 'Tomatoes');
    expect(items.first.quantityValue, 600);
    expect(items.first.quantityUnit, 'g');

    await db.close();
  });
}

class _FixedDefaultShoppingListNotifier extends DefaultShoppingListIdNotifier {
  _FixedDefaultShoppingListNotifier(this._value) : super() {
    state = _value;
  }

  final int? _value;

  @override
  Future<void> _load() async {}
}
