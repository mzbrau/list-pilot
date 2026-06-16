import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_providers.dart';

class TodoCompletedHistoryScreen extends ConsumerWidget {
  const TodoCompletedHistoryScreen({super.key, required this.listId});

  final int listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(todoArchivedProvider(listId));
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.jm();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const BackButtonIcon(),
          onPressed: () => context.pop(),
        ),
        title: const Text('Completed tasks'),
      ),
      body: archivedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No completed task history yet'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.displayName),
                subtitle: Text(
                  'Scheduled ${dateFormat.format(item.scheduledDate)}\n'
                  'Completed ${dateFormat.format(item.completedAt)} at '
                  '${timeFormat.format(item.completedAt)}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
