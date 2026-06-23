import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/services/recipe_duration.dart';

void main() {
  group('parseRecipeDurationToMinutes', () {
    test('parses ISO 8601 minutes', () {
      expect(parseRecipeDurationToMinutes('PT30M'), 30);
      expect(parseRecipeDurationToMinutes('PT1H30M'), 90);
      expect(parseRecipeDurationToMinutes('PT2H'), 120);
    });

    test('parses plain text durations', () {
      expect(parseRecipeDurationToMinutes('45 min'), 45);
      expect(parseRecipeDurationToMinutes('1 hour 30 minutes'), 90);
      expect(parseRecipeDurationToMinutes('2 hours'), 120);
    });

    test('returns null for empty or invalid values', () {
      expect(parseRecipeDurationToMinutes(null), isNull);
      expect(parseRecipeDurationToMinutes(''), isNull);
      expect(parseRecipeDurationToMinutes('not a time'), isNull);
    });
  });

  group('resolveRecipePrepTimeMinutes', () {
    test('prefers totalTime', () {
      expect(
        resolveRecipePrepTimeMinutes(
          totalTime: 'PT45M',
          prepTime: 'PT20M',
          cookTime: 'PT25M',
        ),
        45,
      );
    });

    test('sums prep and cook when total missing', () {
      expect(
        resolveRecipePrepTimeMinutes(
          prepTime: 'PT20M',
          cookTime: 'PT25M',
        ),
        45,
      );
    });
  });
}
