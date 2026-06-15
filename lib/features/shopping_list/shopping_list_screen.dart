import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../features/learning/ordering_service.dart';
import '../shop_stats/widgets/shop_stats_ticker.dart';
import '../shop_stats/widgets/shop_summary_sheet.dart';
import 'widgets/categorized_item_list.dart';
import 'widgets/completed_items_section.dart';
import 'widgets/item_autocomplete_field.dart';
import 'widgets/list_progress_title.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<ShoppingListScreen> createState() =>
      _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _orderingService = OrderingService();

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required String? listName,
    required int remaining,
    required int total,
    ShoppingList? list,
  }) {
    final theme = Theme.of(context);

    return AppBar(
      leading: context.canPop()
          ? IconButton(
              icon: const BackButtonIcon(),
              onPressed: () => context.pop(),
            )
          : null,
      title: listName != null
          ? ListProgressTitle(
              listName: listName,
              remaining: remaining,
              total: total,
            )
          : null,
      bottom: total > 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(
                value: remaining / total,
                minHeight: 3,
                backgroundColor: theme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                color: theme.colorScheme.primary,
              ),
            )
          : null,
      actions: list == null
          ? null
          : [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Rename',
                onPressed: () => _renameList(context, list),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'reset') {
                    await _resetLearnedOrder(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Text('Reset learned order'),
                  ),
                ],
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(shoppingListProvider(widget.listId));
    final itemsAsync = ref.watch(listItemsProvider(widget.listId));
    final items = itemsAsync.valueOrNull ?? [];
    final remaining = items.where((i) => !i.isCompleted).length;
    final total = items.length;
    final completedCount = total - remaining;
    final shopStatsEnabled = ref.watch(shopStatsEnabledProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryStatsAsync =
        ref.watch(categoryRankStatsProvider(widget.listId));
    final itemStatsAsync = ref.watch(itemRankStatsProvider(widget.listId));

    return listAsync.when(
      loading: () => Scaffold(
        appBar: _buildAppBar(
          context,
          listName: null,
          remaining: remaining,
          total: total,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: _buildAppBar(
          context,
          listName: null,
          remaining: remaining,
          total: total,
        ),
        body: Center(child: Text('Error: $e')),
      ),
      data: (list) {
        if (list == null) {
          return Scaffold(
            appBar: _buildAppBar(
              context,
              listName: null,
              remaining: remaining,
              total: total,
            ),
            body: const Center(child: Text('List not found')),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(
            context,
            listName: list.name,
            remaining: remaining,
            total: total,
            list: list,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ItemAutocompleteField(
                  listId: widget.listId,
                ),
              ),
              Expanded(
                child: itemsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (items) {
                    return categoriesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (categories) {
                        final categoryStats =
                            categoryStatsAsync.valueOrNull ?? [];
                        final itemStats = itemStatsAsync.valueOrNull ?? [];

                        final grouped = _orderingService.groupActiveItems(
                          items: items,
                          categories: categories,
                          categoryRankStats: categoryStats,
                          itemRankStats: itemStats,
                        );
                        final completed =
                            _orderingService.sortCompletedItems(items);

                        if (items.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'Start typing above to add items',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final showTicker = shopStatsEnabled &&
                            list.activeShopStartedAt != null &&
                            remaining > 0;

                        return CustomScrollView(
                          slivers: [
                            if (grouped.isNotEmpty)
                              CategorizedItemList(
                                groupedItems: grouped,
                                listId: widget.listId,
                                onToggle: _toggleItem,
                                onTapItem: (item) => context.push(
                                  '/list/${widget.listId}/item/${item.id}',
                                ),
                              ),
                            CompletedItemsSection(
                              items: completed,
                              listId: widget.listId,
                              onToggle: _toggleItem,
                              onClear: _clearCompleted,
                              onTapItem: (item) => context.push(
                                '/list/${widget.listId}/item/${item.id}',
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.only(
                                bottom: showTicker ? 8 : 24,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              if (shopStatsEnabled &&
                  list.activeShopStartedAt != null &&
                  remaining > 0)
                ShopStatsTicker(
                  listId: widget.listId,
                  startedAt: list.activeShopStartedAt!,
                  completedCount: completedCount,
                  totalItems: total,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleItem(ListItem item, bool completed) async {
    final items = ref.read(listItemsProvider(widget.listId)).valueOrNull ?? [];
    final remainingAfter = completed
        ? items.where((i) => !i.isCompleted && i.id != item.id).length
        : items.where((i) => !i.isCompleted).length;
    final totalItems = items.length;
    final shopStatsEnabled = ref.read(shopStatsEnabledProvider);
    final listName =
        ref.read(shoppingListProvider(widget.listId)).valueOrNull?.name ?? 'List';

    final result = await ref.read(listRepositoryProvider).setItemCompleted(
          widget.listId,
          item.id,
          completed,
          shopStatsEnabled: shopStatsEnabled,
          remainingAfter: completed ? remainingAfter : null,
          totalItems: completed ? totalItems : null,
        );

    if (!mounted) return;
    if (result != null) {
      await ShopSummarySheet.show(
        context,
        result: result,
        listName: listName,
      );
    }
  }

  Future<void> _clearCompleted(int count) async {
    if (count > 5) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear completed items?'),
          content: Text('Remove $count completed items?'),
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
      if (confirmed != true) return;
    }

    await ref.read(listRepositoryProvider).clearCompleted(
          widget.listId,
          shopStatsEnabled: ref.read(shopStatsEnabledProvider),
        );
  }

  Future<void> _renameList(BuildContext context, ShoppingList list) async {
    final controller = TextEditingController(text: list.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename list'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await ref.read(listRepositoryProvider).renameList(list.id, name);
    }
  }

  Future<void> _resetLearnedOrder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset learned order?'),
        content: const Text(
          'This will forget the shopping order learned for this list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(listRepositoryProvider).resetLearnedOrder(widget.listId);
    }
  }
}
