import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class MealDetailIngredientsTab extends ConsumerStatefulWidget {
  const MealDetailIngredientsTab({
    super.key,
    required this.mealId,
    required this.isEditing,
    this.draftIngredients,
    this.onDraftIngredientsChanged,
  });

  final int? mealId;
  final bool isEditing;
  final List<String>? draftIngredients;
  final ValueChanged<List<String>>? onDraftIngredientsChanged;

  @override
  ConsumerState<MealDetailIngredientsTab> createState() =>
      _MealDetailIngredientsTabState();
}

class _MealDetailIngredientsTabState
    extends ConsumerState<MealDetailIngredientsTab> {
  final _ingredientController = TextEditingController();
  final _ingredientFocusNode = FocusNode();
  Timer? _debounce;
  List<CatalogItem> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _ingredientController.addListener(_onIngredientTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ingredientController.dispose();
    _ingredientFocusNode.dispose();
    super.dispose();
  }

  void _onIngredientTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.autocompleteDebounceMs),
      () async {
        final query = _ingredientController.text;
        if (query.trim().isEmpty) {
          if (mounted) setState(() => _suggestions = []);
          return;
        }
        final results =
            await ref.read(catalogRepositoryProvider).search(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _showSuggestions = _ingredientFocusNode.hasFocus;
          });
        }
      },
    );
  }

  Future<void> _addIngredient({CatalogItem? catalogItem}) async {
    final displayName =
        catalogItem?.displayName ?? _ingredientController.text.trim();
    if (displayName.isEmpty) return;

    if (widget.mealId == null) {
      widget.onDraftIngredientsChanged?.call([
        ...?widget.draftIngredients,
        displayName,
      ]);
    } else {
      await ref.read(mealRepositoryProvider).addIngredient(
            mealId: widget.mealId!,
            displayName: displayName,
            catalogItemId: catalogItem?.id,
          );
    }

    _ingredientController.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  Future<void> _deleteIngredient(MealIngredient ingredient) async {
    await ref.read(mealRepositoryProvider).deleteIngredient(ingredient.id);
  }

  void _deleteDraftIngredient(int index) {
    final list = List<String>.from(widget.draftIngredients ?? []);
    list.removeAt(index);
    widget.onDraftIngredientsChanged?.call(list);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.mealId == null) {
      return _buildDraftList(theme);
    }

    final ingredientsAsync =
        ref.watch(mealIngredientsProvider(widget.mealId!));

    return ingredientsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (ingredients) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (ingredients.isEmpty && !widget.isEditing)
            Text(
              'No ingredients yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ...ingredients.map((ingredient) {
            if (!widget.isEditing) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: theme.textTheme.bodyLarge),
                    Expanded(
                      child: Text(
                        ingredient.displayName,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(ingredient.displayName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: ingredient.addToShoppingList,
                      onChanged: (value) {
                        ref.read(mealRepositoryProvider).updateIngredient(
                              id: ingredient.id,
                              addToShoppingList: value,
                            );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteIngredient(ingredient),
                    ),
                  ],
                ),
                subtitle: const Text('Add to shopping list'),
              ),
            );
          }),
          if (widget.isEditing) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _ingredientController,
              focusNode: _ingredientFocusNode,
              decoration: InputDecoration(
                hintText: 'Add ingredient…',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addIngredient(),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _addIngredient(),
              onTap: () => setState(() => _showSuggestions = true),
            ),
            if (_showSuggestions && _suggestions.isNotEmpty)
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.surfaceContainerHighest,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final item = _suggestions[index];
                    return ListTile(
                      dense: true,
                      title: Text(item.displayName),
                      onTap: () => _addIngredient(catalogItem: item),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDraftList(ThemeData theme) {
    final ingredients = widget.draftIngredients ?? [];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...ingredients.asMap().entries.map((entry) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(entry.value),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteDraftIngredient(entry.key),
              ),
            ),
          );
        }),
        TextField(
          controller: _ingredientController,
          focusNode: _ingredientFocusNode,
          decoration: InputDecoration(
            hintText: 'Add ingredient…',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addIngredient(),
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _addIngredient(),
          onTap: () => setState(() => _showSuggestions = true),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surfaceContainerHighest,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(item.displayName),
                  onTap: () => _addIngredient(catalogItem: item),
                );
              },
            ),
          ),
      ],
    );
  }
}
