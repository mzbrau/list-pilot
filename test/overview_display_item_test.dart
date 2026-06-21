import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/core/models/overview_display_item.dart';
import 'package:list_pilot/core/models/overview_list_entry.dart';
import 'package:list_pilot/data/database/app_database.dart';

ShoppingList _shoppingList(int id, DateTime updatedAt) {
  return ShoppingList(
    id: id,
    name: 'Shopping $id',
    createdAt: updatedAt,
    updatedAt: updatedAt,
    lastCheckOffAt: null,
    currentTripId: 0,
    currentTripSequence: 0,
    activeShopStartedAt: null,
  );
}

void main() {
  group('sortOverviewDisplayItems', () {
    test('uses default order when no saved order exists', () {
      final older = DateTime(2026, 1, 1);
      final newer = DateTime(2026, 2, 1);
      final items = buildOverviewDisplayItems(
        mealManagerEnabled: true,
        mealPlanningEnabled: true,
        userLists: [
          ShoppingListEntry(_shoppingList(1, older)),
          TodoListEntry(
            TodoList(
              id: 2,
              name: 'Todo',
              createdAt: newer,
              updatedAt: newer,
            ),
          ),
        ],
        subtitleForEntry: (entry) => entry.name,
      );

      final sorted = sortOverviewDisplayItems(items, {});

      expect(sorted[0], isA<MealManagerDisplayItem>());
      expect(sorted[1], isA<MealPlanningDisplayItem>());
      expect((sorted[2] as UserListDisplayItem).entry.id, 2);
      expect((sorted[3] as UserListDisplayItem).entry.id, 1);
    });

    test('applies saved order map when present', () {
      final items = buildOverviewDisplayItems(
        mealManagerEnabled: true,
        mealPlanningEnabled: false,
        userLists: [
          ShoppingListEntry(_shoppingList(1, DateTime(2026, 1, 1))),
        ],
        subtitleForEntry: (entry) => entry.name,
      );

      final sorted = sortOverviewDisplayItems(
        items,
        {
          'shopping:1': 0,
          'meal_manager': 1,
        },
      );

      expect(sorted[0], isA<UserListDisplayItem>());
      expect(sorted[1], isA<MealManagerDisplayItem>());
    });
  });
}
