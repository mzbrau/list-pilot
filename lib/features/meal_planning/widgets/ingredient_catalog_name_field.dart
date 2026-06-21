import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';

class IngredientCatalogNameField extends StatelessWidget {
  const IngredientCatalogNameField({
    super.key,
    required this.controller,
    required this.categories,
    required this.suggestions,
    this.matchSuggestions = const [],
    required this.addToCatalog,
    this.categoryId,
    this.matchedCatalogItem,
    this.originalLine,
    this.onRemove,
    this.onNameChanged,
    required this.onCatalogSelected,
    required this.onAddToCatalogChanged,
    required this.onCategoryChanged,
  });

  final TextEditingController controller;
  final List<Category> categories;
  final List<CatalogItem> suggestions;
  final List<CatalogItem> matchSuggestions;
  final bool addToCatalog;
  final String? categoryId;
  final CatalogItem? matchedCatalogItem;
  final String? originalLine;
  final VoidCallback? onRemove;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Original: $originalLine',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove ingredient',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRemove,
                ),
            ],
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
        if (matchSuggestions.isNotEmpty) ...[
          Text(
            'Suggestions',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final item in matchSuggestions)
                ActionChip(
                  label: Text(item.displayName),
                  onPressed: () => onCatalogSelected(item),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            return TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Ingredient name',
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          onNameChanged?.call('');
                        },
                      )
                    : null,
              ),
              onChanged: onNameChanged,
            );
          },
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
