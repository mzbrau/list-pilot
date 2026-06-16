import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../repositories/todo_repository.dart';

class TodoNotificationService {
  TodoNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _channelId = 'todo_reminders';
  static const _channelName = 'Todo Reminders';

  static bool get isSupported {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  Future<void> initialize({
    void Function(String? payload)? onNotificationTap,
  }) async {
    if (_initialized || !isSupported) return;

    tz_data.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      debugPrint('TodoNotificationService: timezone lookup failed: $e');
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (!isSupported) return false;

    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final macOS = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (macOS != null) {
      final granted = await macOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> scheduleReminder({
    required int taskId,
    required int listId,
    required String title,
    required DateTime reminderAt,
  }) async {
    if (!_initialized || !isSupported) return;
    if (reminderAt.isBefore(DateTime.now())) {
      await cancelReminder(taskId);
      return;
    }

    final payload = jsonEncode({'listId': listId, 'taskId': taskId});
    final scheduled = tz.TZDateTime.from(reminderAt, tz.local);

    await _plugin.zonedSchedule(
      id: taskId,
      title: 'Todo reminder',
      body: title,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelReminder(int taskId) async {
    if (!_initialized) return;
    await _plugin.cancel(id: taskId);
  }

  Future<void> rescheduleAll(TodoRepository repo) async {
    if (!_initialized || !isSupported) return;

    final tasks = await repo.getTasksWithReminders();
    for (final task in tasks) {
      if (task.reminderAt == null || task.isCompleted) {
        await cancelReminder(task.id);
        continue;
      }
      await scheduleReminder(
        taskId: task.id,
        listId: task.listId,
        title: task.displayName,
        reminderAt: task.reminderAt!,
      );
    }
  }
}
