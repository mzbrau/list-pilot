import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import 'meal_plan_formatters.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  const MealDetailScreen({super.key, required this.mealId});

  final int mealId;

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _portionsController = TextEditingController();
  final _recipeController = TextEditingController();
  final _ingredientController = TextEditingController();
  final _ingredientFocusNode = FocusNode();
  Timer? _debounce;
  List<CatalogItem> _suggestions = [];
  bool _showSuggestions = false;
  bool _initialized = false;
  File? _photoFile;

  @override
  void initState() {
    super.initState();
    _ingredientController.addListener(_onIngredientTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _notesController.dispose();
    _portionsController.dispose();
    _recipeController.dispose();
    _ingredientController.dispose();
    _ingredientFocusNode.dispose();
    super.dispose();
  }

  void _initFromMeal(Meal meal) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = meal.displayName;
    _notesController.text = meal.notes ?? '';
    _portionsController.text = meal.portions.toString();
    _recipeController.text = meal.recipeLink ?? '';
    _loadPhoto(meal);
  }

  Future<void> _loadPhoto(Meal meal) async {
    if (meal.photoPath == null) return;
    final file = await ref
        .read(mealPhotoServiceProvider)
        .resolvePhotoFile(meal.photoPath);
    if (mounted) setState(() => _photoFile = file);
  }

  Future<void> _save(Meal meal) async {
    final repo = ref.read(mealRepositoryProvider);
    final name = _nameController.text.trim();
    final portions = int.tryParse(_portionsController.text.trim()) ?? meal.portions;
    final notes = _notesController.text.trim();
    final recipe = _recipeController.text.trim();

    await repo.updateMeal(
      id: meal.id,
      displayName: name.isNotEmpty ? name : meal.displayName,
      notes: notes,
      clearNotes: notes.isEmpty,
      portions: portions.clamp(1, 99),
      recipeLink: recipe,
      clearRecipeLink: recipe.isEmpty,
    );
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

    await ref.read(mealRepositoryProvider).addIngredient(
          mealId: widget.mealId,
          displayName: displayName,
          catalogItemId: catalogItem?.id,
        );

    _ingredientController.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  Future<void> _pickPhoto(Meal meal) async {
    final file = await ref
        .read(mealPhotoServiceProvider)
        .pickAndSavePhoto(meal.id);
    if (mounted) setState(() => _photoFile = file);
  }

  Future<void> _removePhoto(Meal meal) async {
    await ref.read(mealPhotoServiceProvider).removePhoto(meal.id);
    if (mounted) setState(() => _photoFile = null);
  }

  Future<void> _openRecipe(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _deleteMeal(Meal meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete meal?'),
        content: Text(
          'Remove "${meal.displayName}" and all its ingredients and history?',
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
    if (confirmed != true) return;

    await ref.read(mealRepositoryProvider).deleteMeal(meal.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final mealAsync = ref.watch(mealProvider(widget.mealId));
    final ingredientsAsync = ref.watch(mealIngredientsProvider(widget.mealId));
    final lastEatenAsync = ref.watch(lastEatenDateProvider(widget.mealId));
    final theme = Theme.of(context);

    return mealAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (meal) {
        if (meal == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Meal not found')),
          );
        }

        _initFromMeal(meal);

        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) _save(meal);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Meal details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteMeal(meal),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => _showPhotoOptions(meal),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _photoFile != null
                              ? Image.file(
                                  _photoFile!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 200,
                                  height: 200,
                                  color: theme.colorScheme
                                      .surfaceContainerHighest,
                                  child: Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 48,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => _showPhotoOptions(meal),
                    child: Text(
                      _photoFile != null ? 'Change photo' : 'Add photo',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                lastEatenAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (lastEaten) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      formatLastEatenSummary(lastEaten),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => _save(meal),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _portionsController,
                  decoration: const InputDecoration(
                    labelText: 'Portions',
                    helperText: 'Number of people this meal normally feeds',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _save(meal),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => _save(meal),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _recipeController,
                  decoration: InputDecoration(
                    labelText: 'Recipe link',
                    suffixIcon: _recipeController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () =>
                                _openRecipe(_recipeController.text.trim()),
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (_) {
                    setState(() {});
                    _save(meal);
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Ingredients',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ingredientsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Error: $e'),
                  data: (ingredients) {
                    if (ingredients.isEmpty) {
                      return Text(
                        'No ingredients yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    return Column(
                      children: ingredients.map((ingredient) {
                        return Card(
                          child: ListTile(
                            title: Text(ingredient.displayName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: ingredient.addToShoppingList,
                                  onChanged: (value) {
                                    ref
                                        .read(mealRepositoryProvider)
                                        .updateIngredient(
                                          id: ingredient.id,
                                          addToShoppingList: value,
                                        );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => ref
                                      .read(mealRepositoryProvider)
                                      .deleteIngredient(ingredient.id),
                                ),
                              ],
                            ),
                            subtitle: const Text('Add to shopping list'),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPhotoOptions(Meal meal) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(meal);
              },
            ),
            if (_photoFile != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto(meal);
                },
              ),
          ],
        ),
      ),
    );
  }
}
