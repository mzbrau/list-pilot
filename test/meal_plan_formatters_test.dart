import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/features/meal_planning/meal_plan_formatters.dart';

void main() {
  test('formatLastEaten returns Never eaten for null', () {
    expect(formatLastEaten(null), 'Never eaten');
  });

  test('formatDaysSince handles today and past days', () {
    final now = DateTime(2026, 6, 15);
    expect(formatDaysSince(now, now: now), 'Today');
    expect(
      formatDaysSince(now.subtract(const Duration(days: 1)), now: now),
      '1 day ago',
    );
    expect(
      formatDaysSince(now.subtract(const Duration(days: 5)), now: now),
      '5 days ago',
    );
    expect(formatDaysSince(null, now: now), '');
  });

  test('formatLastEatenSummary combines date and days since', () {
    final now = DateTime(2026, 6, 15);
    final lastEaten = DateTime(2026, 6, 10);
    expect(
      formatLastEatenSummary(lastEaten, now: now),
      contains('Last eaten'),
    );
    expect(formatLastEatenSummary(null, now: now), 'Never eaten');
  });

  test('formatPortions singular and plural', () {
    expect(formatPortions(1), '1 serving');
    expect(formatPortions(4), '4 servings');
  });
}
