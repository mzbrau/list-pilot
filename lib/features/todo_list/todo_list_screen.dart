import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import 'widgets/segmented_todo_list.dart';
import 'widgets/task_autocomplete_field.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoMaintenanceServiceProvider).runMaintenanceForList(widget.listId);
    });
  }

  Future<void> _renameList(BuildContext context, TodoList list) async {
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
      await ref.read(todoRepositoryProvider).renameList(list.id, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(todoListProvider(widget.listId));
    final itemsAsync = ref.watch(todoItemsProvider(widget.listId));
    final items = itemsAsync.valueOrNull ?? [];
    final remaining = items.where((i) => !i.isCompleted).length;
    final total = items.length;

    return Scaffold(
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(
                icon: const BackButtonIcon(),
                onPressed: () => context.pop(),
              )
            : null,
        title: listAsync.when(
          data: (list) => list == null
              ? const Text('Todo list')
              : Text('${list.name} ($remaining/$total)'),
          loading: () => const Text('Todo list'),
          error: (_, __) => const Text('Todo list'),
        ),
        bottom: total > 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : (total - remaining) / total,
                  minHeight: 3,
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Completed tasks',
            onPressed: () => context.push('/todo/${widget.listId}/history'),
          ),
          listAsync.whenOrNull(
                data: (list) => list == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Rename',
                        onPressed: () => _renameList(context, list),
                      ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TaskAutocompleteField(listId: widget.listId),
          ),
          Expanded(
            child: itemsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) => CustomScrollView(
                slivers: [
                  SegmentedTodoList(listId: widget.listId, items: items),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
