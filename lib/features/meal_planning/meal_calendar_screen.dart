import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/providers/app_providers.dart';

class MealCalendarScreen extends ConsumerStatefulWidget {
  const MealCalendarScreen({super.key});

  @override
  ConsumerState<MealCalendarScreen> createState() =>
      _MealCalendarScreenState();
}

class _MealCalendarScreenState extends ConsumerState<MealCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Set<DateTime> _eventDays = {};

  @override
  void initState() {
    super.initState();
    _loadEventDays();
  }

  Future<void> _loadEventDays() async {
    final start = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    final end = DateTime(_focusedDay.year, _focusedDay.month + 2, 0);
    final events = await ref
        .read(mealRepositoryProvider)
        .getCheckOffEventsInRange(start, end);
    if (!mounted) return;
    setState(() {
      _eventDays = events
          .map(
            (e) => DateTime(
              e.checkedAt.year,
              e.checkedAt.month,
              e.checkedAt.day,
            ),
          )
          .toSet();
    });
  }

  bool _hasEvent(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _eventDays.contains(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealsAsync = ref.watch(mealsEatenOnDateProvider(_selectedDay));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal calendar'),
      ),
      body: Column(
        children: [
          TableCalendar<void>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadEventDays();
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) => _hasEvent(day) ? [null] : [],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat.yMMMMd().format(_selectedDay),
                style: theme.textTheme.titleSmall,
              ),
            ),
          ),
          Expanded(
            child: mealsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'No meals recorded on this day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.restaurant_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(entry.meal.displayName),
                        subtitle: Text(
                          DateFormat.jm().format(entry.event.checkedAt),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
