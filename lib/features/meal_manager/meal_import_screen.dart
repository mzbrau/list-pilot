import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/services/ingredient_catalog_matcher.dart';
import '../../data/services/meal_import_service.dart';
import '../meal_planning/widgets/meal_detail_header.dart';
import '../meal_planning/widgets/meal_detail_other_tab.dart';
import '../meal_planning/widgets/meal_detail_steps_tab.dart';
import '../meal_planning/widgets/meal_ingredient_line_text.dart';
import 'widgets/import_ingredient_review_sheet.dart';

enum MealImportMode { ai, extract, photo }

class MealImportScreen extends ConsumerStatefulWidget {
  const MealImportScreen({super.key, this.mode = MealImportMode.ai});

  final MealImportMode mode;

  @override
  ConsumerState<MealImportScreen> createState() => _MealImportScreenState();
}

class _MealImportScreenState extends ConsumerState<MealImportScreen>
    with SingleTickerProviderStateMixin {
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _portionsController = TextEditingController(text: '4');
  final _prepTimeController = TextEditingController();
  final _recipeController = TextEditingController();
  final _ingredientController = TextEditingController();
  late TabController _tabController;
  bool _importing = false;
  bool _hasPreview = false;
  List<ImportIngredientDraft> _ingredientDrafts = [];
  List<String> _steps = [];
  List<String> _tags = [];
  String? _imageUrl;
  File? _pickedPhotoFile;

  bool get _isPhotoMode => widget.mode == MealImportMode.photo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _urlController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _portionsController.dispose();
    _prepTimeController.dispose();
    _recipeController.dispose();
    _ingredientController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    if (_isPhotoMode) {
      final photoPath = _pickedPhotoFile?.path;
      if (photoPath == null) return;
      setState(() => _importing = true);
      try {
        final language = ref.read(recipeImportLanguageProvider);
        final result = await ref.read(mealImportServiceProvider).importFromPhoto(
              photoPath,
              language: language,
            );
        await _applyImportResult(result);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _importing = false);
      }
      return;
    }

    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _importing = true);
    try {
      final MealImportResult result;
      if (widget.mode == MealImportMode.ai) {
        final language = ref.read(recipeImportLanguageProvider);
        result = await ref.read(mealImportServiceProvider).importFromUrl(
              url,
              language: language,
            );
      } else {
        result =
            await ref.read(recipePageImportServiceProvider).importFromUrl(url);
      }
      await _applyImportResult(result, recipeUrl: result.recipeUrl ?? url);
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

  Future<void> _applyImportResult(
    MealImportResult result, {
    String? recipeUrl,
  }) async {
    final drafts = await ref
        .read(ingredientCatalogMatcherProvider)
        .matchAll(result.ingredients);
    setState(() {
      _hasPreview = true;
      _nameController.text = result.name;
      _notesController.text = result.notes ?? '';
      _recipeController.text = recipeUrl ?? result.recipeUrl ?? '';
      _portionsController.text = '4';
      _prepTimeController.text =
          result.prepTimeMinutes?.toString() ?? '';
      _ingredientDrafts = drafts;
      _steps = List.of(result.steps);
      _tags = List.of(result.tags);
      _imageUrl = _isPhotoMode ? null : result.imageUrl;
    });
  }

  void _resetPreviewDrafts() {
    _hasPreview = false;
    _ingredientDrafts = [];
    _steps = [];
    _tags = [];
    _nameController.clear();
    _notesController.clear();
    _recipeController.clear();
    _portionsController.text = '4';
    _prepTimeController.clear();
    _imageUrl = null;
  }

  Future<void> _pickPhoto({bool autoImport = true}) async {
    final file = await ref.read(mealPhotoServiceProvider).pickImageForImport();
    if (!mounted || file == null) return;
    setState(() {
      _pickedPhotoFile = file;
      _resetPreviewDrafts();
    });
    if (autoImport) {
      await _import();
    }
  }

  Future<void> _changePhotoFromReview() async {
    setState(_resetPreviewDrafts);
    await _pickPhoto();
  }

  Future<void> _addIngredientLine() async {
    final line = _ingredientController.text.trim();
    if (line.isEmpty) return;
    final draft =
        await ref.read(ingredientCatalogMatcherProvider).matchLine(line);
    setState(() {
      _ingredientDrafts = [
        ..._ingredientDrafts,
        ImportIngredientDraft(
          parsed: draft.parsed,
          confidence: draft.confidence,
          catalogItem: draft.catalogItem,
          displayName:
              draft.catalogItem?.displayName ?? draft.parsed.itemName,
        ),
      ];
      _ingredientController.clear();
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    var drafts = _ingredientDrafts;
    final hasUnmatched = drafts.any(
      (d) => d.confidence == IngredientMatchConfidence.unmatched,
    );
    if (hasUnmatched) {
      final reviewed = await ImportIngredientReviewSheet.show(
        context,
        drafts: drafts,
      );
      if (reviewed == null || !mounted) return;
      drafts = reviewed;
    }

    final portions =
        int.tryParse(_portionsController.text.trim())?.clamp(1, 99) ?? 4;
    final prepTimeText = _prepTimeController.text.trim();
    final prepTime = int.tryParse(prepTimeText);

    final meal = await ref.read(mealRepositoryProvider).createMeal(
          displayName: name,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          portions: portions,
          prepTimeMinutes: prepTime,
          recipeLink: _recipeController.text.trim().isEmpty
              ? null
              : _recipeController.text.trim(),
          ingredients: drafts.map((d) => d.toInput()).toList(),
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
    } else if (_pickedPhotoFile != null) {
      final saved = await ref.read(mealPhotoServiceProvider).savePhotoFromPath(
            meal.id,
            _pickedPhotoFile!.path,
          );
      if (!saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe saved, but the photo could not be saved.'),
          ),
        );
      }
    }

    if (mounted) {
      context.pop();
      context.push('/meal-manager/${meal.id}');
    }
  }

  List<Widget> _ingredientTabChildren(ThemeData theme) {
    return [
      TextField(
        controller: _ingredientController,
        decoration: InputDecoration(
          hintText: 'Add ingredient…',
          suffixIcon: IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addIngredientLine,
          ),
        ),
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _addIngredientLine(),
      ),
      const SizedBox(height: 8),
      if (_ingredientDrafts.isEmpty)
        Text(
          'No ingredients yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ..._ingredientDrafts.asMap().entries.map((entry) {
        final draft = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: MealIngredientLineText(
              displayName: draft.displayName,
              quantityValue: draft.parsed.quantityValue,
              quantityUnit: draft.parsed.quantityUnit,
            ),
            subtitle: draft.confidence == IngredientMatchConfidence.unmatched
                ? const Text('Needs review before save')
                : draft.catalogItem != null
                    ? Text('Matched: ${draft.catalogItem!.displayName}')
                    : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() => _ingredientDrafts.removeAt(entry.key));
              },
            ),
          ),
        );
      }),
    ];
  }

  Widget _buildIngredientsTab(ThemeData theme, {required bool nestedScroll}) {
    final children = _ingredientTabChildren(theme);

    if (!nestedScroll) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: children,
      );
    }

    return CustomScrollView(
      key: const PageStorageKey('meal-import-ingredients'),
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

  Widget _buildPhotoPicker(RecipeImportLanguage importLanguage) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_pickedPhotoFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _pickedPhotoFile!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _importing ? null : () => _pickPhoto(),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose photo'),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_pickedPhotoFile != null)
                TextButton.icon(
                  onPressed: _importing
                      ? null
                      : () => _pickPhoto(autoImport: false),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Change photo'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _importing || _pickedPhotoFile == null
                    ? null
                    : _import,
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
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: importLanguage.code,
            decoration: const InputDecoration(
              labelText: 'Import language',
            ),
            items: [
              for (final language in recipeImportLanguages)
                DropdownMenuItem(
                  value: language.code,
                  child: Text(language.label),
                ),
            ],
            onChanged: _importing
                ? null
                : (code) {
                    if (code == null) return;
                    ref
                        .read(recipeImportLanguageProvider.notifier)
                        .setLanguage(recipeImportLanguageByCode(code));
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildUrlImporter(RecipeImportLanguage importLanguage) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
          if (widget.mode == MealImportMode.ai) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: importLanguage.code,
              decoration: const InputDecoration(
                labelText: 'Import language',
              ),
              items: [
                for (final language in recipeImportLanguages)
                  DropdownMenuItem(
                    value: language.code,
                    child: Text(language.label),
                  ),
              ],
              onChanged: _importing
                  ? null
                  : (code) {
                      if (code == null) return;
                      ref
                          .read(recipeImportLanguageProvider.notifier)
                          .setLanguage(
                            recipeImportLanguageByCode(code),
                          );
                    },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyzingBody(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analyzing recipe…',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBody(ThemeData theme) {
    return NestedScrollView(
      physics: const ClampingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: MealDetailHeader(
              displayName: _nameController.text,
              photoPath: null,
              photoFile: _pickedPhotoFile,
              imageUrl: _imageUrl,
              isEditing: true,
              nameController: _nameController,
            ),
          ),
        ),
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Ingredients'),
                  Tab(text: 'Steps'),
                  Tab(text: 'Other'),
                ],
              ),
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildIngredientsTab(theme, nestedScroll: true),
          MealDetailStepsTab(
            mealId: null,
            isEditing: true,
            draftSteps: _steps,
            onDraftStepsChanged: (value) => setState(() => _steps = value),
            nestedScroll: true,
          ),
          MealDetailOtherTab(
            isEditing: true,
            tags: _tags,
            onTagsChanged: (value) => setState(() => _tags = value),
            notes: _notesController.text,
            portions: int.tryParse(_portionsController.text) ?? 4,
            prepTimeMinutes: int.tryParse(_prepTimeController.text),
            recipeLink: _recipeController.text,
            notesController: _notesController,
            portionsController: _portionsController,
            prepTimeController: _prepTimeController,
            recipeController: _recipeController,
            nestedScroll: true,
          ),
        ],
      ),
    );
  }

  String get _appBarTitle {
    if (_hasPreview && _isPhotoMode) {
      return 'Review recipe';
    }
    return switch (widget.mode) {
      MealImportMode.ai => 'Import recipe (AI)',
      MealImportMode.extract => 'Import recipe',
      MealImportMode.photo => 'Import recipe (photo)',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final importLanguage = ref.watch(recipeImportLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          if (_hasPreview && _isPhotoMode)
            IconButton(
              icon: const Icon(Icons.photo_library_outlined),
              tooltip: 'Change photo',
              onPressed: _importing ? null : _changePhotoFromReview,
            ),
          if (_hasPreview)
            TextButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
        ],
      ),
      body: _hasPreview
          ? Column(
              children: [
                if (!_isPhotoMode) ...[
                  _buildUrlImporter(importLanguage),
                  if (_importing) const LinearProgressIndicator(),
                ],
                Expanded(child: _buildPreviewBody(theme)),
              ],
            )
          : _isPhotoMode && _importing
              ? _buildAnalyzingBody(theme)
              : Column(
                  children: [
                    if (_isPhotoMode)
                      _buildPhotoPicker(importLanguage)
                    else
                      _buildUrlImporter(importLanguage),
                    if (_importing && !_isPhotoMode)
                      const LinearProgressIndicator(),
                    Expanded(
                      child: Center(
                        child: Text(
                          _isPhotoMode
                              ? 'Choose a recipe photo to import'
                              : 'Enter a recipe URL and tap Import',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
