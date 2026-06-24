import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/core/utils/concurrent_runner.dart';

void main() {
  test('mapConcurrent runs all items with bounded concurrency', () async {
    var inFlight = 0;
    var maxInFlight = 0;
    final items = List.generate(8, (index) => index);

    final results = await mapConcurrent(
      items,
      (item) async {
        inFlight++;
        maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        inFlight--;
        return item * 2;
      },
      concurrency: 4,
    );

    expect(results, [0, 2, 4, 6, 8, 10, 12, 14]);
    expect(maxInFlight, lessThanOrEqualTo(4));
    expect(maxInFlight, greaterThan(1));
  });

  test('mapConcurrent returns empty list for empty input', () async {
    final results = await mapConcurrent<int, int>(
      const [],
      (item) async => item,
    );
    expect(results, isEmpty);
  });
}
