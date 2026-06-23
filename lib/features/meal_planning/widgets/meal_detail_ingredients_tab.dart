import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/ingredient_parser_service.dart';
import 'meal_ingredient_edit_sheet.dart';
import 'meal_ingredient_line_text.dart';
import 'recipe_scale_control.dart';

class MealDetailIngredientsTab extends ConsumerStatefulWidget {
  const MealDetailIngredientsTab({
    super.key,
    required this.mealId,
    required this.isEditing,
    this.draftIngredients,
    this.onDraftIngredientsChanged,
    this.nestedScroll = false,
    this.scaleFactor = 1.0,
    this.onScaleChanged,
  });

  final int? mealId;
  final bool isEditing;
  final List<String>? draftIngredients;
  final ValueChanged<List<String>>? onDraftIngredientsChanged;
  final bool nestedScroll;
  final double scaleFactor;
  final ValueChanged<double>? onScaleChanged;

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
    final rawText =
        catalogItem?.displayName ?? _ingredientController.text.trim();
    if (rawText.isEmpty) return;

    if (widget.mealId == null) {
      widget.onDraftIngredientsChanged?.call([
        ...?widget.draftIngredients,
        rawText,
      ]);
    } else {
      final parsed = const IngredientParserService().parse(rawText);
      await ref.read(mealRepositoryProvider).addIngredient(
            mealId: widget.mealId!,
            displayName: catalogItem?.displayName ?? parsed.itemName,
            catalogItemId: catalogItem?.id,
            quantityValue: parsed.quantityValue,
            quantityUnit: parsed.quantityUnit,
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

  Future<void> _editIngredient(MealIngredient ingredient) async {
    await MealIngredientEditSheet.show(context, ingredient: ingredient);
  }

  void _deleteDraftIngredient(int index) {
    final list = List<String>.from(widget.draftIngredients ?? []);
    list.removeAt(index);
    widget.onDraftIngredientsChanged?.call(list);
  }

  Widget _buildAddIngredientField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

  Widget _wrapScrollView(BuildContext context, List<Widget> children) {
    if (!widget.nestedScroll) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: children,
      );
    }
    return CustomScrollView(
      key: const PageStorageKey('meal-detail-ingredients'),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(children),
          ),
        ),
      ],
    );
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
      data: (ingredients) => _wrapScrollView(
        context,
        [
          if (!widget.isEditing && widget.onScaleChanged != null) ...[
            RecipeScaleControl(
              scaleFactor: widget.scaleFactor,
              onScaleChanged: widget.onScaleChanged!,
            ),
            if (widget.scaleFactor != 1.0) ...[
              const SizedBox(height: 8),
              Text(
                'Quantities scaled to ×${widget.scaleFactor == widget.scaleFactor.roundToDouble() ? widget.scaleFactor.toInt() : widget.scaleFactor}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
          if (widget.isEditing) ...[
            _buildAddIngredientField(theme),
            const SizedBox(height: 8),
          ],
          if (ingredients.isEmpty && !widget.isEditing)
            Text(
              'No ingredients yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (ingredients.isEmpty && widget.isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No ingredients yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ...ingredients.map((ingredient) {
            if (!widget.isEditing) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: theme.textTheme.bodyLarge),
                    Expanded(
                      child: MealIngredientLineText(
                        displayName: ingredient.displayName,
                        quantityValue: ingredient.quantityValue,
                        quantityUnit: ingredient.quantityUnit,
                        scaledQuantityValue: scaleQuantity(
                          ingredient.quantityValue,
                          widget.scaleFactor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: MealIngredientLineText(
                  displayName: ingredient.displayName,
                  quantityValue: ingredient.quantityValue,
                  quantityUnit: ingredient.quantityUnit,
                ),
                subtitle: _IngredientSubtitle(ingredient: ingredient),
                onTap: () => _editIngredient(ingredient),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit ingredient',
                      onPressed: () => _editIngredient(ingredient),
                    ),
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
                      tooltip: 'Delete ingredient',
                      onPressed: () => _deleteIngredient(ingredient),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDraftList(ThemeData theme) {
    final ingredients = widget.draftIngredients ?? [];
    return _wrapScrollView(
      context,
      [
        _buildAddIngredientField(theme),
        const SizedBox(height: 8),
        ...ingredients.asMap().entries.map((entry) {
          final parsed = const IngredientParserService().parse(entry.value);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: MealIngredientLineText(
                displayName: parsed.itemName,
                quantityValue: parsed.quantityValue,
                quantityUnit: parsed.quantityUnit,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteDraftIngredient(entry.key),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _IngredientSubtitle extends ConsumerWidget {
  const _IngredientSubtitle({required this.ingredient});

  final MealIngredient ingredient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ingredient.catalogItemId == null) {
      return const Text('Add to shopping list');
    }

    return FutureBuilder<CatalogItem?>(
      future: ref
          .read(catalogRepositoryProvider)
          .getById(ingredient.catalogItemId!),
      builder: (context, snapshot) {
        final catalogName = snapshot.data?.displayName;
        if (catalogName != null) {
          return Text('Matched: $catalogName · Add to shopping list');
        }
        return const Text('Matched catalog item · Add to shopping list');
      },
    );
  }
}
