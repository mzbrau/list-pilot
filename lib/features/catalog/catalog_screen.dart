import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../router/navigation_helpers.dart';
import 'widgets/add_catalog_item_sheet.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  List<CatalogItem>? _searchResults;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.autocompleteDebounceMs),
      () async {
        final query = _searchController.text;
        if (query.trim().isEmpty) {
          if (mounted) {
            setState(() {
              _searchQuery = '';
              _searchResults = null;
              _searching = false;
            });
          }
          return;
        }

        if (mounted) setState(() => _searching = true);
        final results = await ref
            .read(catalogRepositoryProvider)
            .search(query, limit: 500);
        if (mounted) {
          setState(() {
            _searchQuery = query;
            _searchResults = results;
            _searching = false;
          });
        }
      },
    );
  }

  Map<String, List<CatalogItem>> _groupItems({
    required List<CatalogItem> items,
    required List<Category> categories,
  }) {
    final categoryNames = {
      for (final category in categories) category.id: category.name,
    };
    final categoryOrder = {
      for (var i = 0; i < categories.length; i++) categories[i].id: i,
    };

    final grouped = <String, List<CatalogItem>>{};
    for (final item in items) {
      final categoryName = categoryNames[item.categoryId] ?? 'Other';
      grouped.putIfAbsent(categoryName, () => []).add(item);
    }

    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => a.displayName.compareTo(b.displayName));
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final aId = categories
            .firstWhere(
              (c) => c.name == a.key,
              orElse: () => categories.last,
            )
            .id;
        final bId = categories
            .firstWhere(
              (c) => c.name == b.key,
              orElse: () => categories.last,
            )
            .id;
        return (categoryOrder[aId] ?? 999).compareTo(categoryOrder[bId] ?? 999);
      });

    return Map.fromEntries(sortedEntries);
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(allCatalogItemsProvider);
    final theme = Theme.of(context);

    return popOrGoHomeScope(
      child: Scaffold(
        appBar: AppBar(
          leading: overviewBackButton(context),
          title: const Text('Shopping catalog'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => AddCatalogItemSheet.show(context),
          icon: const Icon(Icons.add),
          label: const Text('Add item'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search items or aliases…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                ),
              ),
            ),
            Expanded(
              child: catalogAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (overview) {
                  final items = _searchQuery.trim().isEmpty
                      ? overview.items
                      : (_searchResults ?? []);
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _searchQuery.trim().isEmpty
                              ? 'No catalog items yet'
                              : 'No items match your search',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }

                  final grouped = _groupItems(
                    items: items,
                    categories: overview.categories,
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: _listItemCount(grouped),
                    itemBuilder: (context, index) {
                      var itemIndex = index;
                      for (final entry in grouped.entries) {
                        if (itemIndex == 0) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  theme.colorScheme.primaryContainer,
                                  theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                            child: Text(
                              '${entry.key} (${entry.value.length})',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          );
                        }
                        itemIndex--;

                        for (final item in entry.value) {
                          if (itemIndex == 0) {
                            final aliasCount =
                                overview.aliasCounts[item.id] ?? 0;
                            return ListTile(
                              title: Text(item.displayName),
                              subtitle: aliasCount > 0
                                  ? Text(
                                      '$aliasCount '
                                      '${aliasCount == 1 ? 'alias' : 'aliases'}',
                                    )
                                  : null,
                              trailing: Chip(
                                label: Text(
                                  item.isUserAdded ? 'Custom' : 'Built-in',
                                  style: theme.textTheme.labelSmall,
                                ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              onTap: () =>
                                  context.push('/catalog/${item.id}'),
                            );
                          }
                          itemIndex--;
                        }
                      }
                      return null;
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _listItemCount(Map<String, List<CatalogItem>> grouped) {
    var count = 0;
    for (final entry in grouped.entries) {
      count += 1 + entry.value.length;
    }
    return count;
  }
}
