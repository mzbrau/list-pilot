import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class AddCatalogItemSheet extends ConsumerStatefulWidget {
  const AddCatalogItemSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SafeArea(child: AddCatalogItemSheet()),
    );
  }

  @override
  ConsumerState<AddCatalogItemSheet> createState() =>
      _AddCatalogItemSheetState();
}

class _AddCatalogItemSheetState extends ConsumerState<AddCatalogItemSheet> {
  final _nameController = TextEditingController();
  String? _selectedCategoryId;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save(List<Category> categories) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final categoryId = _selectedCategoryId ?? categories.first.id;
    setState(() => _saving = true);
    try {
      await ref.read(catalogRepositoryProvider).getOrCreate(
            displayName: name,
            categoryId: categoryId,
            isUserAdded: true,
          );
      ref.invalidate(allCatalogItemsProvider);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: categoriesAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text('Error: $e'),
        data: (categories) {
          _selectedCategoryId ??= categories.first.id;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add catalog item',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                ),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                onSubmitted: (_) => _save(categories),
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
                onChanged: (value) => setState(() => _selectedCategoryId = value),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : () => _save(categories),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add item'),
              ),
            ],
          );
        },
      ),
    );
  }
}
