import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/lists/lists_overview_screen.dart';
import 'route_utils.dart';

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

class TabletDetailPlaceholder extends StatelessWidget {
  const TabletDetailPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLow,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select a list to get started',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabletSplitShell extends StatelessWidget {
  const TabletSplitShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tablet = isTabletLayout(context);
    final normalized = normalizeLocation(location);
    final isRoot = normalized == '/';

    Widget content;
    if (!tablet) {
      content = child;
    } else {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: ListsOverviewScreen(
              tabletSidebar: true,
              selectedRoute: isRoot ? null : normalized,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: isRoot ? const TabletDetailPlaceholder() : child,
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
            route: normalized,
          ),
        ),
      ],
    );
  }
}

class _TabletDebugBanner extends StatelessWidget {
  const _TabletDebugBanner({
    required this.tablet,
    required this.route,
  });

  final bool tablet;
  final String route;

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
          'tablet=$tablet route=$route',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
