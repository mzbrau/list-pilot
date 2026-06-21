import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class NavigationEntry {
  const NavigationEntry({required this.location, this.extra});

  final String location;
  final Object? extra;

  @override
  bool operator ==(Object other) {
    return other is NavigationEntry &&
        other.location == location &&
        other.extra == extra;
  }

  @override
  int get hashCode => Object.hash(location, extra);
}

class NavigationHistoryState {
  const NavigationHistoryState({this.stack = const []});

  final List<NavigationEntry> stack;

  NavigationEntry? get previous =>
      stack.length >= 2 ? stack[stack.length - 2] : null;

  NavigationHistoryState copyWith({List<NavigationEntry>? stack}) {
    return NavigationHistoryState(stack: stack ?? this.stack);
  }
}

class NavigationHistoryNotifier extends Notifier<NavigationHistoryState> {
  @override
  NavigationHistoryState build() {
    return const NavigationHistoryState(
      stack: [NavigationEntry(location: '/')],
    );
  }

  void onLocationChange(String newLocation, Object? extra) {
    newLocation = normalizeLocation(newLocation);
    final newEntry = NavigationEntry(location: newLocation, extra: extra);
    final stack = List<NavigationEntry>.from(state.stack);

    if (stack.isNotEmpty && stack.last == newEntry) {
      return;
    }

    if (stack.length >= 2 && stack[stack.length - 2].location == newLocation) {
      stack.removeLast();
      state = NavigationHistoryState(stack: stack);
      return;
    }

    if (newLocation == '/') {
      state = NavigationHistoryState(stack: [newEntry]);
      return;
    }

    if (stack.isEmpty) {
      state = NavigationHistoryState(stack: [newEntry]);
      return;
    }

    final current = stack.last.location;
    if (current == '/' || newLocation.startsWith('$current/')) {
      stack.add(newEntry);
      state = NavigationHistoryState(stack: stack);
      return;
    }

    state = NavigationHistoryState(
      stack: [
        const NavigationEntry(location: '/'),
        newEntry,
      ],
    );
  }
}

final navigationHistoryProvider =
    NotifierProvider<NavigationHistoryNotifier, NavigationHistoryState>(
  NavigationHistoryNotifier.new,
);
