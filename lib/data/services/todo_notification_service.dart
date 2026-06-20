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
  void Function(String? payload)? _onNotificationTap;

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

    _onNotificationTap = onNotificationTap;

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
        _onNotificationTap?.call(response.payload);
      },
    );

    await _configureAndroidChannel();
    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize(onNotificationTap: _onNotificationTap);
    }
  }

  Future<void> _configureAndroidChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Reminders for todo tasks',
        importance: Importance.high,
      ),
    );
  }

  Future<bool> requestPermissions() async {
    if (!isSupported) return false;
    await _ensureInitialized();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final notificationsGranted =
          await android.requestNotificationsPermission();
      await android.requestExactAlarmsPermission();
      return notificationsGranted ?? false;
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

  tz.TZDateTime _toScheduledTime(DateTime reminderAt) {
    final local = reminderAt.isUtc ? reminderAt.toLocal() : reminderAt;
    return tz.TZDateTime(
      tz.local,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    );
  }

  Future<void> scheduleReminder({
    required int taskId,
    required int listId,
    required String title,
    required DateTime reminderAt,
  }) async {
    if (!isSupported) return;

    await _ensureInitialized();

    if (reminderAt.isBefore(DateTime.now())) {
      await cancelReminder(taskId);
      return;
    }

    final payload = jsonEncode({'listId': listId, 'taskId': taskId});
    final scheduled = _toScheduledTime(reminderAt);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Reminders for todo tasks',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id: taskId,
        title: 'Todo reminder',
        body: title,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint(
        'TodoNotificationService: exact schedule failed, retrying inexact: $e',
      );
      await _plugin.zonedSchedule(
        id: taskId,
        title: 'Todo reminder',
        body: title,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  Future<void> cancelReminder(int taskId) async {
    if (!_initialized) return;
    await _plugin.cancel(id: taskId);
  }

  Future<void> rescheduleAll(TodoRepository repo) async {
    if (!isSupported) return;

    await _ensureInitialized();

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
