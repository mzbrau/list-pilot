import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../services/todo_section_service.dart';

typedef TodoNotificationCallback = Future<void> Function(int taskId);

class TodoRepository {
  TodoRepository(this._db, {TodoNotificationCallback? onCancelReminder})
      : _onCancelReminder = onCancelReminder;

  final AppDatabase _db;
  final TodoNotificationCallback? _onCancelReminder;

  Stream<List<TodoList>> watchAllLists() => _db.watchAllTodoLists();

  Future<TodoList?> getListById(int id) => _db.getTodoListById(id);

  Future<int> createList(String name) async {
    final now = DateTime.now();
    return _db.into(_db.todoLists).insert(
          TodoListsCompanion.insert(
            name: name.trim(),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> renameList(int id, String name) async {
    await (_db.update(_db.todoLists)..where((t) => t.id.equals(id))).write(
      TodoListsCompanion(
        name: Value(name.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateListBackgroundColor(int id, int? backgroundColor) async {
    await (_db.update(_db.todoLists)..where((t) => t.id.equals(id))).write(
      TodoListsCompanion(
        backgroundColor: Value(backgroundColor),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteList(int id) async {
    final items = await (_db.select(_db.todoItems)
          ..where((t) => t.listId.equals(id)))
        .get();
    for (final item in items) {
      await _cancelReminderIfNeeded(item.id);
    }
    await (_db.delete(_db.todoCompletedArchive)
          ..where((t) => t.listId.equals(id)))
        .go();
    await (_db.delete(_db.todoItems)..where((t) => t.listId.equals(id))).go();
    await (_db.delete(_db.todoLists)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<TodoItem>> watchListItems(int listId) =>
      _db.watchTodoItems(listId);

  Future<TodoItem?> getTaskById(int id) => _db.getTodoItemById(id);

  Stream<TodoItem?> watchTaskById(int id) => _db.watchTodoItemById(id);

  Future<List<TodoItem>> getTasksWithReminders() =>
      _db.getTodoItemsWithReminders();

  Future<int> addTask({
    required int listId,
    required String displayName,
    DateTime? scheduledDate,
  }) async {
    final now = DateTime.now();
    final date = scheduledDate ?? TodoSectionService.startOfDay(now);
    final normalizedDate = TodoSectionService.startOfDay(date);

    final existingItems = await (_db.select(_db.todoItems)
          ..where(
            (t) =>
                t.listId.equals(listId) &
                t.scheduledDate.equals(normalizedDate),
          ))
        .get();
    final maxOrder = existingItems.isEmpty
        ? 0
        : existingItems.map((i) => i.sortOrder).reduce((a, b) => a > b ? a : b);

    final taskId = await _db.into(_db.todoItems).insert(
          TodoItemsCompanion.insert(
            listId: listId,
            displayName: displayName.trim(),
            scheduledDate: normalizedDate,
            sortOrder: Value(maxOrder + 1),
            addedAt: now,
          ),
        );

    await (_db.update(_db.todoLists)..where((t) => t.id.equals(listId))).write(
      TodoListsCompanion(updatedAt: Value(now)),
    );

    return taskId;
  }

  Future<void> updateTask({
    required int id,
    String? displayName,
    String? notes,
    bool clearNotes = false,
    DateTime? scheduledDate,
    DateTime? reminderAt,
    bool clearReminder = false,
    int? sortOrder,
  }) async {
    final item = await getTaskById(id);
    if (item == null) return;

    await (_db.update(_db.todoItems)..where((t) => t.id.equals(id))).write(
      TodoItemsCompanion(
        displayName: displayName != null
            ? Value(displayName.trim())
            : const Value.absent(),
        notes: clearNotes
            ? const Value(null)
            : notes != null
                ? Value(notes)
                : const Value.absent(),
        scheduledDate: scheduledDate != null
            ? Value(TodoSectionService.startOfDay(scheduledDate))
            : const Value.absent(),
        reminderAt: clearReminder
            ? const Value(null)
            : reminderAt != null
                ? Value(reminderAt)
                : const Value.absent(),
        sortOrder:
            sortOrder != null ? Value(sortOrder) : const Value.absent(),
      ),
    );

    if (clearReminder) {
      await _cancelReminderIfNeeded(id);
    }

    await (_db.update(_db.todoLists)..where((t) => t.id.equals(item.listId)))
        .write(TodoListsCompanion(updatedAt: Value(DateTime.now())));
  }

  Future<void> setTaskCompleted(
    int listId,
    int taskId,
    bool completed,
  ) async {
    final now = DateTime.now();
    await (_db.update(_db.todoItems)..where((t) => t.id.equals(taskId))).write(
      TodoItemsCompanion(
        isCompleted: Value(completed),
        completedAt: completed ? Value(now) : const Value(null),
      ),
    );

    await (_db.update(_db.todoLists)..where((t) => t.id.equals(listId))).write(
      TodoListsCompanion(updatedAt: Value(now)),
    );
  }

  Future<void> deleteTask(int taskId) async {
    final item = await getTaskById(taskId);
    if (item == null) return;

    await _cancelReminderIfNeeded(taskId);
    await (_db.delete(_db.todoItems)..where((t) => t.id.equals(taskId))).go();
    await (_db.update(_db.todoLists)..where((t) => t.id.equals(item.listId)))
        .write(TodoListsCompanion(updatedAt: Value(DateTime.now())));
  }

  Future<void> moveTaskToDate({
    required int taskId,
    required DateTime scheduledDate,
    required int sortOrder,
  }) async {
    final item = await getTaskById(taskId);
    if (item == null) return;

    final normalizedDate = TodoSectionService.startOfDay(scheduledDate);
    await (_db.update(_db.todoItems)..where((t) => t.id.equals(taskId))).write(
      TodoItemsCompanion(
        scheduledDate: Value(normalizedDate),
        sortOrder: Value(sortOrder),
      ),
    );

    await (_db.update(_db.todoLists)..where((t) => t.id.equals(item.listId)))
        .write(TodoListsCompanion(updatedAt: Value(DateTime.now())));
  }

  /// Moves [taskId] to [newIndex] within [sectionItems], optionally changing date.
  Future<void> moveTaskToPosition({
    required int taskId,
    required List<TodoItem> sectionItems,
    required int newIndex,
    DateTime? newScheduledDate,
  }) async {
    final task = await getTaskById(taskId);
    if (task == null) return;

    final ordered = sectionItems.where((i) => i.id != taskId).toList();
    final index = newIndex.clamp(0, ordered.length);
    ordered.insert(index, task);

    final normalizedDate = newScheduledDate != null
        ? TodoSectionService.startOfDay(newScheduledDate)
        : null;
    final now = DateTime.now();

    for (var i = 0; i < ordered.length; i++) {
      final item = ordered[i];
      final isMovedTask = item.id == taskId;
      await (_db.update(_db.todoItems)..where((t) => t.id.equals(item.id)))
          .write(
        TodoItemsCompanion(
          scheduledDate: isMovedTask && normalizedDate != null
              ? Value(normalizedDate)
              : const Value.absent(),
          sortOrder: Value(i),
        ),
      );
    }

    await (_db.update(_db.todoLists)..where((t) => t.id.equals(task.listId)))
        .write(TodoListsCompanion(updatedAt: Value(now)));
  }

  Future<List<String>> searchTaskTitles(
    int listId,
    String query, {
    int limit = 8,
  }) =>
      _db.searchTodoTaskTitles(listId, query, limit: limit);

  Stream<List<TodoCompletedArchiveData>> watchArchivedCompleted(int listId) =>
      _db.watchArchivedCompleted(listId);

  Future<int> purgeAndArchiveCompletedBefore(
    int listId,
    DateTime beforeDate,
  ) async {
    final cutoff = TodoSectionService.startOfDay(beforeDate);
    final completed = await (_db.select(_db.todoItems)
          ..where(
            (t) =>
                t.listId.equals(listId) &
                t.isCompleted.equals(true) &
                t.completedAt.isSmallerThanValue(cutoff),
          ))
        .get();

    final now = DateTime.now();
    for (final item in completed) {
      await _db.into(_db.todoCompletedArchive).insert(
            TodoCompletedArchiveCompanion.insert(
              listId: listId,
              displayName: item.displayName,
              notes: Value(item.notes),
              scheduledDate: item.scheduledDate,
              completedAt: item.completedAt!,
              archivedAt: now,
            ),
          );
      await _cancelReminderIfNeeded(item.id);
      await (_db.delete(_db.todoItems)..where((t) => t.id.equals(item.id)))
          .go();
    }

    return completed.length;
  }

  Future<void> _cancelReminderIfNeeded(int taskId) async {
    await _onCancelReminder?.call(taskId);
  }
}
