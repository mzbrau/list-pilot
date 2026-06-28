import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../router/navigation_helpers.dart';

enum QuickListDestination {
  shopping,
  planning,
  recipes,
}

class QuickListSwitcher extends ConsumerWidget {
  const QuickListSwitcher({
    super.key,
    required this.current,
    this.listId,
  });

  final QuickListDestination current;
  final int? listId;

  static const _padding = EdgeInsets.fromLTRB(16, 8, 16, 0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealManagerEnabled = ref.watch(mealManagerEnabledProvider);
    final mealPlanningEnabled = ref.watch(mealPlanningEnabledProvider);
    final defaultListId = ref.watch(effectiveDefaultShoppingListIdProvider);

    if (current == QuickListDestination.shopping) {
      if (listId == null || defaultListId == null || listId != defaultListId) {
        return const SizedBox.shrink();
      }
      if (!mealManagerEnabled && !mealPlanningEnabled) {
        return const SizedBox.shrink();
      }
    }

    final segments = <ButtonSegment<QuickListDestination>>[
      ButtonSegment(
        value: QuickListDestination.shopping,
        label: const Text('Shopping'),
        icon: const Icon(Icons.shopping_cart_outlined),
        enabled: defaultListId != null,
      ),
      if (mealPlanningEnabled)
        const ButtonSegment(
          value: QuickListDestination.planning,
          label: Text('Planning'),
          icon: Icon(Icons.restaurant_menu_outlined),
        ),
      if (mealManagerEnabled)
        const ButtonSegment(
          value: QuickListDestination.recipes,
          label: Text('Recipes'),
          icon: Icon(Icons.menu_book_outlined),
        ),
    ];

    return Padding(
      padding: _padding,
      child: SegmentedButton<QuickListDestination>(
        segments: segments,
        selected: {current},
        emptySelectionAllowed: false,
        onSelectionChanged: (selection) {
          final destination = selection.first;
          if (destination == current) return;

          final route = _routeForDestination(
            destination,
            defaultListId: defaultListId,
          );
          if (route == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Set a default shopping list in Settings'),
              ),
            );
            return;
          }

          navigateToQuickList(context, route);
        },
      ),
    );
  }

  String? _routeForDestination(
    QuickListDestination destination, {
    required int? defaultListId,
  }) {
    return switch (destination) {
      QuickListDestination.shopping =>
        defaultListId != null ? '/list/$defaultListId' : null,
      QuickListDestination.planning => '/meals',
      QuickListDestination.recipes => '/meal-manager',
    };
  }
}
