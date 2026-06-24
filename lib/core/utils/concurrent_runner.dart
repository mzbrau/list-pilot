/// Runs [fn] over [items] with at most [concurrency] tasks in flight.
Future<List<R>> mapConcurrent<T, R>(
  List<T> items,
  Future<R> Function(T item) fn, {
  int concurrency = 4,
}) async {
  if (items.isEmpty) return [];

  final results = List<R?>.filled(items.length, null);
  var nextIndex = 0;

  Future<void> worker() async {
    while (true) {
      final index = nextIndex++;
      if (index >= items.length) break;
      results[index] = await fn(items[index]);
    }
  }

  final workers = concurrency.clamp(1, items.length);
  await Future.wait(List.generate(workers, (_) => worker()));
  return results.cast<R>();
}
