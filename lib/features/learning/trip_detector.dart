import '../../core/constants/app_constants.dart';

class TripDetector {
  bool shouldStartNewTrip({
    required DateTime? lastCheckOffAt,
    required DateTime now,
  }) {
    if (lastCheckOffAt == null) return false;
    final diff = now.difference(lastCheckOffAt);
    return diff.inHours >= AppConstants.tripInactivityHours;
  }
}
