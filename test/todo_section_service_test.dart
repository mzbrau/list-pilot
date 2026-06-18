import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/todo_repository.dart';
import 'package:list_pilot/data/services/todo_section_service.dart';

void main() {
  group('TodoSectionService', () {
    final monday = DateTime(2026, 6, 15); // Monday

    TodoItem makeItem({
      required int id,
      required String name,
      required DateTime scheduledDate,
      bool isCompleted = false,
    }) {
      return TodoItem(
        id: id,
        listId: 1,
        displayName: name,
        notes: null,
        scheduledDate: scheduledDate,
        sortOrder: id,
        isCompleted: isCompleted,
        completedAt: isCompleted ? scheduledDate : null,
        addedAt: scheduledDate,
        reminderAt: null,
      );
    }

    test('buckets tasks into all sections on Monday', () {
      final items = [
        makeItem(id: 1, name: 'Overdue', scheduledDate: monday.subtract(const Duration(days: 2))),
        makeItem(id: 2, name: 'Today', scheduledDate: monday),
        makeItem(id: 3, name: 'Tomorrow', scheduledDate: monday.add(const Duration(days: 1))),
        makeItem(id: 4, name: 'Wed', scheduledDate: monday.add(const Duration(days: 2))),
        makeItem(id: 5, name: 'Future', scheduledDate: monday.add(const Duration(days: 10))),
      ];

      final sections = TodoSectionService.buildSections(items, now: monday);

      expect(sections, hasLength(9));
      expect(sections[0].label, 'Incomplete');
      expect(sections[0].items.map((i) => i.displayName), ['Overdue']);
      expect(sections[1].label, 'Today');
      expect(sections[1].items.map((i) => i.displayName), ['Today']);
      expect(sections[2].label, 'Tomorrow');
      expect(sections[3].label, 'Wednesday');
      expect(sections[7].label, 'Sunday');
      expect(sections[8].label, 'Future');
      expect(sections[8].items.map((i) => i.displayName), ['Future']);
    });

    test('shifts weekday labels when today is Tuesday', () {
      final tuesday = monday.add(const Duration(days: 1));
      final items = [
        makeItem(id: 1, name: 'Thu', scheduledDate: tuesday.add(const Duration(days: 2))),
      ];

      final sections = TodoSectionService.buildSections(items, now: tuesday);
      final weekdaySections = sections
          .where((s) => s.kind == TodoSectionKind.weekday)
          .map((s) => s.label)
          .toList();

      expect(weekdaySections, ['Thursday', 'Friday', 'Saturday', 'Sunday', 'Monday']);
      expect(
        sections.firstWhere((s) => s.label == 'Thursday').items,
        hasLength(1),
      );
    });

    test('completed overdue tasks do not appear in incomplete', () {
      final items = [
        makeItem(
          id: 1,
          name: 'Done overdue',
          scheduledDate: monday.subtract(const Duration(days: 1)),
          isCompleted: true,
        ),
      ];

      final sections = TodoSectionService.buildSections(items, now: monday);
      expect(sections[0].items, isEmpty);
    });

    test('section counts include completed tasks', () {
      final items = [
        makeItem(id: 1, name: 'Done', scheduledDate: monday, isCompleted: true),
        makeItem(id: 2, name: 'Open', scheduledDate: monday),
      ];

      final today = TodoSectionService.buildSections(items, now: monday)[1];
      expect(today.totalCount, 2);
      expect(today.completedCount, 1);
    });
  });

  group('TodoRepository', () {
    late AppDatabase db;
    late TodoRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = TodoRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('createList and addTask defaults to today', () async {
      final listId = await repo.createList('Chores');
      final now = DateTime(2026, 6, 15, 14, 30);
      final taskId = await repo.addTask(
        listId: listId,
        displayName: 'Wash dishes',
        scheduledDate: TodoSectionService.startOfDay(now),
      );

      final task = await repo.getTaskById(taskId);
      expect(task?.displayName, 'Wash dishes');
      expect(
        TodoSectionService.isSameDay(task!.scheduledDate, now),
        isTrue,
      );
    });

    test('moveTaskToDate updates scheduled date and sort order', () async {
      final listId = await repo.createList('Tasks');
      final taskId = await repo.addTask(
        listId: listId,
        displayName: 'Move me',
      );
      final target = DateTime(2026, 6, 20);

      await repo.moveTaskToDate(
        taskId: taskId,
        scheduledDate: target,
        sortOrder: 3,
      );

      final task = await repo.getTaskById(taskId);
      expect(TodoSectionService.isSameDay(task!.scheduledDate, target), isTrue);
      expect(task.sortOrder, 3);
    });

    test('moveTaskToPosition reorders tasks within a section', () async {
      final listId = await repo.createList('Tasks');
      final today = TodoSectionService.startOfDay(DateTime(2026, 6, 16));
      final firstId = await repo.addTask(
        listId: listId,
        displayName: 'First',
        scheduledDate: today,
      );
      final secondId = await repo.addTask(
        listId: listId,
        displayName: 'Second',
        scheduledDate: today,
      );
      final thirdId = await repo.addTask(
        listId: listId,
        displayName: 'Third',
        scheduledDate: today,
      );

      final items = await repo.watchListItems(listId).first;
      final section = TodoSectionService.buildSections(items, now: today)
          .firstWhere((s) => s.kind == TodoSectionKind.today);

      await repo.moveTaskToPosition(
        taskId: thirdId,
        sectionItems: section.items,
        newIndex: 0,
      );

      final reordered = await repo.watchListItems(listId).first;
      final todayItems = reordered
          .where((i) => TodoSectionService.isSameDay(i.scheduledDate, today))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      expect(todayItems.map((i) => i.id).toList(), [thirdId, firstId, secondId]);
    });

    test('searchTaskTitles is scoped to list', () async {
      final listA = await repo.createList('A');
      final listB = await repo.createList('B');
      await repo.addTask(listId: listA, displayName: 'Buy milk');
      await repo.addTask(listId: listB, displayName: 'Buy bread');

      final results = await repo.searchTaskTitles(listA, 'buy');
      expect(results, ['Buy milk']);
    });

    test('purgeAndArchiveCompletedBefore archives old completed tasks', () async {
      final listId = await repo.createList('Archive test');
      final taskId = await repo.addTask(
        listId: listId,
        displayName: 'Old done',
        scheduledDate: DateTime(2026, 6, 10),
      );
      await repo.setTaskCompleted(listId, taskId, true);

      await (db.update(db.todoItems)..where((t) => t.id.equals(taskId))).write(
        TodoItemsCompanion(
          completedAt: Value(DateTime(2026, 6, 10, 18)),
        ),
      );

      final purged = await repo.purgeAndArchiveCompletedBefore(
        listId,
        DateTime(2026, 6, 15),
      );
      expect(purged, 1);
      expect(await repo.getTaskById(taskId), isNull);

      final archived = await repo.watchArchivedCompleted(listId).first;
      expect(archived, hasLength(1));
      expect(archived.first.displayName, 'Old done');
    });

    test('updateTask persists reminderAt', () async {
      final listId = await repo.createList('Tasks');
      final taskId = await repo.addTask(
        listId: listId,
        displayName: 'Remind me',
      );
      final reminderAt = DateTime(2026, 6, 20, 9, 30);

      await repo.updateTask(
        id: taskId,
        reminderAt: reminderAt,
      );

      final task = await repo.getTaskById(taskId);
      expect(task?.reminderAt, reminderAt);
    });

    test('updateTask without clearReminder preserves existing reminder', () async {
      final listId = await repo.createList('Tasks');
      final taskId = await repo.addTask(
        listId: listId,
        displayName: 'Keep reminder',
      );
      final reminderAt = DateTime(2026, 6, 20, 9, 30);

      await repo.updateTask(id: taskId, reminderAt: reminderAt);
      await repo.updateTask(id: taskId, displayName: 'Renamed');

      final task = await repo.getTaskById(taskId);
      expect(task?.displayName, 'Renamed');
      expect(task?.reminderAt, reminderAt);
    });

    test('updateTask with clearReminder removes reminder', () async {
      final listId = await repo.createList('Tasks');
      final taskId = await repo.addTask(
        listId: listId,
        displayName: 'Clear reminder',
      );
      final reminderAt = DateTime(2026, 6, 20, 9, 30);

      await repo.updateTask(id: taskId, reminderAt: reminderAt);
      await repo.updateTask(id: taskId, clearReminder: true);

      final task = await repo.getTaskById(taskId);
      expect(task?.reminderAt, isNull);
    });
  });
}
