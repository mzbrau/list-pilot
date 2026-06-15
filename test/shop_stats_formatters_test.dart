import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/features/shop_stats/shop_stats_formatters.dart';

void main() {
  group('formatDuration', () {
    test('formats seconds only', () {
      expect(formatDuration(const Duration(seconds: 45)), '45s');
    });

    test('formats minutes and seconds', () {
      expect(formatDuration(const Duration(minutes: 12, seconds: 34)), '12m 34s');
    });

    test('formats hours and minutes', () {
      expect(formatDuration(const Duration(hours: 1, minutes: 2)), '1h 02m');
    });
  });

  group('formatMsPerItem', () {
    test('formats seconds per item', () {
      expect(formatMsPerItem(42000), '42s/item');
    });

    test('formats minutes per item', () {
      expect(formatMsPerItem(90000), '1m 30s/item');
    });
  });

  group('formatDelta', () {
    test('formats negative delta as faster', () {
      expect(formatDelta(-12000), '-12s');
    });

    test('formats positive delta as slower', () {
      expect(formatDelta(8000), '+8s');
    });
  });

  group('formatRankLabel', () {
    test('formats personal best', () {
      expect(formatRankLabel(1), 'PB');
    });

    test('formats ordinal ranks', () {
      expect(formatRankLabel(2), '2nd');
      expect(formatRankLabel(3), '3rd');
      expect(formatRankLabel(4), '4th');
    });
  });
}
