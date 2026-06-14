class AppConstants {
  static const String appName = 'List Pilot';

  /// Hours of inactivity before starting a new shopping trip.
  static const int tripInactivityHours = 4;

  /// Minimum trip samples before learned order overrides defaults.
  static const int minSamplesForLearnedOrder = 3;

  /// Debounce for rank recomputation in milliseconds.
  static const int rankRecomputeDebounceMs = 500;

  /// Autocomplete debounce in milliseconds.
  static const int autocompleteDebounceMs = 150;

  /// Max autocomplete suggestions shown.
  static const int autocompleteLimit = 8;

  /// Bulk check window in seconds (3+ checks = bulk).
  static const int bulkCheckWindowSeconds = 2;

  /// Weight multiplier for bulk-check trips.
  static const double bulkCheckWeight = 0.25;

  static const String themeModeKey = 'theme_mode';
}

class QuantityUnits {
  static const String count = 'count';
  static const String g = 'g';
  static const String kg = 'kg';
  static const String ml = 'ml';
  static const String l = 'L';

  static const List<String> all = [count, g, kg, ml, l];

  static String label(String unit) {
    switch (unit) {
      case count:
        return 'Count';
      case g:
        return 'g';
      case kg:
        return 'kg';
      case ml:
        return 'ml';
      case l:
        return 'L';
      default:
        return unit;
    }
  }
}
