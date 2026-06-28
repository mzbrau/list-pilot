import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/keyboard_inset_padding.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/ingredient_parser_service.dart';
import 'ingredient_catalog_name_field.dart';

class MealIngredientEditSheet extends ConsumerStatefulWidget {
  const MealIngredientEditSheet({
    super.key,
    required this.ingredient,
  });

  final MealIngredient ingredient;

  static Future<bool?> show(
    BuildContext context, {
    required MealIngredient ingredient,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => MealIngredientEditSheet(ingredient: ingredient),
    );
  }

  @override
  ConsumerState<MealIngredientEditSheet> createState() =>
      _MealIngredientEditSheetState();
}

class _MealIngredientEditSheetState
    extends ConsumerState<MealIngredientEditSheet> {
  final _quantityController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedUnit;
  Timer? _debounce;
  List<CatalogItem> _suggestions = [];
  List<Category> _categories = [];
  CatalogItem? _selectedCatalogItem;
  bool _addToCatalog = false;
  String _categoryId = 'other';
  String? _errorText;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final ingredient = widget.ingredient;
    if (ingredient.quantityValue != null) {
      final value = ingredient.quantityValue!;
      _quantityController.text = value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toString();
    }
    _selectedUnit = _canonicalUnit(ingredient.quantityUnit);
    _nameController.text = ingredient.displayName;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final catalogRepo = ref.read(catalogRepositoryProvider);
    final categories = await catalogRepo.getCategories();
    CatalogItem? linkedItem;
    if (widget.ingredient.catalogItemId != null) {
      linkedItem =
          await catalogRepo.getById(widget.ingredient.catalogItemId!);
    }
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _selectedCatalogItem = linkedItem;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _quantityController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    setState(() {
      _selectedCatalogItem = null;
      _addToCatalog = false;
      _errorText = null;
    });
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.autocompleteDebounceMs),
      () async {
        if (value.trim().isEmpty) {
          if (mounted) setState(() => _suggestions = []);
          return;
        }
        final results =
            await ref.read(catalogRepositoryProvider).search(value);
        if (mounted) setState(() => _suggestions = results);
      },
    );
  }

  void _selectCatalogItem(CatalogItem item) {
    setState(() {
      _nameController.text = item.displayName;
      _selectedCatalogItem = item;
      _addToCatalog = false;
      _suggestions = [];
      _errorText = null;
    });
  }

  String? _canonicalUnit(String? raw) {
    if (raw == null) return null;
    const parser = IngredientParserService();
    final parsed = parser.parse('1 $raw placeholder');
    final normalized = parsed.quantityUnit ?? raw;
    return QuantityUnits.all.contains(normalized)
        ? normalized
        : QuantityUnits.count;
  }

  double? _parseQuantity(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final direct = double.tryParse(trimmed);
    if (direct != null) return direct;
    return const IngredientParserService()
        .parse('$trimmed count placeholder')
        .quantityValue;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final qtyRaw = _quantityController.text.trim();
    final hasQty = qtyRaw.isNotEmpty;
    final hasUnit = _selectedUnit != null;

    if (name.isEmpty) {
      setState(() => _errorText = 'Ingredient name is required');
      return;
    }
    if (hasQty != hasUnit) {
      setState(
        () => _errorText = 'Set both quantity and unit, or leave both empty',
      );
      return;
    }

    double? quantityValue;
    String? quantityUnit;
    if (hasQty && hasUnit) {
      quantityValue = _parseQuantity(qtyRaw);
      quantityUnit = _selectedUnit;
      if (quantityValue == null) {
        setState(() => _errorText = 'Invalid quantity');
        return;
      }
    }

    final catalogRepo = ref.read(catalogRepositoryProvider);
    CatalogItem? catalogItem = _selectedCatalogItem;

    if (catalogItem == null && _addToCatalog) {
      catalogItem = await catalogRepo.getOrCreate(
        displayName: name,
        categoryId: _categoryId,
        isUserAdded: true,
      );
    }

    final mealRepo = ref.read(mealRepositoryProvider);
    await mealRepo.updateIngredient(
      id: widget.ingredient.id,
      displayName: name,
      catalogItemId: catalogItem?.id,
      clearCatalogItem: catalogItem == null,
      quantityValue: quantityValue,
      quantityUnit: quantityUnit,
      clearQuantity: !hasQty && !hasUnit,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _clearQuantity() {
    setState(() {
      _quantityController.clear();
      _selectedUnit = null;
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final originalLine = formatMealIngredient(
      displayName: widget.ingredient.displayName,
      quantityValue: widget.ingredient.quantityValue,
      quantityUnit: widget.ingredient.quantityUnit,
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: keyboardAwareSheetPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Edit ingredient',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                suffixIcon: _quantityController.text.isNotEmpty
                                    ? IconButton(
                                        tooltip: 'Clear quantity',
                                        icon: const Icon(Icons.clear),
                                        onPressed: _clearQuantity,
                                      )
                                    : null,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d./½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]'),
                                ),
                              ],
                              onChanged: (_) =>
                                  setState(() => _errorText = null),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String?>(
                              value: _selectedUnit,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('None'),
                                ),
                                ...QuantityUnits.all.map(
                                  (u) => DropdownMenuItem<String?>(
                                    value: u,
                                    child: Text(QuantityUnits.label(u)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnit = value;
                                  _errorText = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      IngredientCatalogNameField(
                        controller: _nameController,
                        categories: _categories,
                        suggestions: _suggestions,
                        addToCatalog: _addToCatalog,
                        categoryId: _categoryId,
                        matchedCatalogItem: _selectedCatalogItem,
                        originalLine: originalLine,
                        onNameChanged: _onNameChanged,
                        onCatalogSelected: _selectCatalogItem,
                        onAddToCatalogChanged: (value) {
                          setState(() {
                            _addToCatalog = value ?? false;
                            if (_addToCatalog) {
                              _selectedCatalogItem = null;
                            }
                          });
                        },
                        onCategoryChanged: (value) {
                          if (value != null) {
                            setState(() => _categoryId = value);
                          }
                        },
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _loading ? null : _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
