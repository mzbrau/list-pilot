import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/ingredient_catalog_matcher.dart';
import '../../meal_planning/widgets/ingredient_catalog_name_field.dart';

class ImportIngredientReviewSheet extends ConsumerStatefulWidget {
  const ImportIngredientReviewSheet({
    super.key,
    required this.drafts,
  });

  final List<ImportIngredientDraft> drafts;

  static Future<List<ImportIngredientDraft>?> show(
    BuildContext context, {
    required List<ImportIngredientDraft> drafts,
  }) {
    return showModalBottomSheet<List<ImportIngredientDraft>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ImportIngredientReviewSheet(
        drafts: drafts,
      ),
    );
  }

  @override
  ConsumerState<ImportIngredientReviewSheet> createState() =>
      _ImportIngredientReviewSheetState();
}

class _ImportIngredientReviewSheetState
    extends ConsumerState<ImportIngredientReviewSheet> {
  late List<ImportIngredientDraft> _drafts;
  List<Category> _categories = [];
  final _controllers = <int, TextEditingController>{};
  Timer? _debounce;
  List<CatalogItem> _suggestions = [];
  int? _activeDraftIndex;

  @override
  void initState() {
    super.initState();
    _drafts = widget.drafts
        .map(
          (d) => ImportIngredientDraft(
            parsed: d.parsed,
            confidence: d.confidence,
            catalogItem: d.catalogItem,
            displayName: d.displayName,
            addToCatalog: d.addToCatalog,
            categoryId: d.categoryId,
          ),
        )
        .toList();
    _loadCategories();
    for (var i = 0; i < _drafts.length; i++) {
      _controllers[i] = TextEditingController(text: _drafts[i].displayName);
    }
  }

  Future<void> _loadCategories() async {
    final categories = await ref.read(catalogRepositoryProvider).getCategories();
    if (mounted) setState(() => _categories = categories);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<ImportIngredientDraft> get _unmatched =>
      _drafts.where((d) => d.confidence == IngredientMatchConfidence.unmatched).toList();

  void _onNameChanged(int index, String value) {
    setState(() => _drafts[index].displayName = value);
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
        if (mounted) {
          setState(() {
            _suggestions = results;
            _activeDraftIndex = index;
          });
        }
      },
    );
  }

  void _selectCatalogItem(int index, CatalogItem item) {
    setState(() {
      _drafts[index].displayName = item.displayName;
      _drafts[index].catalogItem = item;
      _drafts[index].confidence = IngredientMatchConfidence.matched;
      _drafts[index].addToCatalog = false;
      _controllers[index]?.text = item.displayName;
      _suggestions = [];
      _activeDraftIndex = null;
    });
  }

  Future<void> _confirm() async {
    final catalogRepo = ref.read(catalogRepositoryProvider);
    for (final draft in _drafts) {
      if (draft.addToCatalog && draft.catalogItem == null) {
        final name = draft.displayName.trim();
        if (name.isEmpty) continue;
        final item = await catalogRepo.getOrCreate(
          displayName: name,
          categoryId: draft.categoryId,
          isUserAdded: true,
        );
        draft.catalogItem = item;
        draft.displayName = item.displayName;
        draft.confidence = IngredientMatchConfidence.matched;
      }
    }
    if (!mounted) return;
    Navigator.pop(context, _drafts);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unmatched = _unmatched;
    final matchedCount = _drafts.length - unmatched.length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Review ingredients',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '$matchedCount matched · ${unmatched.length} need review',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final draft in unmatched) ...[
                      _UnmatchedRow(
                        draft: draft,
                        controller: _controllers[_drafts.indexOf(draft)]!,
                        categories: _categories,
                        suggestions: _activeDraftIndex == _drafts.indexOf(draft)
                            ? _suggestions
                            : const [],
                        onNameChanged: (value) =>
                            _onNameChanged(_drafts.indexOf(draft), value),
                        onCatalogSelected: (item) =>
                            _selectCatalogItem(_drafts.indexOf(draft), item),
                        onAddToCatalogChanged: (value) {
                          setState(() => draft.addToCatalog = value ?? false);
                        },
                        onCategoryChanged: (value) {
                          if (value != null) {
                            setState(() => draft.categoryId = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              FilledButton(
                onPressed: _confirm,
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UnmatchedRow extends StatelessWidget {
  const _UnmatchedRow({
    required this.draft,
    required this.controller,
    required this.categories,
    required this.suggestions,
    required this.onNameChanged,
    required this.onCatalogSelected,
    required this.onAddToCatalogChanged,
    required this.onCategoryChanged,
  });

  final ImportIngredientDraft draft;
  final TextEditingController controller;
  final List<Category> categories;
  final List<CatalogItem> suggestions;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<CatalogItem> onCatalogSelected;
  final ValueChanged<bool?> onAddToCatalogChanged;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: IngredientCatalogNameField(
          controller: controller,
          categories: categories,
          suggestions: suggestions,
          addToCatalog: draft.addToCatalog,
          categoryId: draft.categoryId,
          originalLine: draft.parsed.originalLine,
          onNameChanged: onNameChanged,
          onCatalogSelected: onCatalogSelected,
          onAddToCatalogChanged: onAddToCatalogChanged,
          onCategoryChanged: onCategoryChanged,
        ),
      ),
    );
  }
}
