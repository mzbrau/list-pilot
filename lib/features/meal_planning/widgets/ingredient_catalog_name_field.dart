import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';

class IngredientCatalogNameField extends StatelessWidget {
  const IngredientCatalogNameField({
    super.key,
    required this.controller,
    required this.categories,
    required this.suggestions,
    required this.addToCatalog,
    this.categoryId,
    this.matchedCatalogItem,
    this.originalLine,
    this.onNameChanged,
    required this.onCatalogSelected,
    required this.onAddToCatalogChanged,
    required this.onCategoryChanged,
  });

  final TextEditingController controller;
  final List<Category> categories;
  final List<CatalogItem> suggestions;
  final bool addToCatalog;
  final String? categoryId;
  final CatalogItem? matchedCatalogItem;
  final String? originalLine;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<CatalogItem> onCatalogSelected;
  final ValueChanged<bool?> onAddToCatalogChanged;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (originalLine != null) ...[
          Text(
            'Original: $originalLine',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (matchedCatalogItem != null && !addToCatalog) ...[
          Text(
            'Matched: ${matchedCatalogItem!.displayName}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Ingredient name',
          ),
          onChanged: onNameChanged,
        ),
        if (suggestions.isNotEmpty)
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surfaceContainerHighest,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final item = suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(item.displayName),
                  onTap: () => onCatalogSelected(item),
                );
              },
            ),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Add to catalog'),
          value: addToCatalog,
          onChanged: onAddToCatalogChanged,
        ),
        if (addToCatalog && categories.isNotEmpty)
          DropdownButtonFormField<String>(
            value: categoryId,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final category in categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: onCategoryChanged,
          ),
      ],
    );
  }
}
