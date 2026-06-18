import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';

class TakeAwayMenuItemTile extends StatelessWidget {
  const TakeAwayMenuItemTile({
    super.key,
    required this.item,
    required this.readOnly,
    this.onAdd,
  });

  final TakeAwayMenuItem item;
  final bool readOnly;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              if (item.itemNumber != null && item.itemNumber!.isNotEmpty) ...[
                SizedBox(
                  width: 36,
                  child: Text(
                    item.itemNumber!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  item.name,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.priceDisplay,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (readOnly && onAdd != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add to order',
                  onPressed: onAdd,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
