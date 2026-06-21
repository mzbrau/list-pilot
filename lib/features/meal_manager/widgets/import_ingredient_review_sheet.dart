import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/keyboard_inset_padding.dart';
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

class _DraftEntry {
  _DraftEntry({
    required this.id,
    required ImportIngredientDraft draft,
  })  : draft = ImportIngredientDraft(
          parsed: draft.parsed,
          confidence: draft.confidence,
          catalogItem: draft.catalogItem,
          displayName: draft.displayName,
          addToCatalog: draft.addToCatalog,
          categoryId: draft.categoryId,
        ),
        controller = TextEditingController(text: draft.displayName);

  final String id;
  final ImportIngredientDraft draft;
  final TextEditingController controller;

  void dispose() => controller.dispose();
}

class _ImportIngredientReviewSheetState
    extends ConsumerState<ImportIngredientReviewSheet> {
  late List<_DraftEntry> _entries;
  List<Category> _categories = [];
  Timer? _debounce;
  List<CatalogItem> _typingSuggestions = [];
  String? _activeEntryId;
  final _proactiveSuggestions = <String, List<CatalogItem>>{};
  var _nextEntryId = 0;

  @override
  void initState() {
    super.initState();
    _entries = widget.drafts
        .map((d) => _DraftEntry(id: '${_nextEntryId++}', draft: d))
        .toList();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final categories = await ref.read(catalogRepositoryProvider).getCategories();
    final matcher = ref.read(ingredientCatalogMatcherProvider);
    final suggestions = <String, List<CatalogItem>>{};

    for (final entry in _entries) {
      if (entry.draft.confidence == IngredientMatchConfidence.unmatched) {
        suggestions[entry.id] =
            await matcher.suggestMatches(entry.draft.displayName);
      }
    }

    if (mounted) {
      setState(() {
        _categories = categories;
        _proactiveSuggestions
          ..clear()
          ..addAll(suggestions);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  List<_DraftEntry> get _unmatchedEntries => _entries
      .where((e) => e.draft.confidence == IngredientMatchConfidence.unmatched)
      .toList();

  _DraftEntry? _entryById(String id) {
    for (final entry in _entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  void _onNameChanged(String entryId, String value) {
    final entry = _entryById(entryId);
    if (entry == null) return;

    setState(() => entry.draft.displayName = value);
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.autocompleteDebounceMs),
      () async {
        if (value.trim().isEmpty) {
          if (mounted) setState(() => _typingSuggestions = []);
          return;
        }
        final results =
            await ref.read(catalogRepositoryProvider).search(value);
        if (mounted) {
          setState(() {
            _typingSuggestions = results;
            _activeEntryId = entryId;
          });
        }
      },
    );
  }

  void _selectCatalogItem(String entryId, CatalogItem item) {
    final entry = _entryById(entryId);
    if (entry == null) return;

    setState(() {
      entry.draft.displayName = item.displayName;
      entry.draft.catalogItem = item;
      entry.draft.confidence = IngredientMatchConfidence.matched;
      entry.draft.addToCatalog = false;
      entry.controller.text = item.displayName;
      _typingSuggestions = [];
      _activeEntryId = null;
      _proactiveSuggestions.remove(entryId);
    });
  }

  void _removeDraft(String entryId) {
    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index == -1) return;

    setState(() {
      if (_activeEntryId == entryId) {
        _typingSuggestions = [];
        _activeEntryId = null;
      }
      _proactiveSuggestions.remove(entryId);
      _entries[index].dispose();
      _entries.removeAt(index);
    });
  }

  Future<void> _confirm() async {
    final catalogRepo = ref.read(catalogRepositoryProvider);
    for (final entry in _entries) {
      final draft = entry.draft;
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

    final result = _entries
        .map((e) => e.draft)
        .where((d) => d.displayName.trim().isNotEmpty)
        .toList();

    if (!mounted) return;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unmatched = _unmatchedEntries;
    final matchedCount = _entries.length - unmatched.length;

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
                    for (final entry in unmatched) ...[
                      _UnmatchedRow(
                        entry: entry,
                        categories: _categories,
                        matchSuggestions:
                            _proactiveSuggestions[entry.id] ?? const [],
                        typingSuggestions: _activeEntryId == entry.id
                            ? _typingSuggestions
                            : const [],
                        onRemove: () => _removeDraft(entry.id),
                        onNameChanged: (value) =>
                            _onNameChanged(entry.id, value),
                        onCatalogSelected: (item) =>
                            _selectCatalogItem(entry.id, item),
                        onAddToCatalogChanged: (value) {
                          setState(
                            () => entry.draft.addToCatalog = value ?? false,
                          );
                        },
                        onCategoryChanged: (value) {
                          if (value != null) {
                            setState(() => entry.draft.categoryId = value);
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
    required this.entry,
    required this.categories,
    required this.matchSuggestions,
    required this.typingSuggestions,
    required this.onRemove,
    required this.onNameChanged,
    required this.onCatalogSelected,
    required this.onAddToCatalogChanged,
    required this.onCategoryChanged,
  });

  final _DraftEntry entry;
  final List<Category> categories;
  final List<CatalogItem> matchSuggestions;
  final List<CatalogItem> typingSuggestions;
  final VoidCallback onRemove;
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
          controller: entry.controller,
          categories: categories,
          suggestions: typingSuggestions,
          matchSuggestions: matchSuggestions,
          addToCatalog: entry.draft.addToCatalog,
          categoryId: entry.draft.categoryId,
          originalLine: entry.draft.parsed.originalLine,
          onRemove: onRemove,
          onNameChanged: onNameChanged,
          onCatalogSelected: onCatalogSelected,
          onAddToCatalogChanged: onAddToCatalogChanged,
          onCategoryChanged: onCategoryChanged,
        ),
      ),
    );
  }
}
