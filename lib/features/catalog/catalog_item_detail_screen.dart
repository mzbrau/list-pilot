import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/catalog_repository.dart';

class CatalogItemDetailScreen extends ConsumerStatefulWidget {
  const CatalogItemDetailScreen({
    super.key,
    required this.itemId,
  });

  final int itemId;

  @override
  ConsumerState<CatalogItemDetailScreen> createState() =>
      _CatalogItemDetailScreenState();
}

class _CatalogItemDetailScreenState
    extends ConsumerState<CatalogItemDetailScreen> {
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
  String? _selectedCategoryId;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  void _initFromItem(CatalogItem item) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = item.displayName;
    _selectedCategoryId = item.categoryId;
  }

  void _invalidateCatalog() {
    ref.invalidate(allCatalogItemsProvider);
    ref.invalidate(catalogItemProvider(widget.itemId));
    ref.invalidate(catalogItemAliasesProvider(widget.itemId));
  }

  Future<void> _save(CatalogItem item) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await ref.read(catalogRepositoryProvider).updateCatalogItem(
          id: item.id,
          displayName: name,
          categoryId: _selectedCategoryId,
        );
    _invalidateCatalog();
  }

  Future<void> _addAlias(CatalogItem item) async {
    final alias = _aliasController.text.trim();
    if (alias.isEmpty) return;

    try {
      await ref.read(catalogRepositoryProvider).addAlias(
            catalogItemId: item.id,
            alias: alias,
          );
      _aliasController.clear();
      _invalidateCatalog();
    } on CatalogAliasConflictException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _deleteAlias(CatalogItemAlias alias) async {
    await ref.read(catalogRepositoryProvider).deleteAlias(alias.id);
    _invalidateCatalog();
  }

  Future<void> _deleteItem(CatalogItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete catalog item?'),
        content: Text(
          item.isUserAdded
              ? 'Remove "${item.displayName}" from the catalog permanently?'
              : 'Remove "${item.displayName}" from the catalog? '
                  'Built-in items will not be restored on future updates.',
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

    await ref.read(catalogRepositoryProvider).deleteCatalogItem(item.id);
    _invalidateCatalog();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(catalogItemProvider(widget.itemId));
    final aliasesAsync = ref.watch(catalogItemAliasesProvider(widget.itemId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return itemAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Item not found')),
          );
        }

        _initFromItem(item);

        return PopScope(
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) await _save(item);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Catalog item'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteItem(item),
                ),
              ],
            ),
            body: categoriesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (categories) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item name',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => _save(item),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                        _save(item);
                      },
                    ),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Source',
                      ),
                      child: Text(
                        item.isUserAdded ? 'Custom item' : 'Built-in catalog',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Aliases',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alternative names used when matching recipe ingredients '
                      'to this catalog item.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    aliasesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                      data: (aliases) {
                        if (aliases.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'No aliases yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            for (final alias in aliases)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(alias.alias),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  tooltip: 'Remove alias',
                                  onPressed: () => _deleteAlias(alias),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _aliasController,
                            decoration: const InputDecoration(
                              labelText: 'New alias',
                              hintText: 'e.g. bell peppers',
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _addAlias(item),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => _addAlias(item),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () => _deleteItem(item),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete catalog item'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
