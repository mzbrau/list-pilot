import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import 'ordering_service.dart';

class LearnedRanksScreen extends ConsumerWidget {
  const LearnedRanksScreen({super.key, required this.listId});

  final int listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(shoppingListProvider(listId));
    final itemStatsAsync = ref.watch(itemRankStatsProvider(listId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final catalogAsync = ref.watch(allCatalogItemsProvider);

    final listName = listAsync.valueOrNull?.name ?? 'List';

    return Scaffold(
      appBar: AppBar(
        title: Text('Learned item ranks — $listName'),
      ),
      body: itemStatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (itemStats) {
          if (itemStats.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No learned item ranks yet. Check off items over a few '
                  'shopping trips and within-category order will appear here.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final categories = categoriesAsync.valueOrNull ?? [];
          final categoryNames = {
            for (final c in categories) c.id: c.name,
          };
          final catalogItems = catalogAsync.valueOrNull?.items ?? [];
          final catalogNames = {
            for (final c in catalogItems) c.id: c.displayName,
          };

          final sortedItems = [...itemStats]..sort((a, b) {
                final rankA = OrderingService.effectiveRank(
                  overrideRank: a.overrideRank,
                  medianRank: a.medianRank,
                  sampleCount: a.sampleCount,
                  fallback: a.medianRank,
                );
                final rankB = OrderingService.effectiveRank(
                  overrideRank: b.overrideRank,
                  medianRank: b.medianRank,
                  sampleCount: b.sampleCount,
                  fallback: b.medianRank,
                );
                return rankA.compareTo(rankB);
              });

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const _HelpBanner(),
              const _SectionHeader('Items'),
              for (final stat in sortedItems)
                _ItemRankTile(
                  listId: listId,
                  stat: stat,
                  itemName: catalogNames[stat.catalogItemId] ??
                      'Item #${stat.catalogItemId}',
                  categoryName:
                      categoryNames[stat.categoryId] ?? stat.categoryId,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HelpBanner extends StatelessWidget {
  const _HelpBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        'Lower rank = earlier within a category. Learned ranks apply after '
        '${AppConstants.minSamplesForLearnedOrder}+ samples unless overridden. '
        'Category aisle order is set in Settings → Reorder categories.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ItemRankTile extends ConsumerWidget {
  const _ItemRankTile({
    required this.listId,
    required this.stat,
    required this.itemName,
    required this.categoryName,
  });

  final int listId;
  final ItemRankStat stat;
  final String itemName;
  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effective = OrderingService.effectiveRank(
      overrideRank: stat.overrideRank,
      medianRank: stat.medianRank,
      sampleCount: stat.sampleCount,
      fallback: stat.medianRank,
    );
    final overridden = stat.overrideRank != null;

    return ListTile(
      title: Text(itemName),
      subtitle: Text(
        '$categoryName · ${_rankSubtitle(
          computed: stat.medianRank,
          effective: effective,
          sampleCount: stat.sampleCount,
          lastUpdated: stat.lastUpdated,
          overridden: overridden,
        )}',
      ),
      trailing: _RankActions(
        overridden: overridden,
        onEdit: () => _editRank(
          context: context,
          title: itemName,
          initial: effective,
          onSave: (rank) => ref.read(learningRepositoryProvider).setItemRankOverride(
                listId: listId,
                catalogItemId: stat.catalogItemId,
                categoryId: stat.categoryId,
                rank: rank,
              ),
        ),
        onUndo: () => ref.read(learningRepositoryProvider).clearItemRankOverride(
              listId: listId,
              catalogItemId: stat.catalogItemId,
            ),
      ),
      onTap: () => _editRank(
        context: context,
        title: itemName,
        initial: effective,
        onSave: (rank) => ref.read(learningRepositoryProvider).setItemRankOverride(
              listId: listId,
              catalogItemId: stat.catalogItemId,
              categoryId: stat.categoryId,
              rank: rank,
            ),
      ),
    );
  }
}

class _RankActions extends StatelessWidget {
  const _RankActions({
    required this.overridden,
    required this.onEdit,
    required this.onUndo,
  });

  final bool overridden;
  final VoidCallback onEdit;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (overridden)
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo override',
            onPressed: onUndo,
          ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit rank',
          onPressed: onEdit,
        ),
      ],
    );
  }
}

String _rankSubtitle({
  required double computed,
  required double effective,
  required int sampleCount,
  required DateTime lastUpdated,
  required bool overridden,
}) {
  final date = DateFormat.yMMMd().add_jm().format(lastUpdated);
  final samples = '$sampleCount sample${sampleCount == 1 ? '' : 's'}';
  if (overridden) {
    return 'Override ${_fmt(effective)} (computed ${_fmt(computed)}) · '
        '$samples · $date';
  }
  final active = sampleCount >= AppConstants.minSamplesForLearnedOrder;
  final status = active ? 'active' : 'not yet active';
  return 'Rank ${_fmt(effective)} ($status) · $samples · $date';
}

String _fmt(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2);
}

Future<void> _editRank({
  required BuildContext context,
  required String title,
  required double initial,
  required Future<void> Function(double rank) onSave,
}) async {
  final controller = TextEditingController(text: _fmt(initial));
  final result = await showDialog<double>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Override rank — $title'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Rank (lower = earlier)',
            helperText: 'This override is used for sorting until undone.',
          ),
          onSubmitted: (value) {
            final parsed = double.tryParse(value.trim());
            if (parsed != null) Navigator.pop(context, parsed);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed == null) return;
              Navigator.pop(context, parsed);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
  controller.dispose();
  if (result == null) return;
  await onSave(result);
}
