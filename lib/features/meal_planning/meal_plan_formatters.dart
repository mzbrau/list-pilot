import 'package:intl/intl.dart';

String formatLastEaten(DateTime? lastEaten) {
  if (lastEaten == null) return 'Never eaten';
  return 'Last eaten ${DateFormat.MMMd().format(lastEaten)}';
}

String formatDaysSince(DateTime? lastEaten, {DateTime? now}) {
  if (lastEaten == null) return '';
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final eatenDay =
      DateTime(lastEaten.year, lastEaten.month, lastEaten.day);
  final days = today.difference(eatenDay).inDays;
  if (days == 0) return 'Today';
  if (days == 1) return '1 day ago';
  return '$days days ago';
}

String formatLastEatenSummary(DateTime? lastEaten, {DateTime? now}) {
  if (lastEaten == null) return 'Never eaten';
  final daysSince = formatDaysSince(lastEaten, now: now);
  return '${formatLastEaten(lastEaten)} · $daysSince';
}

String formatPortions(int portions) {
  if (portions == 1) return '1 serving';
  return '$portions servings';
}
