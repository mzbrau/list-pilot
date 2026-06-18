import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../router/navigation_helpers.dart';
import 'widgets/take_away_menu_card.dart';

class TakeAwayListScreen extends ConsumerWidget {
  const TakeAwayListScreen({super.key, required this.listId});

  final int listId;

  Future<void> _renameList(BuildContext context, WidgetRef ref, TakeAwayList list) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: list.name);
        return AlertDialog(
          title: const Text('Rename list'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'List name'),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (value) => Navigator.pop(context, value),
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
        );
      },
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(takeAwayRepositoryProvider).renameList(list.id, name);
    }
  }

  void _importMenu(BuildContext context, WidgetRef ref) {
    final aiConfig = ref.read(aiConfigProvider);
    if (!aiConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configure AI import in Settings before importing menus'),
        ),
      );
      return;
    }
    context.push('/take-away/$listId/import');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(takeAwayListProvider(listId));
    final menusAsync = ref.watch(takeAwayMenusProvider(listId));
    final theme = Theme.of(context);

    return popOrGoHomeScope(
      child: Scaffold(
        appBar: AppBar(
          leading: overviewBackButton(context),
          title: listAsync.when(
            data: (list) => Text(list?.name ?? 'Take away list'),
            loading: () => const Text('Take away list'),
            error: (_, __) => const Text('Take away list'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Rename',
              onPressed: () {
                final list = listAsync.valueOrNull;
                if (list != null) {
                  _renameList(context, ref, list);
                }
              },
            ),
          ],
        ),
        body: menusAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (menus) {
            if (menus.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No menus yet',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Import a restaurant menu from a webpage',
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
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TakeAwayMenuCard(
                    listId: listId,
                    menu: menu,
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _importMenu(context, ref),
          icon: const Icon(Icons.download_outlined),
          label: const Text('Import menu'),
        ),
      ),
    );
  }
}
