import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../learning/ordering_service.dart';
import 'completed_items_section.dart';

class ListItemTile extends StatelessWidget {
  const ListItemTile({
    super.key,
    required this.item,
    required this.completed,
    required this.onToggle,
    required this.onTap,
    this.diagnostics,
  });

  final ListItem item;
  final bool completed;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final ItemSortDiagnostics? diagnostics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantity = formatQuantity(item);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: completed ? 0.55 : 1,
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Checkbox(
            value: completed,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (value) => onToggle(value ?? false),
          ),
          title: Text(
            item.displayName,
            style: completed
                ? theme.textTheme.bodyLarge?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : theme.textTheme.bodyLarge,
          ),
          subtitle: diagnostics == null
              ? null
              : Text(
                  _diagnosticsCaption(diagnostics!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
          trailing: quantity.isNotEmpty
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quantity,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}

String _diagnosticsCaption(ItemSortDiagnostics d) {
  final itemLabel = d.usingDefaultItem
      ? 'item default'
      : 'item ${_fmt(d.itemRank)}'
          '${d.itemOverridden ? ' ov' : ''}'
          '${d.itemSampleCount != null ? ' n=${d.itemSampleCount}' : ''}';
  final catLabel = d.usingDefaultCategory
      ? 'cat default'
      : 'cat ${_fmt(d.categoryRank)}'
          '${d.categoryOverridden ? ' ov' : ''}'
          '${d.categorySampleCount != null ? ' n=${d.categorySampleCount}' : ''}';
  return '$catLabel · $itemLabel · key ${_fmt(d.sortKey)}';
}

String _fmt(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}
