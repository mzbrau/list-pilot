import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

bool get _keepScreenOn =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// Keeps the screen awake on mobile while [action] runs.
Future<T> runWithImportWakelock<T>(Future<T> Function() action) async {
  if (!_keepScreenOn) return action();
  await WakelockPlus.enable();
  try {
    return await action();
  } finally {
    await WakelockPlus.disable();
  }
}
