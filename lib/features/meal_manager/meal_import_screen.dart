import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../meal_planning/widgets/meal_detail_header.dart';
import '../meal_planning/widgets/meal_detail_ingredients_tab.dart';
import '../meal_planning/widgets/meal_detail_other_tab.dart';
import '../meal_planning/widgets/meal_detail_steps_tab.dart';

class MealImportScreen extends ConsumerStatefulWidget {
  const MealImportScreen({super.key});

  @override
  ConsumerState<MealImportScreen> createState() => _MealImportScreenState();
}

class _MealImportScreenState extends ConsumerState<MealImportScreen>
    with SingleTickerProviderStateMixin {
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _portionsController = TextEditingController(text: '4');
  final _recipeController = TextEditingController();
  late TabController _tabController;
  bool _importing = false;
  bool _hasPreview = false;
  List<String> _ingredients = [];
  List<String> _steps = [];
  List<String> _tags = [];
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _portionsController.dispose();
    _recipeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _importing = true);
    try {
      final result =
          await ref.read(mealImportServiceProvider).importFromUrl(url);
      setState(() {
        _hasPreview = true;
        _nameController.text = result.name;
        _notesController.text = result.notes ?? '';
        _recipeController.text = result.recipeUrl ?? url;
        _portionsController.text = '4';
        _ingredients = List.of(result.ingredients);
        _steps = List.of(result.steps);
        _tags = List.of(result.tags);
        _imageUrl = result.imageUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final portions =
        int.tryParse(_portionsController.text.trim())?.clamp(1, 99) ?? 4;

    final meal = await ref.read(mealRepositoryProvider).createMeal(
          displayName: name,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          portions: portions,
          recipeLink: _recipeController.text.trim().isEmpty
              ? null
              : _recipeController.text.trim(),
          ingredients: _ingredients,
          steps: _steps,
          tags: _tags,
        );

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      final saved = await ref.read(mealPhotoServiceProvider).downloadAndSavePhoto(
            meal.id,
            _imageUrl!,
            referer: _recipeController.text.trim().isEmpty
                ? null
                : _recipeController.text.trim(),
          );
      if (!saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe saved, but the photo could not be downloaded.'),
          ),
        );
      }
    }

    if (mounted) {
      context.pop();
      context.push('/meal-manager/${meal.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import recipe'),
        actions: [
          if (_hasPreview)
            TextButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe URL',
                      hintText: 'https://…',
                    ),
                    keyboardType: TextInputType.url,
                    enabled: !_importing,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _importing ? null : _import,
                  child: _importing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Import'),
                ),
              ],
            ),
          ),
          if (_importing)
            const LinearProgressIndicator(),
          if (!_hasPreview)
            Expanded(
              child: Center(
                child: Text(
                  'Enter a recipe URL and tap Import',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MealDetailHeader(
                displayName: _nameController.text,
                photoPath: null,
                imageUrl: _imageUrl,
                isEditing: true,
                nameController: _nameController,
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Ingredients'),
                Tab(text: 'Steps'),
                Tab(text: 'Other'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  MealDetailIngredientsTab(
                    mealId: null,
                    isEditing: true,
                    draftIngredients: _ingredients,
                    onDraftIngredientsChanged: (value) =>
                        setState(() => _ingredients = value),
                  ),
                  MealDetailStepsTab(
                    mealId: null,
                    isEditing: true,
                    draftSteps: _steps,
                    onDraftStepsChanged: (value) =>
                        setState(() => _steps = value),
                  ),
                  MealDetailOtherTab(
                    isEditing: true,
                    tags: _tags,
                    onTagsChanged: (value) => setState(() => _tags = value),
                    notes: _notesController.text,
                    portions: int.tryParse(_portionsController.text) ?? 4,
                    recipeLink: _recipeController.text,
                    notesController: _notesController,
                    portionsController: _portionsController,
                    recipeController: _recipeController,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
