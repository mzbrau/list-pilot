import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_utils.dart';
import 'tablet_layout.dart';

bool _canPop(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router != null) {
    return context.canPop();
  }
  return Navigator.canPop(context);
}

void popOrGoHome(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router != null) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
    return;
  }

  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

Widget? overviewBackButton(BuildContext context) {
  if (isTabletLayout(context)) {
    final location = GoRouterState.of(context).uri.toString();
    if (isTabletTopLevelDetailRoute(location)) {
      return null;
    }
  }

  return IconButton(
    icon: const BackButtonIcon(),
    onPressed: () => popOrGoHome(context),
  );
}

Widget popOrGoHomeScope({required Widget child}) {
  return Builder(
    builder: (context) {
      final router = GoRouter.maybeOf(context);
      return PopScope(
        canPop: _canPop(context),
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && router != null) {
            context.go('/');
          }
        },
        child: child,
      );
    },
  );
}
