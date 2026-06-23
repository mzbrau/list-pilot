import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';
import '../meal_plan_formatters.dart';
import 'recipe_scale_control.dart';

class MealPlanTile extends ConsumerWidget {
  const MealPlanTile({
    super.key,
    required this.entry,
    required this.completed,
    required this.onToggle,
    required this.onTap,
    required this.onAddIngredients,
    required this.onScaleChanged,
  });

  final MealPlanItemWithMeal entry;
  final bool completed;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onAddIngredients;
  final ValueChanged<double> onScaleChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final meal = entry.meal;
    final scaleFactor = entry.planItem.scaleFactor;
    final lastEatenAsync = ref.watch(lastEatenDateProvider(meal.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: completed ? 0.55 : 1,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: completed,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) => onToggle(value ?? false),
                ),
                _MealPhotoThumbnail(meal: meal),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.displayName,
                                style: completed
                                    ? theme.textTheme.titleMedium?.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      )
                                    : theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              lastEatenAsync.when(
                                loading: () => Text(
                                  formatPortions(meal.portions),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                error: (_, __) => Text(
                                  formatPortions(meal.portions),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                data: (lastEaten) => Text(
                                  '${formatLastEatenSummary(lastEaten)} · ${formatPortions(meal.portions)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      RecipeScaleControl(
                        scaleFactor: scaleFactor,
                        onScaleChanged: onScaleChanged,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart_outlined),
                  tooltip: 'Add ingredients to list',
                  onPressed: onAddIngredients,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealPhotoThumbnail extends ConsumerWidget {
  const _MealPhotoThumbnail({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (meal.photoPath == null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.restaurant_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return FutureBuilder<File?>(
      future: ref.read(mealPhotoServiceProvider).resolvePhotoFile(meal.photoPath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: file != null
              ? Image.file(
                  file,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 48,
                  height: 48,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.restaurant_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        );
      },
    );
  }
}
