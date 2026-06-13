import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import 'list_item_tile.dart';

class CategorizedItemList extends StatelessWidget {
  const CategorizedItemList({
    super.key,
    required this.groupedItems,
    required this.listId,
    required this.onToggle,
    required this.onTapItem,
  });

  final Map<String, List<ListItem>> groupedItems;
  final int listId;
  final void Function(ListItem item, bool completed) onToggle;
  final void Function(ListItem item) onTapItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var itemIndex = index;
          for (final entry in groupedItems.entries) {
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
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Text(
                  '${entry.key} (${entry.value.length})',
                  textAlign: TextAlign.left,
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
                return ListItemTile(
                  item: item,
                  completed: false,
                  onToggle: (value) => onToggle(item, value),
                  onTap: () => onTapItem(item),
                );
              }
              itemIndex--;
            }
          }
          return null;
        },
        childCount: _totalChildCount(),
      ),
    );
  }

  int _totalChildCount() {
    var count = 0;
    for (final entry in groupedItems.entries) {
      count += 1 + entry.value.length;
    }
    return count;
  }
}
