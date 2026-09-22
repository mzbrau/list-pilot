import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../router/navigation_helpers.dart';
import '../lists/widgets/quick_list_switcher.dart';
import 'widgets/create_meal_sheet.dart';
import 'widgets/meal_manager_grid_tile.dart';
import 'widgets/meal_manager_list_tile.dart';

class MealManagerScreen extends ConsumerStatefulWidget {
  const MealManagerScreen({super.key});

  @override
  ConsumerState<MealManagerScreen> createState() => _MealManagerScreenState();
}

class _MealManagerScreenState extends ConsumerState<MealManagerScreen> {
  final _filterController = TextEditingController();
  Timer? _debounce;
  String _filterQuery = '';
  List<Meal>? _filteredMeals;
  bool _filtering = false;
  bool _isSelecting = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _filterController.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _filterController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.autocompleteDebounceMs),
      () async {
        final query = _filterController.text;
        if (query.trim().isEmpty) {
          if (mounted) {
            setState(() {
              _filterQuery = '';
              _filteredMeals = null;
              _filtering = false;
            });
          }
          return;
        }
        if (mounted) setState(() => _filtering = true);
        final results =
            await ref.read(mealRepositoryProvider).searchMealsWithTags(query);
        if (mounted) {
          setState(() {
            _filterQuery = query;
            _filteredMeals = results;
            _filtering = false;
          });
        }
      },
    );
  }

  List<Meal> _resolveMeals(List<Meal> allMeals) {
    if (_filterQuery.trim().isEmpty) return allMeals;
    return _filteredMeals ?? [];
  }

  void _exitSelection() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  void _enterSelection(int mealId) {
    setState(() {
      _isSelecting = true;
      _selectedIds
        ..clear()
        ..add(mealId);
    });
  }

  void _toggleSelection(int mealId) {
    setState(() {
      if (_selectedIds.contains(mealId)) {
        _selectedIds.remove(mealId);
      } else {
        _selectedIds.add(mealId);
      }
    });
  }

  void _onMealLongPress(int mealId) {
    if (_isSelecting) {
      _toggleSelection(mealId);
    } else {
      _enterSelection(mealId);
    }
  }

  void _onMealTap(Meal meal) {
    if (_isSelecting) {
      _toggleSelection(meal.id);
    } else {
      context.push('/meal-manager/${meal.id}');
    }
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(count == 1 ? 'Delete meal?' : 'Delete $count meals?'),
        content: Text(
          count == 1
              ? 'Remove this meal and all its ingredients and history?'
              : 'Remove these $count meals and all their ingredients and history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ids = List<int>.from(_selectedIds);
    final repo = ref.read(mealRepositoryProvider);
    for (final id in ids) {
      await repo.deleteMeal(id);
    }
    if (mounted) _exitSelection();
  }

  Future<void> _addMealToPlan(BuildContext context, Meal meal) async {
    final mealPlanningEnabled = ref.read(mealPlanningEnabledProvider);
    if (!mealPlanningEnabled) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable Meal Planning in settings to add meals to your plan'),
        ),
      );
      return;
    }

    await ref.read(mealRepositoryProvider).addMealToPlan(meal.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${meal.displayName}" to meal plan'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.push('/meals'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealManagerMealsProvider);
    final layoutMode = ref.watch(mealManagerLayoutModeProvider);
    final mealPlanningEnabled = ref.watch(mealPlanningEnabledProvider);
    final theme = Theme.of(context);
    final selectedCount = _selectedIds.length;

    return popOrGoHomeScope(
      child: PopScope(
        canPop: !_isSelecting,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _isSelecting) {
            _exitSelection();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: _isSelecting
                ? IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Cancel',
                    onPressed: _exitSelection,
                  )
                : overviewBackButton(context),
            title: Text(
              _isSelecting
                  ? (selectedCount == 0
                      ? 'Select recipes'
                      : '$selectedCount selected')
                  : 'Meal Manager',
            ),
            actions: [
              if (_isSelecting)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: selectedCount > 0 ? _deleteSelected : null,
                )
              else
                IconButton(
                  icon: Icon(
                    layoutMode == MealManagerLayoutMode.list
                        ? Icons.grid_view_outlined
                        : Icons.view_list_outlined,
                  ),
                  tooltip: layoutMode == MealManagerLayoutMode.list
                      ? 'Tile view'
                      : 'List view',
                  onPressed: () {
                    ref.read(mealManagerLayoutModeProvider.notifier).setMode(
                          layoutMode == MealManagerLayoutMode.list
                              ? MealManagerLayoutMode.tiles
                              : MealManagerLayoutMode.list,
                        );
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              const QuickListSwitcher(current: QuickListDestination.recipes),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _filterController,
                  decoration: InputDecoration(
                    hintText: 'Filter by name or tag…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _filtering
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _filterController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _filterController.clear(),
                              )
                            : null,
                  ),
                ),
              ),
              Expanded(
                child: mealsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (allMeals) {
                    final meals = _resolveMeals(allMeals);
                    if (meals.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: 64,
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _filterQuery.isNotEmpty
                                    ? 'No meals match your filter'
                                    : 'No meals yet',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _filterQuery.isNotEmpty
                                    ? 'Try a different search term'
                                    : 'Tap + to create your first recipe',
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

                    if (layoutMode == MealManagerLayoutMode.tiles) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: meals.length,
                        itemBuilder: (context, index) {
                          final meal = meals[index];
                          return MealManagerGridTile(
                            meal: meal,
                            isSelecting: _isSelecting,
                            isSelected: _selectedIds.contains(meal.id),
                            onTap: () => _onMealTap(meal),
                            onLongPress: () => _onMealLongPress(meal.id),
                            onAddToPlan: !_isSelecting && mealPlanningEnabled
                                ? () => _addMealToPlan(context, meal)
                                : null,
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return MealManagerListTile(
                          meal: meal,
                          isSelecting: _isSelecting,
                          isSelected: _selectedIds.contains(meal.id),
                          onTap: () => _onMealTap(meal),
                          onLongPress: () => _onMealLongPress(meal.id),
                          onAddToPlan: !_isSelecting && mealPlanningEnabled
                              ? () => _addMealToPlan(context, meal)
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: _isSelecting
              ? null
              : FloatingActionButton(
                  onPressed: () => CreateMealSheet.show(context, ref),
                  child: const Icon(Icons.add),
                ),
        ),
      ),
    );
  }
}
