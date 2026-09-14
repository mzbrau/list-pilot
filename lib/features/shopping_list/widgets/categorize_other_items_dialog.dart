import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class CategorizeOtherItemsDialog extends ConsumerStatefulWidget {
  const CategorizeOtherItemsDialog({
    super.key,
    required this.items,
    required this.categories,
  });

  final List<ListItem> items;
  final List<Category> categories;

  static Future<void> show(
    BuildContext context, {
    required List<ListItem> items,
    required List<Category> categories,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => CategorizeOtherItemsDialog(
        items: items,
        categories: categories,
      ),
    );
  }

  @override
  ConsumerState<CategorizeOtherItemsDialog> createState() =>
      _CategorizeOtherItemsDialogState();
}

class _CategorizeOtherItemsDialogState
    extends ConsumerState<CategorizeOtherItemsDialog> {
  late final Map<int, String> _selections;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _selections = {
      for (final item in widget.items) item.id: item.categoryId,
    };
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final listRepo = ref.read(listRepositoryProvider);
    final catalogRepo = ref.read(catalogRepositoryProvider);

    try {
      for (final item in widget.items) {
        final categoryId = _selections[item.id];
        if (categoryId == null || categoryId == 'other') continue;

        await listRepo.updateListItem(
          id: item.id,
          categoryId: categoryId,
        );

        if (item.catalogItemId != null) {
          await catalogRepo.updateCatalogItem(
            id: item.catalogItemId!,
            categoryId: categoryId,
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.6;

    return AlertDialog(
      title: const Text('Categorize Other items'),
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: widget.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.displayName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selections[item.id],
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      isDense: true,
                    ),
                    items: widget.categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() => _selections[item.id] = value);
                          },
                  ),
                ],
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
