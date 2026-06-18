import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../router/navigation_helpers.dart';
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

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealManagerMealsProvider);
    final layoutMode = ref.watch(mealManagerLayoutModeProvider);
    final theme = Theme.of(context);

    return popOrGoHomeScope(
      child: Scaffold(
      appBar: AppBar(
        leading: overviewBackButton(context),
        title: const Text('Meal Manager'),
        actions: [
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
              loading: () => const Center(child: CircularProgressIndicator()),
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
                        onTap: () =>
                            context.push('/meal-manager/${meal.id}'),
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
                      onTap: () => context.push('/meal-manager/${meal.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateMealSheet.show(context, ref),
        child: const Icon(Icons.add),
      ),
    ),
    );
  }
}
