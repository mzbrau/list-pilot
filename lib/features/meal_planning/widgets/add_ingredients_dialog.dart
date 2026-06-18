import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/ingredient_parser_service.dart';
import 'meal_ingredient_line_text.dart';

class AddIngredientsDialog extends ConsumerStatefulWidget {
  const AddIngredientsDialog({
    super.key,
    required this.mealId,
    this.scaleFactor = 1.0,
  });

  final int mealId;
  final double scaleFactor;

  static Future<void> show(
    BuildContext context, {
    required int mealId,
    double scaleFactor = 1.0,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AddIngredientsDialog(
        mealId: mealId,
        scaleFactor: scaleFactor,
      ),
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
    this.quantityValue,
    this.quantityUnit,
    required this.selected,
  });

  final String displayName;
  final int? catalogItemId;
  final double? quantityValue;
  final String? quantityUnit;
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
  int? _selectedListId;

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
              quantityValue: i.quantityValue,
              quantityUnit: i.quantityUnit,
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
    final lists = ref.read(shoppingListsProvider).valueOrNull ?? [];
    final listId = _selectedListId ?? ref.read(effectiveDefaultShoppingListIdProvider);

    if (listId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lists.isEmpty
                  ? 'Create a shopping list first.'
                  : 'Select a shopping list below or set a default in Settings.',
            ),
          ),
        );
      }
      return;
    }

    final listExists = lists.any((list) => list.id == listId);
    if (!listExists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('That shopping list no longer exists.'),
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
      final scaledQty = scaleQuantity(
        ingredient.quantityValue,
        widget.scaleFactor,
      );

      if (ingredient.catalogItemId != null) {
        final catalogItem =
            await catalogRepo.getById(ingredient.catalogItemId!);
        if (catalogItem != null) {
          await listRepo.addItemFromCatalog(
            listId: listId,
            catalogItem: catalogItem,
            quantityValue: scaledQty,
            quantityUnit: ingredient.quantityUnit,
          );
          continue;
        }
      }
      await listRepo.addItem(
        listId: listId,
        displayName: ingredient.displayName,
        quantityValue: scaledQty,
        quantityUnit: ingredient.quantityUnit,
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
    final showScale = widget.scaleFactor != 1.0;
    final lists = ref.watch(shoppingListsProvider).valueOrNull ?? [];
    final effectiveListId = ref.watch(effectiveDefaultShoppingListIdProvider);
    final selectedListId = _selectedListId ?? effectiveListId;
    ShoppingList? selectedList;
    if (selectedListId != null) {
      for (final list in lists) {
        if (list.id == selectedListId) {
          selectedList = list;
          break;
        }
      }
    }
    final needsListPicker = lists.length > 1 && effectiveListId == null;

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
                  if (lists.isEmpty)
                    Text(
                      'Create a shopping list first.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    )
                  else if (needsListPicker)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<int>(
                        value: selectedListId,
                        decoration: const InputDecoration(
                          labelText: 'Shopping list',
                        ),
                        items: [
                          for (final list in lists)
                            DropdownMenuItem(
                              value: list.id,
                              child: Text(list.name),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedListId = value);
                        },
                      ),
                    )
                  else if (selectedList != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Adding to ${selectedList.name}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (showScale)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Quantities scaled to ×${widget.scaleFactor == widget.scaleFactor.roundToDouble() ? widget.scaleFactor.toInt() : widget.scaleFactor}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
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
                            title: MealIngredientLineText(
                              displayName: item.displayName,
                              quantityValue: item.quantityValue,
                              quantityUnit: item.quantityUnit,
                              scaledQuantityValue: scaleQuantity(
                                item.quantityValue,
                                widget.scaleFactor,
                              ),
                            ),
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
          onPressed: _submitting || lists.isEmpty ? null : _confirm,
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
