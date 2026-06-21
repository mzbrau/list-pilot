import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/overview_display_item.dart';
import '../../../core/providers/app_providers.dart';

typedef OverviewItemBuilder = Widget Function(
  OverviewDisplayItem item, {
  required bool isDragging,
  required VoidCallback onDragStarted,
  required VoidCallback onDragEnded,
});

class ReorderableOverviewList extends ConsumerStatefulWidget {
  const ReorderableOverviewList({
    super.key,
    required this.items,
    required this.isEditing,
    required this.itemBuilder,
    this.footer,
  });

  final List<OverviewDisplayItem> items;
  final bool isEditing;
  final OverviewItemBuilder itemBuilder;
  final Widget? footer;

  @override
  ConsumerState<ReorderableOverviewList> createState() =>
      _ReorderableOverviewListState();
}

class _ReorderableOverviewListState extends ConsumerState<ReorderableOverviewList> {
  String? _draggingItemKey;

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditing) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final item in widget.items)
            widget.itemBuilder(
              item,
              isDragging: false,
              onDragStarted: () {},
              onDragEnded: () {},
            ),
          if (widget.footer != null) widget.footer!,
        ],
      );
    }

    final children = <Widget>[];
    for (var index = 0; index < widget.items.length; index++) {
      final item = widget.items[index];
      children.add(
        _OverviewDropZone(
          onDrop: (dropped) => _handleDrop(dropped, index),
          child: widget.itemBuilder(
            item,
            isDragging: _draggingItemKey == item.itemKey,
            onDragStarted: () => setState(() => _draggingItemKey = item.itemKey),
            onDragEnded: () => setState(() => _draggingItemKey = null),
          ),
        ),
      );
    }

    if (widget.items.isNotEmpty) {
      children.add(
        _OverviewDropZone(
          onDrop: (dropped) => _handleDrop(dropped, widget.items.length),
          showIndicatorOnly: true,
        ),
      );
    }

    if (widget.footer != null) {
      children.add(widget.footer!);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }

  Future<void> _handleDrop(
    OverviewDisplayItem item,
    int insertIndex,
  ) async {
    final currentIndex =
        widget.items.indexWhere((i) => i.itemKey == item.itemKey);
    if (currentIndex != -1 && currentIndex == insertIndex) return;
    if (currentIndex != -1 && insertIndex > currentIndex) {
      insertIndex -= 1;
    }

    await ref.read(overviewOrderRepositoryProvider).moveItemToPosition(
          itemKey: item.itemKey,
          orderedKeys: widget.items.map((i) => i.itemKey).toList(),
          newIndex: insertIndex,
        );
  }
}

class _OverviewDropZone extends StatelessWidget {
  const _OverviewDropZone({
    required this.onDrop,
    this.child,
    this.showIndicatorOnly = false,
  });

  final Future<void> Function(OverviewDisplayItem item) onDrop;
  final Widget? child;
  final bool showIndicatorOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DragTarget<OverviewDisplayItem>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        final indicator = AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: isHighlighted ? 3 : (showIndicatorOnly ? 8 : 0),
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: showIndicatorOnly ? 0 : 2,
          ),
          decoration: BoxDecoration(
            color: isHighlighted ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        );

        if (showIndicatorOnly) {
          return indicator;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            child!,
          ],
        );
      },
    );
  }
}
