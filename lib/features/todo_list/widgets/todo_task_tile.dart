import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class TodoTaskTile extends ConsumerWidget {
  const TodoTaskTile({
    super.key,
    required this.listId,
    required this.task,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final int listId;
  final TodoItem task;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return _buildTile(context, theme, ref);
  }

  Widget _buildTile(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref, {
    bool enabled = true,
  }) {
    return Slidable(
      key: ValueKey(task.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: enabled
                ? (_) async {
                    await ref.read(todoRepositoryProvider).setTaskCompleted(
                          listId,
                          task.id,
                          !task.isCompleted,
                        );
                  }
                : null,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: task.isCompleted ? Icons.undo : Icons.check,
            label: task.isCompleted ? 'Undo' : 'Done',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: enabled
                ? (_) async {
                    await ref
                        .read(todoRepositoryProvider)
                        .deleteTask(task.id);
                  }
                : null,
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        onTap: enabled
            ? () => context.push('/todo/$listId/task/${task.id}')
            : null,
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: enabled
              ? (value) async {
                  await ref.read(todoRepositoryProvider).setTaskCompleted(
                        listId,
                        task.id,
                        value ?? false,
                      );
                }
              : null,
        ),
        title: Text(
          task.displayName,
          style: task.isCompleted
              ? theme.textTheme.bodyLarge?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : null,
        ),
        trailing: enabled
            ? Draggable<TodoItem>(
                data: task,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                onDragStarted: onDragStarted,
                onDragEnd: (_) => onDragEnded(),
                feedback: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: ListTile(
                      title: Text(task.displayName),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grabbing,
                    child: const Icon(Icons.drag_handle, size: 20),
                  ),
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: const Icon(Icons.drag_handle, size: 20),
                ),
              )
            : const Icon(Icons.drag_handle, size: 20),
      ),
    );
  }
}
