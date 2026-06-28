import 'package:shared_preferences/shared_preferences.dart';

import 'sync_id_generator.dart';

const _deviceIdKey = 'list_pilot_device_id';

/// Stable per-install identifier used for LWW tie-breaking.
class DeviceIdService {
  DeviceIdService(this._prefs);

  final SharedPreferences _prefs;
  String? _cached;

  static Future<DeviceIdService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return DeviceIdService(prefs);
  }

  String get deviceId {
    _cached ??= _prefs.getString(_deviceIdKey);
    if (_cached == null || _cached!.isEmpty) {
      _cached = generateSyncId();
      _prefs.setString(_deviceIdKey, _cached!);
    }
    return _cached!;
  }
}
