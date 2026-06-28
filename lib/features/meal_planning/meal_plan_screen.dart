import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../router/navigation_helpers.dart';
import 'widgets/add_ingredients_dialog.dart';
import 'widgets/ai_meal_suggest_options_dialog.dart';
import 'widgets/completed_meals_section.dart';
import 'widgets/meal_autocomplete_field.dart';
import 'widgets/meal_plan_tile.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(mealPlanItemsProvider);
    final aiConfigured = ref.watch(aiConfigProvider).isConfigured;

    return popOrGoHomeScope(
      child: Scaffold(
      appBar: AppBar(
        leading: overviewBackButton(context),
        title: const Text('Meal Planning'),
        actions: [
          if (aiConfigured)
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: 'Suggest meals',
              onPressed: () => _openAiSuggest(context, ref),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Calendar',
            onPressed: () => context.push('/meals/calendar'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'export') {
                await _exportMeals(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download_outlined),
                  title: Text('Export meals'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          final active = entries.where((e) => !e.planItem.isCompleted).toList();
          final completed =
              entries.where((e) => e.planItem.isCompleted).toList();

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: MealAutocompleteField(),
              ),
              Expanded(
                child: active.isEmpty && completed.isEmpty
                    ? _EmptyMealPlan(theme: Theme.of(context))
                    : CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final entry = active[index];
                                return MealPlanTile(
                                  entry: entry,
                                  completed: false,
                                  onToggle: (value) => _toggleItem(
                                    ref,
                                    entry,
                                    value,
                                  ),
                                  onTap: () => context.push(
                                    '/meals/${entry.meal.id}',
                                  ),
                                  onAddIngredients: () =>
                                      AddIngredientsDialog.show(
                                    context,
                                    mealId: entry.meal.id,
                                    scaleFactor: entry.planItem.scaleFactor,
                                  ),
                                  onScaleChanged: (scale) => _updateScale(
                                    ref,
                                    entry,
                                    scale,
                                  ),
                                  onLongPress: () => _confirmRemoveFromPlan(
                                    context,
                                    ref,
                                    entry,
                                  ),
                                );
                              },
                              childCount: active.length,
                            ),
                          ),
                          CompletedMealsSection(
                            items: completed,
                            onToggle: (entry, value) =>
                                _toggleItem(ref, entry, value),
                            onClear: (count) =>
                                _clearCompleted(context, ref, count),
                            onTapItem: (entry) =>
                                context.push('/meals/${entry.meal.id}'),
                            onAddIngredients: (entry) =>
                                AddIngredientsDialog.show(
                              context,
                              mealId: entry.meal.id,
                              scaleFactor: entry.planItem.scaleFactor,
                            ),
                            onScaleChanged: (entry, scale) =>
                                _updateScale(ref, entry, scale),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }

  Future<void> _toggleItem(
    WidgetRef ref,
    MealPlanItemWithMeal entry,
    bool completed,
  ) async {
    await ref.read(mealRepositoryProvider).setPlanItemCompleted(
          entry.planItem.id,
          completed,
        );
  }

  Future<void> _updateScale(
    WidgetRef ref,
    MealPlanItemWithMeal entry,
    double scaleFactor,
  ) async {
    await ref.read(mealRepositoryProvider).updatePlanItemScale(
          entry.planItem.id,
          scaleFactor,
        );
  }

  Future<void> _confirmRemoveFromPlan(
    BuildContext context,
    WidgetRef ref,
    MealPlanItemWithMeal entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from plan?'),
        content: Text(
          'Remove "${entry.meal.displayName}" from your meal plan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(mealRepositoryProvider).deleteMealFromPlan(
          entry.planItem.id,
        );
  }

  Future<void> _clearCompleted(
    BuildContext context,
    WidgetRef ref,
    int count,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear eaten meals?'),
        content: Text(
          'Remove $count eaten meal${count == 1 ? '' : 's'} from your plan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(mealRepositoryProvider).clearCompletedPlanItems();
  }

  Future<void> _openAiSuggest(BuildContext context, WidgetRef ref) async {
    final options = await AiMealSuggestOptionsDialog.show(context, ref);
    if (options == null || !context.mounted) return;
    context.push('/meals/suggest', extra: options);
  }

  Future<void> _exportMeals(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result =
          await ref.read(mealExportServiceProvider).exportToFile();
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${result.mealCount} meals and '
            '${result.checkOffCount} history entries to '
            '${result.displayLocation}',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
}

class _EmptyMealPlan extends StatelessWidget {
  const _EmptyMealPlan({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Plan your week',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add meals above to plan what you\'ll eat and build your shopping list',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
