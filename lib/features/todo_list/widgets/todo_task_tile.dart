import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.isDragging = false,
  });

  final int listId;
  final TodoItem task;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final bool isDragging;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth;
        final tile = _buildTile(context, theme, ref, tileWidth: tileWidth);

        return Opacity(
          opacity: isDragging ? 0 : 1,
          child: tile,
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref, {
    required double tileWidth,
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
      child: _buildInteractiveListTile(
        context,
        theme,
        ref,
        tileWidth: tileWidth,
        enabled: enabled,
      ),
    );
  }

  Widget _buildInteractiveListTile(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref, {
    required double tileWidth,
    required bool enabled,
  }) {
    return ListTile(
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
      title: _buildTitle(theme),
      trailing: _buildTrailing(
        theme,
        tileWidth: tileWidth,
        enabled: enabled,
        forFeedback: false,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      task.displayName,
      style: task.isCompleted
          ? theme.textTheme.bodyLarge?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.colorScheme.onSurfaceVariant,
            )
          : null,
    );
  }

  Widget _buildTrailing(
    ThemeData theme, {
    required double tileWidth,
    required bool enabled,
    required bool forFeedback,
  }) {
    final handle = forFeedback
        ? const Icon(Icons.drag_handle, size: 20)
        : const MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Icon(Icons.drag_handle, size: 20),
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (task.reminderAt != null)
          Icon(
            Icons.notifications_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        if (enabled && !forFeedback)
          Draggable<TodoItem>(
            data: task,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragStarted: () {
              HapticFeedback.lightImpact();
              onDragStarted();
            },
            onDragEnd: (_) => onDragEnded(),
            feedback: _buildDragFeedback(theme, tileWidth),
            childWhenDragging: const SizedBox(width: 20, height: 20),
            child: handle,
          )
        else
          handle,
      ],
    );
  }

  Widget _buildDragFeedback(ThemeData theme, double tileWidth) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: tileWidth,
        child: IgnorePointer(
          child: ListTile(
            enabled: false,
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: null,
            ),
            title: _buildTitle(theme),
            trailing: _buildTrailing(
              theme,
              tileWidth: tileWidth,
              enabled: false,
              forFeedback: true,
            ),
          ),
        ),
      ),
    );
  }
}
