String formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds < 0) return '0s';

  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  if (hours > 0) {
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
  if (minutes > 0) {
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }
  return '${seconds}s';
}

String formatMsPerItem(int msPerItem) {
  if (msPerItem <= 0) return '0s/item';
  final seconds = (msPerItem / 1000).round();
  if (seconds >= 60) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s/item';
  }
  return '${seconds}s/item';
}

String formatDelta(int deltaMs) {
  final seconds = (deltaMs.abs() / 1000).round();
  final sign = deltaMs < 0 ? '-' : '+';
  if (seconds >= 60) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$sign${minutes}m ${remainingSeconds}s';
  }
  return '$sign${seconds}s';
}

String formatDeltaDescription(int deltaMs, {required String reference}) {
  if (deltaMs == 0) return 'Same as $reference';
  final seconds = (deltaMs.abs() / 1000).round();
  if (deltaMs < 0) {
    return '$seconds s faster per item than $reference';
  }
  return '$seconds s slower per item than $reference';
}

String formatRankLabel(int rank) {
  if (rank == 1) return 'PB';
  if (rank == 2) return '2nd';
  if (rank == 3) return '3rd';
  return '${rank}th';
}
