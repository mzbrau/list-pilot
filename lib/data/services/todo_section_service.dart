import 'package:intl/intl.dart';

import '../database/app_database.dart';

enum TodoSectionKind {
  incomplete,
  today,
  tomorrow,
  weekday,
  future,
}

class TodoSection {
  const TodoSection({
    required this.kind,
    required this.label,
    required this.scheduledDate,
    required this.items,
    required this.totalCount,
    required this.completedCount,
  });

  final TodoSectionKind kind;
  final String label;
  final DateTime? scheduledDate;
  final List<TodoItem> items;
  final int totalCount;
  final int completedCount;
}

class TodoSectionService {
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static List<TodoSection> buildSections(
    List<TodoItem> items, {
    DateTime? now,
  }) {
    final current = startOfDay(now ?? DateTime.now());
    final weekdayFormat = DateFormat('EEEE');

    final sections = <TodoSection>[
      _buildSection(
        kind: TodoSectionKind.incomplete,
        label: 'Incomplete',
        scheduledDate: null,
        items: items,
        current: current,
        matches: (item) =>
            !item.isCompleted && startOfDay(item.scheduledDate).isBefore(current),
      ),
      _buildSection(
        kind: TodoSectionKind.today,
        label: 'Today',
        scheduledDate: current,
        items: items,
        current: current,
        matches: (item) => isSameDay(item.scheduledDate, current),
      ),
      _buildSection(
        kind: TodoSectionKind.tomorrow,
        label: 'Tomorrow',
        scheduledDate: current.add(const Duration(days: 1)),
        items: items,
        current: current,
        matches: (item) =>
            isSameDay(item.scheduledDate, current.add(const Duration(days: 1))),
      ),
      for (var offset = 2; offset <= 6; offset++)
        _buildSection(
          kind: TodoSectionKind.weekday,
          label: weekdayFormat.format(current.add(Duration(days: offset))),
          scheduledDate: current.add(Duration(days: offset)),
          items: items,
          current: current,
          matches: (item) =>
              isSameDay(item.scheduledDate, current.add(Duration(days: offset))),
        ),
      _buildSection(
        kind: TodoSectionKind.future,
        label: 'Future',
        scheduledDate: current.add(const Duration(days: 7)),
        items: items,
        current: current,
        matches: (item) =>
            !startOfDay(item.scheduledDate)
                .isBefore(current.add(const Duration(days: 7))),
      ),
    ];

    return sections;
  }

  static TodoSection _buildSection({
    required TodoSectionKind kind,
    required String label,
    required DateTime? scheduledDate,
    required List<TodoItem> items,
    required DateTime current,
    required bool Function(TodoItem item) matches,
  }) {
    final sectionItems = items.where(matches).toList()
      ..sort((a, b) {
        final orderCompare = a.sortOrder.compareTo(b.sortOrder);
        if (orderCompare != 0) return orderCompare;
        return a.addedAt.compareTo(b.addedAt);
      });

    final completedCount = sectionItems.where((i) => i.isCompleted).length;

    return TodoSection(
      kind: kind,
      label: label,
      scheduledDate: scheduledDate,
      items: sectionItems,
      totalCount: sectionItems.length,
      completedCount: completedCount,
    );
  }

  static DateTime dateForSection(TodoSection section, DateTime now) {
    final current = startOfDay(now);
    return switch (section.kind) {
      TodoSectionKind.incomplete => current.subtract(const Duration(days: 1)),
      TodoSectionKind.today => current,
      TodoSectionKind.tomorrow => current.add(const Duration(days: 1)),
      TodoSectionKind.weekday => section.scheduledDate ?? current,
      TodoSectionKind.future => current.add(const Duration(days: 7)),
    };
  }
}
