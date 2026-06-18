import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../router/navigation_helpers.dart';
import 'shop_stats_formatters.dart';

class ShopStatsScreen extends ConsumerWidget {
  const ShopStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(shopStatsRecordsProvider);
    final listsAsync = ref.watch(shoppingListsProvider);
    final theme = Theme.of(context);

    return popOrGoHomeScope(
      child: Scaffold(
      appBar: AppBar(
        leading: overviewBackButton(context),
        title: const Text('Shop Stats'),
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 64,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No shop stats yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete a shop with all items checked off to see your first stats.',
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

          final lists = listsAsync.valueOrNull ?? [];
          final listNames = {
            for (final list in lists) list.id: list.name,
          };

          final grouped = <int, List<ShopStatsRecord>>{};
          for (final record in records) {
            grouped.putIfAbsent(record.listId, () => []).add(record);
          }

          int? globalBestMsPerItem;
          for (final record in records) {
            final ms = _msPerItem(record);
            if (globalBestMsPerItem == null || ms < globalBestMsPerItem) {
              globalBestMsPerItem = ms;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Total shops',
                      value: '${records.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.emoji_events_outlined,
                      label: 'Best pace',
                      value: globalBestMsPerItem != null
                          ? formatMsPerItem(globalBestMsPerItem)
                          : '—',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...grouped.entries.map((entry) {
                final listId = entry.key;
                final listRecords = entry.value
                  ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
                final ranked = [...listRecords]
                  ..sort((a, b) => _msPerItem(a).compareTo(_msPerItem(b)));

                return _ListStatsSection(
                  listName: listNames[listId] ?? 'List $listId',
                  records: listRecords,
                  rankedRecords: ranked,
                );
              }),
            ],
          );
        },
      ),
    ),
    );
  }

  int _msPerItem(ShopStatsRecord record) {
    final durationMs =
        record.completedAt.difference(record.startedAt).inMilliseconds;
    if (record.itemCount <= 0) return 0;
    return durationMs ~/ record.itemCount;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
          Icon(icon, color: theme.colorScheme.primary),
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
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListStatsSection extends StatelessWidget {
  const _ListStatsSection({
    required this.listName,
    required this.records,
    required this.rankedRecords,
  });

  final String listName;
  final List<ShopStatsRecord> records;
  final List<ShopStatsRecord> rankedRecords;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.MMMd().add_jm();

    final msPerItems = records.map(_msPerItem).toList();
    final average = msPerItems.reduce((a, b) => a + b) ~/ msPerItems.length;
    final best = msPerItems.reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.store_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  listName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: '${records.length} shops'),
              _Chip(label: 'Avg ${formatMsPerItem(average)}'),
              _Chip(label: 'Best ${formatMsPerItem(best)}'),
            ],
          ),
          const SizedBox(height: 12),
          ...records.map((record) {
            final rank = rankedRecords.indexOf(record) + 1;
            final duration =
                record.completedAt.difference(record.startedAt);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _RankBadge(rank: rank),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(record.completedAt),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${record.itemCount} items · ${formatDuration(duration)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatMsPerItem(_msPerItem(record)),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  int _msPerItem(ShopStatsRecord record) {
    final durationMs =
        record.completedAt.difference(record.startedAt).inMilliseconds;
    if (record.itemCount <= 0) return 0;
    return durationMs ~/ record.itemCount;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall,
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBest = rank == 1;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isBest
            ? Colors.amber.shade100
            : theme.colorScheme.secondaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        formatRankLabel(rank),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isBest
              ? Colors.amber.shade900
              : theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
