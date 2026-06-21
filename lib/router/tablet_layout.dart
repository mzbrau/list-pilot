import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation_history.dart';
import 'route_screen_builder.dart';

const tabletBreakpoint = 600.0;
const letterboxMinWindowWidth = 500.0;

bool isTabletLayoutFromSizes({
  required Size windowSize,
  Size? displayLogicalSize,
}) {
  if (windowSize.shortestSide >= tabletBreakpoint) {
    return true;
  }

  if (displayLogicalSize != null) {
    final displayShortest = displayLogicalSize.shortestSide;
    if (displayShortest >= tabletBreakpoint &&
        windowSize.width >= letterboxMinWindowWidth) {
      return true;
    }
  }

  return false;
}

bool isTabletLayout(BuildContext context) {
  final window = MediaQuery.sizeOf(context);
  Size? displayLogicalSize;
  final display = View.maybeOf(context)?.display;
  if (display != null) {
    displayLogicalSize = Size(
      display.size.width / display.devicePixelRatio,
      display.size.height / display.devicePixelRatio,
    );
  }

  return isTabletLayoutFromSizes(
    windowSize: window,
    displayLogicalSize: displayLogicalSize,
  );
}

class TabletSplitShell extends ConsumerWidget {
  const TabletSplitShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(navigationHistoryProvider);
    final tablet = isTabletLayout(context);
    final previous = history.previous;

    Widget content;
    if (!tablet || previous == null) {
      content = child;
    } else {
      content = Row(
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

    if (!kDebugMode) {
      return content;
    }

    return Stack(
      children: [
        content,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TabletDebugBanner(
            tablet: tablet,
            stackDepth: history.stack.length,
          ),
        ),
      ],
    );
  }
}

class _TabletDebugBanner extends StatelessWidget {
  const _TabletDebugBanner({
    required this.tablet,
    required this.stackDepth,
  });

  final bool tablet;
  final int stackDepth;

  @override
  Widget build(BuildContext context) {
    final window = MediaQuery.sizeOf(context);
    final display = View.maybeOf(context)?.display;
    final displaySize = display == null
        ? null
        : Size(
            display.size.width / display.devicePixelRatio,
            display.size.height / display.devicePixelRatio,
          );

    final displayLabel = displaySize == null
        ? 'n/a'
        : '${displaySize.width.toStringAsFixed(0)}x'
            '${displaySize.height.toStringAsFixed(0)}';

    return Material(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'Tablet debug: window=${window.width.toStringAsFixed(0)}x'
          '${window.height.toStringAsFixed(0)} display=$displayLabel '
          'tablet=$tablet stack=$stackDepth',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
