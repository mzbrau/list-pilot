import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/services/todo_section_service.dart';
import 'package:list_pilot/features/todo_list/widgets/section_count_pill.dart';
import 'package:list_pilot/features/todo_list/widgets/segmented_todo_list.dart';

void main() {
  testWidgets('Segmented todo list shows Today section with count pill', (tester) async {
    final today = TodoSectionService.startOfDay(DateTime.now());
    final items = [
      TodoItem(
        id: 1,
        listId: 1,
        displayName: 'Buy groceries',
        notes: null,
        scheduledDate: today,
        sortOrder: 1,
        isCompleted: false,
        completedAt: null,
        addedAt: today,
        reminderAt: null,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SegmentedTodoList(listId: 1, items: items),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Buy groceries'), findsOneWidget);
    expect(find.byType(SectionCountPill), findsWidgets);
    expect(find.text('0/1'), findsOneWidget);
  });
}
