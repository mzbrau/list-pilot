import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/services/todo_notification_service.dart';

void main() {
  test('cancelReminder does not throw before initialization', () async {
    final plugin = FlutterLocalNotificationsPlugin();
    final service = TodoNotificationService(plugin);
    await service.cancelReminder(1);
  });
}
