/// Parses Schema.org ISO 8601 durations and common recipe time strings to minutes.
int? parseRecipeDurationToMinutes(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  final upper = trimmed.toUpperCase();
  if (upper.startsWith('P') || upper.startsWith('-P')) {
    return _parseIso8601DurationToMinutes(trimmed);
  }

  return _parsePlainTextDurationToMinutes(trimmed);
}

int? resolveRecipePrepTimeMinutes({
  String? totalTime,
  String? prepTime,
  String? cookTime,
}) {
  final total = parseRecipeDurationToMinutes(totalTime);
  if (total != null) return total;

  final prep = parseRecipeDurationToMinutes(prepTime);
  final cook = parseRecipeDurationToMinutes(cookTime);
  if (prep != null && cook != null) return prep + cook;
  return prep ?? cook;
}

int? _parseIso8601DurationToMinutes(String value) {
  final match = RegExp(
    r'^-?P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
    caseSensitive: false,
  ).firstMatch(value.trim());
  if (match == null) return null;

  final days = int.tryParse(match.group(1) ?? '') ?? 0;
  final hours = int.tryParse(match.group(2) ?? '') ?? 0;
  final minutes = int.tryParse(match.group(3) ?? '') ?? 0;
  final seconds = double.tryParse(match.group(4) ?? '') ?? 0;

  final totalMinutes = days * 24 * 60 + hours * 60 + minutes + (seconds / 60).round();
  return totalMinutes > 0 ? totalMinutes : null;
}

int? _parsePlainTextDurationToMinutes(String value) {
  final lower = value.toLowerCase();
  var total = 0;
  var matched = false;

  final hourMinute = RegExp(
    r'(\d+)\s*(?:hours?|hrs?|h)\s*(?:and\s*)?(\d+)\s*(?:minutes?|mins?|m)\b',
  ).firstMatch(lower);
  if (hourMinute != null) {
    final hours = int.tryParse(hourMinute.group(1)!) ?? 0;
    final minutes = int.tryParse(hourMinute.group(2)!) ?? 0;
    total += hours * 60 + minutes;
    matched = true;
  }

  if (!matched) {
    for (final match in RegExp(r'(\d+)\s*(?:hours?|hrs?|h)\b').allMatches(lower)) {
      total += (int.tryParse(match.group(1)!) ?? 0) * 60;
      matched = true;
    }
    for (final match
        in RegExp(r'(\d+)\s*(?:minutes?|mins?|m)\b').allMatches(lower)) {
      total += int.tryParse(match.group(1)!) ?? 0;
      matched = true;
    }
  }

  return matched && total > 0 ? total : null;
}
