import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/database/app_database.dart';
import 'list_item_tile.dart';

class CompletedItemsSection extends StatefulWidget {
  const CompletedItemsSection({
    super.key,
    required this.items,
    required this.listId,
    required this.onToggle,
    required this.onClear,
    required this.onTapItem,
  });

  final List<ListItem> items;
  final int listId;
  final void Function(ListItem item, bool completed) onToggle;
  final Future<void> Function(int count) onClear;
  final void Function(ListItem item) onTapItem;

  @override
  State<CompletedItemsSection> createState() => _CompletedItemsSectionState();
}

class _CompletedItemsSectionState extends State<CompletedItemsSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final theme = Theme.of(context);

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Icon(
                            _expanded
                                ? Icons.expand_more
                                : Icons.chevron_right,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'In your cart (${widget.items.length})',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onClear(widget.items.length),
                  child: const Text('Clear all'),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = widget.items[index];
                return ListItemTile(
                  item: item,
                  completed: true,
                  onToggle: (value) => widget.onToggle(item, value),
                  onTap: () => widget.onTapItem(item),
                );
              },
              childCount: widget.items.length,
            ),
          ),
      ],
    );
  }
}

String formatQuantity(ListItem item) {
  if (item.quantityValue == null) return '';
  final value = item.quantityValue!;
  final unit = item.quantityUnit ?? QuantityUnits.count;
  if (unit == QuantityUnits.count) {
    if (value == value.roundToDouble()) {
      return '×${value.toInt()}';
    }
    return '×$value';
  }
  if (value == value.roundToDouble()) {
    return '${value.toInt()} $unit';
  }
  return '$value $unit';
}
