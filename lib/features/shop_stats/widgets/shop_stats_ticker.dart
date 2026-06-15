import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../shop_stats_formatters.dart';

class ShopStatsTicker extends ConsumerStatefulWidget {
  const ShopStatsTicker({
    super.key,
    required this.listId,
    required this.startedAt,
    required this.completedCount,
    required this.totalItems,
  });

  final int listId;
  final DateTime startedAt;
  final int completedCount;
  final int totalItems;

  @override
  ConsumerState<ShopStatsTicker> createState() => _ShopStatsTickerState();
}

class _ShopStatsTickerState extends ConsumerState<ShopStatsTicker> {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed = _now.difference(widget.startedAt);
    final completed = widget.completedCount.clamp(1, widget.totalItems);
    final currentMsPerItem = elapsed.inMilliseconds ~/ completed;

    final averageAsync = ref.watch(shopStatsAverageMsPerItemProvider(widget.listId));

    final averageMsPerItem = averageAsync.valueOrNull;
    final hasHistory = averageMsPerItem != null;

    Color? deltaColor;
    IconData? deltaIcon;
    String deltaText;

    if (!hasHistory) {
      deltaText = '— vs avg';
      deltaColor = theme.colorScheme.onSurfaceVariant;
    } else {
      final delta = currentMsPerItem - averageMsPerItem;
      deltaText = '${formatDelta(delta)} vs avg';
      if (delta < 0) {
        deltaColor = Colors.green.shade700;
        deltaIcon = Icons.arrow_drop_down;
      } else if (delta > 0) {
        deltaColor = Colors.red.shade700;
        deltaIcon = Icons.arrow_drop_up;
      } else {
        deltaColor = theme.colorScheme.onSurfaceVariant;
      }
    }

    return Material(
      elevation: 4,
      color: theme.colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                formatDuration(elapsed),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '·',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formatMsPerItem(currentMsPerItem),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (deltaIcon != null) ...[
                Icon(deltaIcon, size: 18, color: deltaColor),
                const SizedBox(width: 2),
              ],
              Text(
                deltaText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: deltaColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
