import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/services/todo_section_service.dart';

class TodoTaskDetailScreen extends ConsumerStatefulWidget {
  const TodoTaskDetailScreen({
    super.key,
    required this.listId,
    required this.taskId,
  });

  final int listId;
  final int taskId;

  @override
  ConsumerState<TodoTaskDetailScreen> createState() =>
      _TodoTaskDetailScreenState();
}

class _TodoTaskDetailScreenState extends ConsumerState<TodoTaskDetailScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  bool _initialized = false;
  DateTime? _scheduledDate;
  DateTime? _reminderAt;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initFromTask(TodoItem task) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = task.displayName;
    _notesController.text = task.notes ?? '';
    _scheduledDate = task.scheduledDate;
    _reminderAt = task.reminderAt;
  }

  Future<void> _save(TodoItem task, {bool clearReminder = false}) async {
    final repo = ref.read(todoRepositoryProvider);
    final notifications = ref.read(todoNotificationServiceProvider);

    await repo.updateTask(
      id: task.id,
      displayName: _nameController.text.trim(),
      notes: _notesController.text.trim(),
      clearNotes: _notesController.text.trim().isEmpty,
      scheduledDate: _scheduledDate,
      reminderAt: _reminderAt,
      clearReminder: clearReminder,
    );

    if (_reminderAt != null && !task.isCompleted) {
      await notifications.requestPermissions();
      await notifications.scheduleReminder(
        taskId: task.id,
        listId: widget.listId,
        title: _nameController.text.trim(),
        reminderAt: _reminderAt!,
      );
    } else {
      await notifications.cancelReminder(task.id);
    }
  }

  Future<void> _pickScheduledDate(TodoItem task) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _scheduledDate = TodoSectionService.startOfDay(picked));
      await _save(task);
    }
  }

  Future<void> _pickReminder(TodoItem task) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _reminderAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
    await _save(task);
  }

  Future<void> _clearReminder(TodoItem task) async {
    setState(() => _reminderAt = null);
    await _save(task, clearReminder: true);
  }

  Future<void> _deleteTask(BuildContext context, TodoItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Remove "${task.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(todoRepositoryProvider).deleteTask(task.id);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(todoTaskProvider(widget.taskId));
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.jm();

    return taskAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (task) {
        if (task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Task not found')),
          );
        }

        _initFromTask(task);

        return PopScope(
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) await _save(task);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Task details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteTask(context, task),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Task name'),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => _save(task),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 5,
                  onChanged: (_) => _save(task),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Scheduled date'),
                  subtitle: Text(
                    _scheduledDate != null
                        ? dateFormat.format(_scheduledDate!)
                        : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () => _pickScheduledDate(task),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reminder'),
                  subtitle: Text(
                    _reminderAt != null
                        ? '${dateFormat.format(_reminderAt!)} at ${timeFormat.format(_reminderAt!)}'
                        : 'No reminder set',
                  ),
                  trailing: _reminderAt != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _clearReminder(task),
                        )
                      : const Icon(Icons.notifications_outlined),
                  onTap: () => _pickReminder(task),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
