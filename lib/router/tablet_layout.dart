import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation_history.dart';
import 'route_screen_builder.dart';

bool isTabletLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).shortestSide >= 600;
}

class TabletSplitShell extends ConsumerWidget {
  const TabletSplitShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isTabletLayout(context)) {
      return child;
    }

    final previous = ref.watch(navigationHistoryProvider).previous;
    if (previous == null) {
      return child;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: buildScreenForLocation(
            previous.location,
            extra: previous.extra,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: child,
        ),
      ],
    );
  }
}
