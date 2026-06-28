import 'package:flutter/material.dart';

import 'overview_list_entry.dart';

sealed class OverviewDisplayItem {
  const OverviewDisplayItem();

  String get itemKey;
  IconData get icon;
  Color avatarBackgroundColor(BuildContext context);
  Color avatarForegroundColor(BuildContext context);
  String get title;
  String get subtitle;
  String get route;
  Color? cardBackgroundColor(BuildContext context) => null;
}

class MealManagerDisplayItem extends OverviewDisplayItem {
  const MealManagerDisplayItem();

  @override
  String get itemKey => 'meal_manager';

  @override
  IconData get icon => Icons.menu_book_outlined;

  @override
  Color avatarBackgroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.tertiaryContainer;

  @override
  Color avatarForegroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.onTertiaryContainer;

  @override
  String get title => 'Meal Manager';

  @override
  String get subtitle => 'Create and browse your recipes';

  @override
  String get route => '/meal-manager';
}

class MealPlanningDisplayItem extends OverviewDisplayItem {
  const MealPlanningDisplayItem();

  @override
  String get itemKey => 'meal_planning';

  @override
  IconData get icon => Icons.restaurant_menu_outlined;

  @override
  Color avatarBackgroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  @override
  Color avatarForegroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondaryContainer;

  @override
  String get title => 'Meal Planning';

  @override
  String get subtitle => 'Plan your week and fill your shopping list';

  @override
  String get route => '/meals';
}

class UserListDisplayItem extends OverviewDisplayItem {
  const UserListDisplayItem({
    required this.entry,
    required this.subtitle,
  });

  final OverviewListEntry entry;
  @override
  final String subtitle;

  @override
  String get itemKey {
    return switch (entry) {
      ShoppingListEntry() => 'shopping:${entry.id}',
      TodoListEntry() => 'todo:${entry.id}',
      TakeAwayListEntry() => 'take_away:${entry.id}',
      ReceiptListEntry() => 'receipts:${entry.id}',
    };
  }

  @override
  IconData get icon {
    return switch (entry) {
      ShoppingListEntry() => Icons.store_outlined,
      TodoListEntry() => Icons.checklist_outlined,
      TakeAwayListEntry() => Icons.restaurant_outlined,
      ReceiptListEntry() => Icons.receipt_long_outlined,
    };
  }

  @override
  Color avatarBackgroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer;

  @override
  Color avatarForegroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimaryContainer;

  @override
  Color? cardBackgroundColor(BuildContext context) {
    final colorValue = entry.backgroundColor;
    if (colorValue == null) return null;
    return Color(colorValue);
  }

  @override
  String get title => entry.name;

  @override
  String get route {
    return switch (entry) {
      ShoppingListEntry() => '/list/${entry.id}',
      TodoListEntry() => '/todo/${entry.id}',
      TakeAwayListEntry() => '/take-away/${entry.id}',
      ReceiptListEntry() => '/receipts/${entry.id}',
    };
  }
}

List<OverviewDisplayItem> buildOverviewDisplayItems({
  required bool mealManagerEnabled,
  required bool mealPlanningEnabled,
  required List<OverviewListEntry> userLists,
  required String Function(OverviewListEntry entry) subtitleForEntry,
}) {
  final items = <OverviewDisplayItem>[
    if (mealManagerEnabled) const MealManagerDisplayItem(),
    if (mealPlanningEnabled) const MealPlanningDisplayItem(),
    for (final entry in userLists)
      UserListDisplayItem(
        entry: entry,
        subtitle: subtitleForEntry(entry),
      ),
  ];
  return items;
}

int compareOverviewDisplayItemsDefault(
  OverviewDisplayItem a,
  OverviewDisplayItem b,
) {
  final aIsMeal = a is! UserListDisplayItem;
  final bIsMeal = b is! UserListDisplayItem;
  if (aIsMeal && !bIsMeal) return -1;
  if (!aIsMeal && bIsMeal) return 1;
  if (aIsMeal && bIsMeal) {
    if (a is MealManagerDisplayItem && b is MealPlanningDisplayItem) {
      return -1;
    }
    if (a is MealPlanningDisplayItem && b is MealManagerDisplayItem) {
      return 1;
    }
    return 0;
  }

  final aEntry = (a as UserListDisplayItem).entry;
  final bEntry = (b as UserListDisplayItem).entry;
  return bEntry.updatedAt.compareTo(aEntry.updatedAt);
}

List<OverviewDisplayItem> sortOverviewDisplayItems(
  List<OverviewDisplayItem> items,
  Map<String, int> orderMap,
) {
  if (orderMap.isEmpty) {
    return items.toList()
      ..sort(compareOverviewDisplayItemsDefault);
  }

  final sorted = items.toList()
    ..sort((a, b) {
      final aOrder = orderMap[a.itemKey];
      final bOrder = orderMap[b.itemKey];
      if (aOrder != null && bOrder != null) {
        return aOrder.compareTo(bOrder);
      }
      if (aOrder != null) return -1;
      if (bOrder != null) return 1;
      return compareOverviewDisplayItemsDefault(a, b);
    });
  return sorted;
}
