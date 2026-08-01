import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../learning/ordering_service.dart';
import 'list_item_tile.dart';

class CategorizedItemList extends StatelessWidget {
  const CategorizedItemList({
    super.key,
    required this.groupedItems,
    required this.listId,
    required this.onToggle,
    required this.onTapItem,
    this.diagnosticsByItemId,
    this.categoryDiagnosticsByName,
  });

  final Map<String, List<ListItem>> groupedItems;
  final int listId;
  final void Function(ListItem item, bool completed) onToggle;
  final void Function(ListItem item) onTapItem;

  /// When non-null, shows per-item ordering diagnostics.
  final Map<int, ItemSortDiagnostics>? diagnosticsByItemId;

  /// When non-null, shows per-category rank aggregates on headers.
  final Map<String, ItemSortDiagnostics>? categoryDiagnosticsByName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showDiagnostics = diagnosticsByItemId != null;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var itemIndex = index;
          for (final entry in groupedItems.entries) {
            if (itemIndex == 0) {
              final catDiag = categoryDiagnosticsByName?[entry.key];
              final headerLabel = showDiagnostics && catDiag != null
                  ? '${entry.key} (${entry.value.length})  ·  '
                      'cat ${_fmt(catDiag.categoryRank)}'
                      '${catDiag.categoryOverridden ? ' (override)' : ''}  ·  '
                      'Σ ${_fmt(catDiag.categoryContribution)}'
                  : '${entry.key} (${entry.value.length})';

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
                  headerLabel,
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
                  diagnostics: diagnosticsByItemId?[item.id],
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

String _fmt(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}
