import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import 'meal_plan_formatters.dart';
import 'widgets/meal_detail_header.dart';
import 'widgets/meal_detail_ingredients_tab.dart';
import 'widgets/meal_detail_other_tab.dart';
import 'widgets/meal_detail_steps_tab.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  const MealDetailScreen({
    super.key,
    required this.mealId,
    this.initialEditMode = false,
    this.fromMealManager = false,
  });

  final int mealId;
  final bool initialEditMode;
  final bool fromMealManager;

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _stepsTabKey = GlobalKey<MealDetailStepsTabState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _portionsController = TextEditingController();
  final _recipeController = TextEditingController();
  bool _isEditing = false;
  bool _initialized = false;
  List<String> _tags = [];
  File? _photoFile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isEditing = widget.initialEditMode;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _portionsController.dispose();
    _recipeController.dispose();
    super.dispose();
  }

  void _initFromMeal(Meal meal, List<MealTag> tags) {
    if (_initialized && !_isEditing) return;
    if (!_initialized) {
      _initialized = true;
      _nameController.text = meal.displayName;
      _notesController.text = meal.notes ?? '';
      _portionsController.text = meal.portions.toString();
      _recipeController.text = meal.recipeLink ?? '';
      _tags = tags.map((t) => t.displayName).toList();
      _loadPhoto(meal);
    }
  }

  Future<void> _loadPhoto(Meal meal) async {
    if (meal.photoPath == null) {
      if (mounted) setState(() => _photoFile = null);
      return;
    }
    final file = await ref
        .read(mealPhotoServiceProvider)
        .resolvePhotoFile(meal.photoPath);
    if (mounted) setState(() => _photoFile = file);
  }

  void _reloadFromMeal(Meal meal, List<MealTag> tags) {
    _nameController.text = meal.displayName;
    _notesController.text = meal.notes ?? '';
    _portionsController.text = meal.portions.toString();
    _recipeController.text = meal.recipeLink ?? '';
    _tags = tags.map((t) => t.displayName).toList();
    _loadPhoto(meal);
  }

  Future<void> _save(Meal meal) async {
    final repo = ref.read(mealRepositoryProvider);
    final name = _nameController.text.trim();
    final portions =
        int.tryParse(_portionsController.text.trim()) ?? meal.portions;
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
    await repo.setMealTags(meal.id, _tags);
  }

  void _startEditing() {
    setState(() => _isEditing = true);
  }

  void _cancelEditing(Meal meal, List<MealTag> tags) {
    _reloadFromMeal(meal, tags);
    setState(() => _isEditing = false);
  }

  Future<void> _finishEditing(Meal meal) async {
    await _stepsTabKey.currentState?.savePendingChanges();
    await _save(meal);
    if (mounted) setState(() => _isEditing = false);
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

  Future<void> _addMealToPlan(Meal meal) async {
    final mealPlanningEnabled = ref.read(mealPlanningEnabledProvider);
    if (!mealPlanningEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enable Meal Planning in settings to add meals to your plan',
          ),
        ),
      );
      return;
    }

    await ref.read(mealRepositoryProvider).addMealToPlan(meal.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${meal.displayName}" to meal plan'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.push('/meals'),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final mealAsync = ref.watch(mealProvider(widget.mealId));
    final tagsAsync = ref.watch(mealTagsProvider(widget.mealId));
    final lastEatenAsync = ref.watch(lastEatenDateProvider(widget.mealId));

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

        return tagsAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Error: $e')),
          ),
          data: (tags) {
            _initFromMeal(meal, tags);

            final lastEatenSummary = lastEatenAsync.maybeWhen(
              data: (d) => formatLastEatenSummary(d),
              orElse: () => null,
            );
            final mealPlanningEnabled = ref.watch(mealPlanningEnabledProvider);

            return Scaffold(
              appBar: AppBar(
                title: Text(_isEditing ? 'Edit meal' : meal.displayName),
                actions: [
                  if (widget.fromMealManager &&
                      mealPlanningEnabled &&
                      !_isEditing)
                    IconButton(
                      icon: const Icon(Icons.playlist_add_outlined),
                      tooltip: 'Add to meal plan',
                      onPressed: () => _addMealToPlan(meal),
                    ),
                  if (_isEditing) ...[
                    TextButton(
                      onPressed: () => _cancelEditing(meal, tags),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => _finishEditing(meal),
                      child: const Text('Save'),
                    ),
                  ] else
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                      onPressed: _startEditing,
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteMeal(meal),
                  ),
                ],
              ),
              body: NestedScrollView(
                physics: const ClampingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: MealDetailHeader(
                        displayName: meal.displayName,
                        photoPath: meal.photoPath,
                        photoFile: _photoFile,
                        lastEatenSummary: lastEatenSummary,
                        isEditing: _isEditing,
                        nameController: _nameController,
                        onPhotoTap: () => _showPhotoOptions(meal),
                      ),
                    ),
                  ),
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
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
                    MealDetailIngredientsTab(
                      mealId: widget.mealId,
                      isEditing: _isEditing,
                      nestedScroll: true,
                    ),
                    MealDetailStepsTab(
                      key: _stepsTabKey,
                      mealId: widget.mealId,
                      isEditing: _isEditing,
                      nestedScroll: true,
                    ),
                    MealDetailOtherTab(
                      isEditing: _isEditing,
                      tags: _isEditing
                          ? _tags
                          : tags.map((t) => t.displayName).toList(),
                      onTagsChanged: (value) =>
                          setState(() => _tags = value),
                      notes: meal.notes ?? '',
                      portions: meal.portions,
                      recipeLink: meal.recipeLink,
                      notesController: _notesController,
                      portionsController: _portionsController,
                      recipeController: _recipeController,
                      nestedScroll: true,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
