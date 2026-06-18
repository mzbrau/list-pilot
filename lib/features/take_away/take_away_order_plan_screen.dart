import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_providers.dart';
import '../../router/navigation_helpers.dart';
import 'widgets/take_away_order_line_tile.dart';

class TakeAwayOrderPlanScreen extends ConsumerWidget {
  const TakeAwayOrderPlanScreen({
    super.key,
    required this.listId,
    required this.menuId,
  });

  final int listId;
  final int menuId;

  String _formatTotal(double total, String? currency) {
    final formatted = total == total.roundToDouble()
        ? total.toStringAsFixed(0)
        : total.toStringAsFixed(2);
    if (currency != null && currency.isNotEmpty) {
      return '$formatted $currency';
    }
    return formatted;
  }

  Future<void> _clearOrder(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear order?'),
        content: const Text('Remove all items from this order plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(takeAwayRepositoryProvider).clearOrder(menuId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(takeAwayMenuProvider(menuId));
    final orderAsync = ref.watch(takeAwayOrderProvider(menuId));
    final theme = Theme.of(context);
    final dateFormat = DateFormat.MMMd().add_jm();

    return popOrGoHomeScope(
      child: Scaffold(
        appBar: AppBar(
          leading: overviewBackButton(context),
          title: menuAsync.when(
            data: (menu) => Text(menu?.restaurantName ?? 'Order plan'),
            loading: () => const Text('Order plan'),
            error: (_, __) => const Text('Order plan'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear order',
              onPressed: () => _clearOrder(context, ref),
            ),
          ],
        ),
        body: orderAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (orderWithLines) {
            final menu = menuAsync.valueOrNull;
            final lines = orderWithLines?.lines ?? [];
            final updatedAt = orderWithLines?.order.updatedAt;

            var total = 0.0;
            var hasNumericPrices = false;
            for (final entry in lines) {
              final amount = entry.menuItem.priceAmount;
              if (amount != null) {
                hasNumericPrices = true;
                total += amount * entry.line.quantity;
              }
            }

            if (lines.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No items in order',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + on menu items to build your order',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                if (updatedAt != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Last updated ${dateFormat.format(updatedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      final entry = lines[index];
                      return TakeAwayOrderLineTile(
                        entry: entry,
                        onQuantityChanged: (qty) => ref
                            .read(takeAwayRepositoryProvider)
                            .setLineQuantity(menuId, entry.menuItem.id, qty),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border(
                      top: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasNumericPrices)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatTotal(total, menu?.currency),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Total unavailable — some items lack numeric prices',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
