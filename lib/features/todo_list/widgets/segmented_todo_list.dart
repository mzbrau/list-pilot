import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/services/todo_section_service.dart';
import 'section_count_pill.dart';
import 'todo_task_tile.dart';

class SegmentedTodoList extends ConsumerStatefulWidget {
  const SegmentedTodoList({
    super.key,
    required this.listId,
    required this.items,
  });

  final int listId;
  final List<TodoItem> items;

  @override
  ConsumerState<SegmentedTodoList> createState() => _SegmentedTodoListState();
}

class _SegmentedTodoListState extends ConsumerState<SegmentedTodoList> {
  int? _draggingTaskId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = TodoSectionService.buildSections(widget.items);
    final children = <Widget>[];

    for (final section in sections) {
      children.add(
        _SectionDropTarget(
          onDrop: (task) =>
              _handleDrop(ref, section, task, section.items.length),
          builder: (isHighlighted) => Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    section.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (section.totalCount > 0)
                  SectionCountPill(
                    completedCount: section.completedCount,
                    totalCount: section.totalCount,
                  ),
              ],
            ),
          ),
        ),
      );

      for (var index = 0; index < section.items.length; index++) {
        final task = section.items[index];
        children.add(
          _TaskDropZone(
            onDrop: (dropped) => _handleDrop(ref, section, dropped, index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TodoTaskTile(
                listId: widget.listId,
                task: task,
                isDragging: _draggingTaskId == task.id,
                onDragStarted: () => setState(() => _draggingTaskId = task.id),
                onDragEnded: () => setState(() => _draggingTaskId = null),
              ),
            ),
          ),
        );
      }

      if (section.items.isNotEmpty) {
        children.add(
          _TaskDropZone(
            onDrop: (dropped) =>
                _handleDrop(ref, section, dropped, section.items.length),
            showIndicatorOnly: true,
          ),
        );
      }
    }

    return SliverList(
      delegate: SliverChildListDelegate(children),
    );
  }

  Future<void> _handleDrop(
    WidgetRef ref,
    TodoSection section,
    TodoItem task,
    int insertIndex,
  ) async {
    final currentIndex = section.items.indexWhere((i) => i.id == task.id);
    if (currentIndex != -1 && currentIndex == insertIndex) return;
    if (currentIndex != -1 && insertIndex > currentIndex) {
      insertIndex -= 1;
    }

    final movingFromAnotherSection = currentIndex == -1;
    final targetDate = movingFromAnotherSection
        ? TodoSectionService.dateForSection(section, DateTime.now())
        : null;

    await ref.read(todoRepositoryProvider).moveTaskToPosition(
          taskId: task.id,
          sectionItems: section.items,
          newIndex: insertIndex,
          newScheduledDate: targetDate,
        );
  }
}

class _SectionDropTarget extends StatelessWidget {
  const _SectionDropTarget({
    required this.onDrop,
    required this.builder,
  });

  final Future<void> Function(TodoItem task) onDrop;
  final Widget Function(bool isHighlighted) builder;

  @override
  Widget build(BuildContext context) {
    return DragTarget<TodoItem>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidateData, rejectedData) {
        return builder(candidateData.isNotEmpty);
      },
    );
  }
}

class _TaskDropZone extends StatelessWidget {
  const _TaskDropZone({
    required this.onDrop,
    this.child,
    this.showIndicatorOnly = false,
  });

  final Future<void> Function(TodoItem task) onDrop;
  final Widget? child;
  final bool showIndicatorOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DragTarget<TodoItem>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        final indicator = AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: isHighlighted ? 3 : (showIndicatorOnly ? 8 : 0),
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: showIndicatorOnly ? 0 : 2,
          ),
          decoration: BoxDecoration(
            color: isHighlighted ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        );

        if (showIndicatorOnly) {
          return indicator;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            child!,
          ],
        );
      },
    );
  }
}
