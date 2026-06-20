import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:list_pilot/data/services/todo_notification_service.dart';

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  test('cancelReminder does not throw before initialization', () async {
    final plugin = FlutterLocalNotificationsPlugin();
    final service = TodoNotificationService(plugin);
    await service.cancelReminder(1);
  });

  test('scheduleReminder skips past reminders without initializing', () async {
    final plugin = FlutterLocalNotificationsPlugin();
    final service = TodoNotificationService(plugin);

    await service.scheduleReminder(
      taskId: 1,
      listId: 2,
      title: 'Past task',
      reminderAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );
  });
}
