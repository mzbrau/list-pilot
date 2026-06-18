import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/services/todo_section_service.dart';
import 'package:list_pilot/features/todo_list/widgets/todo_task_tile.dart';

void main() {
  TodoItem buildTask({DateTime? reminderAt}) {
    final today = TodoSectionService.startOfDay(DateTime.now());
    return TodoItem(
      id: 1,
      listId: 1,
      displayName: 'Buy groceries',
      notes: null,
      scheduledDate: today,
      sortOrder: 1,
      isCompleted: false,
      completedAt: null,
      addedAt: today,
      reminderAt: reminderAt,
    );
  }

  Future<void> pumpTile(WidgetTester tester, TodoItem task) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TodoTaskTile(
              listId: 1,
              task: task,
              onDragStarted: () {},
              onDragEnded: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows reminder icon when task has a reminder', (tester) async {
    final reminderAt = DateTime.now().add(const Duration(hours: 2));
    await pumpTile(tester, buildTask(reminderAt: reminderAt));

    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
  });

  testWidgets('hides reminder icon when task has no reminder', (tester) async {
    await pumpTile(tester, buildTask());

    expect(find.byIcon(Icons.notifications_outlined), findsNothing);
  });
}
