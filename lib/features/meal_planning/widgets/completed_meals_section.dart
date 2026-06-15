import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import 'meal_plan_tile.dart';

class CompletedMealsSection extends StatefulWidget {
  const CompletedMealsSection({
    super.key,
    required this.items,
    required this.onToggle,
    required this.onClear,
    required this.onTapItem,
    required this.onAddIngredients,
  });

  final List<MealPlanItemWithMeal> items;
  final void Function(MealPlanItemWithMeal entry, bool completed) onToggle;
  final Future<void> Function(int count) onClear;
  final void Function(MealPlanItemWithMeal entry) onTapItem;
  final void Function(MealPlanItemWithMeal entry) onAddIngredients;

  @override
  State<CompletedMealsSection> createState() => _CompletedMealsSectionState();
}

class _CompletedMealsSectionState extends State<CompletedMealsSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final theme = Theme.of(context);

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Icon(
                            _expanded
                                ? Icons.expand_more
                                : Icons.chevron_right,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Eaten (${widget.items.length})',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onClear(widget.items.length),
                  child: const Text('Clear all'),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = widget.items[index];
                return MealPlanTile(
                  entry: entry,
                  completed: true,
                  onToggle: (value) => widget.onToggle(entry, value),
                  onTap: () => widget.onTapItem(entry),
                  onAddIngredients: () => widget.onAddIngredients(entry),
                );
              },
              childCount: widget.items.length,
            ),
          ),
      ],
    );
  }
}
