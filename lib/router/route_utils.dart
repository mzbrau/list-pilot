String normalizeLocation(String location) {
  final path = Uri.parse(location).path;
  if (path.isEmpty || path == '/') {
    return '/';
  }

  var normalized = path.startsWith('/') ? path : '/$path';
  if (normalized.endsWith('/') && normalized.length > 1) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}

bool isTabletTopLevelDetailRoute(String location) {
  final path = normalizeLocation(location);
  if (path == '/') {
    return false;
  }

  if (path == '/stats' || path == '/meals' || path == '/meal-manager') {
    return true;
  }

  final segments = Uri.parse(path).pathSegments;
  if (segments.length == 2) {
    return segments[0] == 'list' ||
        segments[0] == 'todo' ||
        segments[0] == 'take-away' ||
        segments[0] == 'receipts';
  }

  return false;
}

bool isOverviewRouteSelected(String itemRoute, String? selectedRoute) {
  if (selectedRoute == null) {
    return false;
  }

  final normalized = normalizeLocation(selectedRoute);
  if (itemRoute == '/meals' ||
      itemRoute == '/meal-manager' ||
      itemRoute == '/stats') {
    return normalized == itemRoute;
  }

  return normalized == itemRoute || normalized.startsWith('$itemRoute/');
}
