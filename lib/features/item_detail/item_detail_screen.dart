import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.listId,
    required this.itemId,
  });

  final int listId;
  final int itemId;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedCategoryId;
  String _selectedUnit = QuantityUnits.count;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _initFromItem(ListItem item) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = item.displayName;
    _selectedCategoryId = item.categoryId;
    if (item.quantityValue != null) {
      _quantityController.text = item.quantityValue!.toString();
    }
    if (item.quantityUnit != null) {
      _selectedUnit = item.quantityUnit!;
    }
  }

  Future<void> _save(ListItem item) async {
    final repo = ref.read(listRepositoryProvider);
    final catalogRepo = ref.read(catalogRepositoryProvider);

    final name = _nameController.text.trim();
    final quantityText = _quantityController.text.trim();
    double? quantity;
    if (quantityText.isNotEmpty) {
      quantity = double.tryParse(quantityText);
    }

    await repo.updateListItem(
      id: item.id,
      displayName: name,
      categoryId: _selectedCategoryId,
      quantityValue: quantity,
      quantityUnit: quantity != null ? _selectedUnit : null,
      clearQuantity: quantityText.isEmpty,
    );

    if (item.catalogItemId != null && _selectedCategoryId != null) {
      await catalogRepo.updateCatalogItem(
        id: item.catalogItemId!,
        displayName: name,
        categoryId: _selectedCategoryId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(listItemProvider(widget.itemId));
    final categoriesAsync = ref.watch(categoriesProvider);

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
              title: const Text('Item details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteFromList(context, item),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            onChanged: (_) => _save(item),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items: QuantityUnits.all
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(QuantityUnits.label(u)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedUnit = value);
                              _save(item);
                            },
                          ),
                        ),
                      ],
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
                    if (item.catalogItemId != null) ...[
                      const SizedBox(height: 32),
                      OutlinedButton.icon(
                        onPressed: () => _removeFromMemory(context, item),
                        icon: const Icon(Icons.memory_outlined),
                        label: const Text('Remove from app memory'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Removes this custom item from suggestions. Built-in catalog items cannot be removed.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteFromList(BuildContext context, ListItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Remove "${item.displayName}" from this list?'),
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

    if (confirmed == true) {
      await ref.read(listRepositoryProvider).deleteListItem(item.id);
      if (context.mounted) context.pop();
    }
  }

  Future<void> _removeFromMemory(BuildContext context, ListItem item) async {
    if (item.catalogItemId == null) return;

    final catalogItem =
        await ref.read(catalogRepositoryProvider).getById(item.catalogItemId!);
    if (catalogItem == null || !catalogItem.isUserAdded) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only custom items can be removed from memory'),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from memory?'),
        content: Text(
          'Remove "${item.displayName}" from suggestions permanently?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(catalogRepositoryProvider)
          .deleteUserCatalogItem(item.catalogItemId!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from app memory')),
        );
      }
    }
  }
}
