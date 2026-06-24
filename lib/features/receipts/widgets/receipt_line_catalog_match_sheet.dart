import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/keyboard_inset_padding.dart';
import '../../../data/database/app_database.dart';

class ReceiptLineCatalogMatchSheet extends ConsumerStatefulWidget {
  const ReceiptLineCatalogMatchSheet({
    super.key,
    required this.line,
  });

  final ReceiptLine line;

  static Future<void> show(
    BuildContext context, {
    required ReceiptLine line,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ReceiptLineCatalogMatchSheet(line: line),
    );
  }

  @override
  ConsumerState<ReceiptLineCatalogMatchSheet> createState() =>
      _ReceiptLineCatalogMatchSheetState();
}

class _ReceiptLineCatalogMatchSheetState
    extends ConsumerState<ReceiptLineCatalogMatchSheet> {
  late final TextEditingController _searchController;
  List<CatalogItem> _suggestions = [];
  List<CatalogItem> _matchSuggestions = [];
  Timer? _debounce;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.line.englishName);
    _loadSuggestions();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadSuggestions() async {
    final matcher = ref.read(ingredientCatalogMatcherProvider);
    final suggestions = await matcher.suggestMatches(widget.line.englishName);
    if (mounted) {
      setState(() => _matchSuggestions = suggestions);
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.autocompleteDebounceMs),
      () async {
        final query = _searchController.text.trim();
        if (query.isEmpty) {
          if (mounted) setState(() => _suggestions = []);
          return;
        }
        final results =
            await ref.read(catalogRepositoryProvider).search(query);
        if (mounted) setState(() => _suggestions = results);
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _applyMatch(CatalogItem item) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(receiptRepositoryProvider).updateLineCatalogMatch(
            lineId: widget.line.id,
            catalogItemId: item.id,
            englishName: item.displayName,
            categoryId: item.categoryId,
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _unmatch() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(receiptRepositoryProvider).updateLineCatalogMatch(
            lineId: widget.line.id,
            catalogItemId: null,
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchedCatalogAsync = widget.line.catalogItemId != null
        ? ref.watch(catalogItemProvider(widget.line.catalogItemId!))
        : null;
    final matchedName = matchedCatalogAsync?.valueOrNull?.displayName;

    return Padding(
      padding: keyboardAwareSheetPadding(context),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Catalog match', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            if (widget.line.originalDescription != widget.line.englishName)
              Text(
                'Original: ${widget.line.originalDescription}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (matchedName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Currently matched: $matchedName',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search catalog',
                prefixIcon: Icon(Icons.search),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            if (_matchSuggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Suggestions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in _matchSuggestions)
                    ActionChip(
                      label: Text(item.displayName),
                      onPressed: _saving ? null : () => _applyMatch(item),
                    ),
                ],
              ),
            ],
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final item = _suggestions[index];
                    return ListTile(
                      title: Text(item.displayName),
                      onTap: _saving ? null : () => _applyMatch(item),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.line.catalogItemId != null)
                  TextButton(
                    onPressed: _saving ? null : _unmatch,
                    child: const Text('Unmatch'),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      );
  }
}
