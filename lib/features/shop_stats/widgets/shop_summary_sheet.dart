import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/shop_stats_repository.dart';
import '../shop_stats_formatters.dart';

class ShopSummarySheet extends StatelessWidget {
  const ShopSummarySheet({
    super.key,
    required this.result,
    required this.listName,
  });

  final ShopCompletionResult result;
  final String listName;

  static Future<void> show(
    BuildContext context, {
    required ShopCompletionResult result,
    required String listName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ShopSummarySheet(
        result: result,
        listName: listName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comparison = result.comparison;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.celebration_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop complete!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        listName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _HeroStat(
                    icon: Icons.timer_outlined,
                    label: 'Total time',
                    value: formatDuration(result.duration),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeroStat(
                    icon: Icons.speed_outlined,
                    label: 'Per item',
                    value: formatMsPerItem(result.msPerItem.inMilliseconds),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ComparisonCard(
              icon: Icons.history,
              title: 'vs last shop',
              child: _buildPreviousComparison(comparison, theme),
            ),
            const SizedBox(height: 8),
            _ComparisonCard(
              icon: Icons.emoji_events_outlined,
              title: 'Personal best',
              child: _buildBestComparison(comparison, theme),
            ),
            const SizedBox(height: 8),
            _ComparisonCard(
              icon: Icons.insights_outlined,
              title: 'vs average',
              child: _buildAverageComparison(comparison, theme),
            ),
            const SizedBox(height: 8),
            _ComparisonCard(
              icon: Icons.numbers_outlined,
              title: 'Shop count',
              child: Text(
                'Shop #${comparison.shopNumber} on this list',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/stats'),
                    child: const Text('View all stats'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousComparison(ShopStatsComparison comparison, ThemeData theme) {
    if (comparison.previousDeltaMs == null) {
      return Text(
        'First shop on this list',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return _DeltaText(deltaMs: comparison.previousDeltaMs!, reference: 'last shop');
  }

  Widget _buildBestComparison(ShopStatsComparison comparison, ThemeData theme) {
    if (comparison.isPersonalBest) {
      return Text(
        'New personal best!',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.amber.shade800,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (comparison.bestDeltaMs == null) {
      return Text(
        '—',
        style: theme.textTheme.bodyMedium,
      );
    }
    return _DeltaText(deltaMs: comparison.bestDeltaMs!, reference: 'your best');
  }

  Widget _buildAverageComparison(ShopStatsComparison comparison, ThemeData theme) {
    if (comparison.averageDeltaMs == null) {
      return Text(
        '—',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return _DeltaText(deltaMs: comparison.averageDeltaMs!, reference: 'average');
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaText extends StatelessWidget {
  const _DeltaText({
    required this.deltaMs,
    required this.reference,
  });

  final int deltaMs;
  final String reference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    if (deltaMs < 0) {
      color = Colors.green.shade700;
    } else if (deltaMs > 0) {
      color = Colors.red.shade700;
    } else {
      color = theme.colorScheme.onSurface;
    }

    return Text(
      formatDeltaDescription(deltaMs, reference: reference),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
