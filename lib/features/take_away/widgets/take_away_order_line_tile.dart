import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';

class TakeAwayOrderLineTile extends StatelessWidget {
  const TakeAwayOrderLineTile({
    super.key,
    required this.entry,
    required this.onQuantityChanged,
  });

  final TakeAwayOrderLineWithItem entry;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = entry.menuItem;
    final quantity = entry.line.quantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (item.itemNumber != null && item.itemNumber!.isNotEmpty) ...[
              SizedBox(
                width: 32,
                child: Text(
                  item.itemNumber!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.bodyLarge),
                  Text(
                    item.priceDisplay,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => onQuantityChanged(quantity - 1),
            ),
            SizedBox(
              width: 28,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onQuantityChanged(quantity + 1),
            ),
          ],
        ),
      ),
    );
  }
}
