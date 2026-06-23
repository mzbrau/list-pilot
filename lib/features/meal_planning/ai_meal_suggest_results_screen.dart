import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/services/meal_plan_ai_suggest_service.dart';
import '../../router/navigation_helpers.dart';
import 'widgets/meal_photo_thumbnail.dart';

class AiMealSuggestResultsScreen extends ConsumerStatefulWidget {
  const AiMealSuggestResultsScreen({
    super.key,
    required this.options,
  });

  final MealPlanAiSuggestOptions options;

  @override
  ConsumerState<AiMealSuggestResultsScreen> createState() =>
      _AiMealSuggestResultsScreenState();
}

class _AiMealSuggestResultsScreenState
    extends ConsumerState<AiMealSuggestResultsScreen> {
  bool _loading = true;
  String? _error;
  MealPlanAiSuggestionResult? _result;
  Map<int, Meal> _mealsById = {};
  final Set<int> _selectedMealIds = {};
  List<int> _excludeMealIds = [];
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions({bool tryAgain = false}) async {
    if (tryAgain && _result != null) {
      _excludeMealIds = [
        ..._excludeMealIds,
        ..._result!.suggestions.map((s) => s.mealId),
      ];
    }

    setState(() {
      _loading = true;
      _error = null;
      if (!tryAgain) {
        _selectedMealIds.clear();
      }
    });

    try {
      final repo = ref.read(mealRepositoryProvider);
      final catalog = await repo.getMealCatalogForAi();
      final planItems = await repo.watchPlanItems().first;
      final activePlan = planItems
          .where((e) => !e.planItem.isCompleted)
          .map(
            (e) => MealPlanActiveEntry(
              mealId: e.meal.id,
              displayName: e.meal.displayName,
            ),
          )
          .toList();

      final request = MealPlanAiSuggestRequest(
        options: widget.options,
        catalog: catalog,
        activePlan: activePlan,
        excludeMealIds: _excludeMealIds,
      );

      final result = await ref
          .read(mealPlanAiSuggestServiceProvider)
          .suggestMeals(request);

      final mealsById = <int, Meal>{};
      for (final entry in catalog) {
        final meal = await repo.getMealById(entry.id);
        if (meal != null) mealsById[entry.id] = meal;
      }

      if (!mounted) return;
      setState(() {
        _mealsById = mealsById;
        _result = result;
        _loading = false;
        if (!tryAgain) {
          _selectedMealIds.addAll(result.suggestions.map((s) => s.mealId));
        }
      });
    } on MealPlanAiSuggestException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to get suggestions: $e';
        _loading = false;
      });
    }
  }

  void _toggleSelection(int mealId, bool selected) {
    setState(() {
      if (selected) {
        _selectedMealIds.add(mealId);
      } else {
        _selectedMealIds.remove(mealId);
      }
    });
  }

  Future<void> _addSelectedToPlan() async {
    if (_selectedMealIds.isEmpty) return;
    setState(() => _adding = true);
    final repo = ref.read(mealRepositoryProvider);
    final count = _selectedMealIds.length;
    for (final mealId in _selectedMealIds) {
      await repo.addMealToPlan(mealId);
    }
    if (!mounted) return;
    setState(() => _adding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added $count meal${count == 1 ? '' : 's'} to your plan',
        ),
      ),
    );
    context.pop();
  }

  Meal? _mealFor(int mealId) => _mealsById[mealId];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = _selectedMealIds.length;

    return popOrGoHomeScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meal suggestions'),
          actions: [
            if (!_loading && _result != null)
              TextButton(
                onPressed: _adding ? null : () => _loadSuggestions(tryAgain: true),
                child: const Text('Try again'),
              ),
            if (!_loading && _result != null && selectedCount > 0)
              TextButton(
                onPressed: _adding ? null : _addSelectedToPlan,
                child: _adding
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Add $selectedCount'),
              ),
          ],
        ),
        body: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Finding meals…',
                style: theme.textTheme.titleMedium,
              ),
              if (widget.options.query.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.options.query,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _loadSuggestions(tryAgain: _result != null),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final suggestions = _result?.suggestions ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _SuggestionCard(
          suggestion: suggestion,
          meal: _mealFor(suggestion.mealId),
          alternativeMeals: suggestion.alternatives
              .map(_mealFor)
              .whereType<Meal>()
              .toList(),
          selectedMealIds: _selectedMealIds,
          offerAlternatives: widget.options.offerAlternatives,
          onToggle: _toggleSelection,
          onOpenMeal: (mealId) => context.push('/meals/$mealId'),
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.meal,
    required this.alternativeMeals,
    required this.selectedMealIds,
    required this.offerAlternatives,
    required this.onToggle,
    required this.onOpenMeal,
  });

  final MealPlanAiSuggestion suggestion;
  final Meal? meal;
  final List<Meal> alternativeMeals;
  final Set<int> selectedMealIds;
  final bool offerAlternatives;
  final void Function(int mealId, bool selected) onToggle;
  final void Function(int mealId) onOpenMeal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayMeal = meal;
    final mealId = suggestion.mealId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selectedMealIds.contains(mealId),
                  onChanged: displayMeal == null
                      ? null
                      : (value) => onToggle(mealId, value ?? false),
                ),
                if (displayMeal != null)
                  MealPhotoThumbnail(meal: displayMeal)
                else
                  const SizedBox(width: 48, height: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: displayMeal == null
                            ? null
                            : () => onOpenMeal(mealId),
                        child: Text(
                          displayMeal?.displayName ?? 'Unknown meal',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion.reason,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (displayMeal?.prepTimeMinutes != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${displayMeal!.prepTimeMinutes} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (offerAlternatives && alternativeMeals.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Alternatives',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              ...alternativeMeals.map(
                (alt) => _AlternativeRow(
                  meal: alt,
                  selected: selectedMealIds.contains(alt.id),
                  onToggle: (selected) => onToggle(alt.id, selected),
                  onOpen: () => onOpenMeal(alt.id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AlternativeRow extends StatelessWidget {
  const _AlternativeRow({
    required this.meal,
    required this.selected,
    required this.onToggle,
    required this.onOpen,
  });

  final Meal meal;
  final bool selected;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            onChanged: (value) => onToggle(value ?? false),
          ),
          MealPhotoThumbnail(meal: meal, width: 40, height: 40),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: onOpen,
              child: Text(meal.displayName),
            ),
          ),
        ],
      ),
    );
  }
}
