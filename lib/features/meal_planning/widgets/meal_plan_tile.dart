import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';
import '../meal_plan_formatters.dart';

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
                      _ScaleControl(
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

class _ScaleControl extends StatelessWidget {
  const _ScaleControl({
    required this.scaleFactor,
    required this.onScaleChanged,
  });

  final double scaleFactor;
  final ValueChanged<double> onScaleChanged;

  String _formatScale(double value) {
    if (value == value.roundToDouble()) {
      return '×${value.toInt()}';
    }
    return '×$value';
  }

  Future<void> _showEditor(BuildContext context) async {
    final controller = TextEditingController(
      text: scaleFactor == scaleFactor.roundToDouble()
          ? scaleFactor.toInt().toString()
          : scaleFactor.toString(),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recipe scale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final preset in [0.5, 1.0, 1.5, 2.0])
                    ActionChip(
                      label: Text(_formatScale(preset)),
                      onPressed: () => Navigator.pop(context, preset),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Custom scale',
                  hintText: 'e.g. 1.5',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                if (value != null && value > 0) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (result != null) {
      onScaleChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDefault = scaleFactor == 1.0;

    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ActionChip(
          label: Text(_formatScale(scaleFactor)),
          backgroundColor: isDefault
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.secondaryContainer,
          labelStyle: TextStyle(
            color: isDefault
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSecondaryContainer,
            fontWeight: isDefault ? FontWeight.normal : FontWeight.w600,
          ),
          onPressed: () => _showEditor(context),
        ),
        if (!isDefault)
          TextButton(
            onPressed: () => onScaleChanged(1.0),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Reset'),
          ),
      ],
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
