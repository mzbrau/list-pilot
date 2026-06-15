import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class AddIngredientsDialog extends ConsumerStatefulWidget {
  const AddIngredientsDialog({super.key, required this.mealId});

  final int mealId;

  static Future<void> show(BuildContext context, {required int mealId}) {
    return showDialog<void>(
      context: context,
      builder: (context) => AddIngredientsDialog(mealId: mealId),
    );
  }

  @override
  ConsumerState<AddIngredientsDialog> createState() =>
      _AddIngredientsDialogState();
}

class _DialogIngredient {
  _DialogIngredient({
    required this.displayName,
    this.catalogItemId,
    required this.selected,
  });

  final String displayName;
  final int? catalogItemId;
  bool selected;
}

class _AddIngredientsDialogState extends ConsumerState<AddIngredientsDialog> {
  final _addController = TextEditingController();
  final _addFocusNode = FocusNode();
  Timer? _debounce;
  List<CatalogItem> _suggestions = [];
  bool _showSuggestions = false;
  List<_DialogIngredient> _ingredients = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
    _addController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addController.removeListener(_onTextChanged);
    _addController.dispose();
    _addFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadIngredients() async {
    final items =
        await ref.read(mealRepositoryProvider).getIngredientsForMeal(widget.mealId);
    if (!mounted) return;
    setState(() {
      _ingredients = items
          .map(
            (i) => _DialogIngredient(
              displayName: i.displayName,
              catalogItemId: i.catalogItemId,
              selected: i.addToShoppingList,
            ),
          )
          .toList();
      _loading = false;
    });
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.autocompleteDebounceMs),
      () async {
        final query = _addController.text;
        if (query.trim().isEmpty) {
          if (mounted) setState(() => _suggestions = []);
          return;
        }
        final results =
            await ref.read(catalogRepositoryProvider).search(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _showSuggestions = _addFocusNode.hasFocus;
          });
        }
      },
    );
  }

  void _addIngredient({CatalogItem? catalogItem}) {
    final displayName = catalogItem?.displayName ?? _addController.text.trim();
    if (displayName.isEmpty) return;

    final exists = _ingredients.any(
      (i) => i.displayName.toLowerCase() == displayName.toLowerCase(),
    );
    if (exists) return;

    setState(() {
      _ingredients.add(
        _DialogIngredient(
          displayName: displayName,
          catalogItemId: catalogItem?.id,
          selected: true,
        ),
      );
      _addController.clear();
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  Future<void> _confirm() async {
    final listId = ref.read(defaultShoppingListIdProvider);
    if (listId == null) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Set a default shopping list in Settings first.',
            ),
          ),
        );
      }
      return;
    }

    final selected = _ingredients.where((i) => i.selected).toList();
    if (selected.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one ingredient.')),
        );
      }
      return;
    }

    setState(() => _submitting = true);

    final listRepo = ref.read(listRepositoryProvider);
    final catalogRepo = ref.read(catalogRepositoryProvider);

    for (final ingredient in selected) {
      if (ingredient.catalogItemId != null) {
        final catalogItem = await catalogRepo.findByName(ingredient.displayName);
        if (catalogItem != null) {
          await listRepo.addItemFromCatalog(
            listId: listId,
            catalogItem: catalogItem,
          );
          continue;
        }
      }
      await listRepo.addItem(
        listId: listId,
        displayName: ingredient.displayName,
      );
    }

    if (!mounted) return;

    final list = await ref.read(listRepositoryProvider).getListById(listId);
    if (!mounted) return;
    final listName = list?.name ?? 'your list';
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${selected.length} ingredient${selected.length == 1 ? '' : 's'} to $listName',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add ingredients to list'),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_ingredients.isEmpty)
                    Text(
                      'No ingredients yet. Add some below.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _ingredients.length,
                        itemBuilder: (context, index) {
                          final item = _ingredients[index];
                          return CheckboxListTile(
                            value: item.selected,
                            title: Text(item.displayName),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (value) {
                              setState(() => item.selected = value ?? false);
                            },
                            secondary: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() => _ingredients.removeAt(index));
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addController,
                    focusNode: _addFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Add ingredient…',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addIngredient(),
                      ),
                    ),
                    onSubmitted: (_) => _addIngredient(),
                    onTap: () => setState(() => _showSuggestions = true),
                  ),
                  if (_showSuggestions && _suggestions.isNotEmpty)
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 120),
                        child: ListView.builder(
                          shrinkWrap: true,
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
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _confirm,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add to list'),
        ),
      ],
    );
  }
}
