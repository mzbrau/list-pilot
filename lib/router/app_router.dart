import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'navigation_history.dart';
import 'route_screen_builder.dart';
import 'tablet_layout.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => TabletSplitShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => buildScreenForLocation(
              state.uri.toString(),
              extra: state.extra,
            ),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => buildScreenForLocation(
              state.uri.toString(),
              extra: state.extra,
            ),
          ),
          GoRoute(
            path: '/meals',
            builder: (context, state) => buildScreenForLocation(
              state.uri.toString(),
              extra: state.extra,
            ),
            routes: [
              GoRoute(
                path: 'calendar',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
              ),
              GoRoute(
                path: ':mealId',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/meal-manager',
            builder: (context, state) => buildScreenForLocation(
              state.uri.toString(),
              extra: state.extra,
            ),
            routes: [
              GoRoute(
                path: 'import',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
                routes: [
                  GoRoute(
                    path: 'extract',
                    builder: (context, state) => buildScreenForLocation(
                      state.uri.toString(),
                      extra: state.extra,
                    ),
                  ),
                  GoRoute(
                    path: 'photo',
                    builder: (context, state) => buildScreenForLocation(
                      state.uri.toString(),
                      extra: state.extra,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: ':mealId',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/list/:id',
            builder: (context, state) => buildScreenForLocation(
              state.uri.toString(),
              extra: state.extra,
            ),
            routes: [
              GoRoute(
                path: 'item/:itemId',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/todo/:id',
            builder: (context, state) => buildScreenForLocation(
              state.uri.toString(),
              extra: state.extra,
            ),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
              ),
              GoRoute(
                path: 'task/:taskId',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/take-away/:id',
            builder: (context, state) => buildScreenForLocation(
              state.uri.toString(),
              extra: state.extra,
            ),
            routes: [
              GoRoute(
                path: 'import',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
              ),
              GoRoute(
                path: 'menu/:menuId',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
                routes: [
                  GoRoute(
                    path: 'order',
                    builder: (context, state) => buildScreenForLocation(
                      state.uri.toString(),
                      extra: state.extra,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/receipts/:id',
            builder: (context, state) => buildScreenForLocation(
              state.uri.toString(),
              extra: state.extra,
            ),
            routes: [
              GoRoute(
                path: 'insights',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
              ),
              GoRoute(
                path: 'receipt/:receiptId',
                builder: (context, state) => buildScreenForLocation(
                  state.uri.toString(),
                  extra: state.extra,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  void syncHistory() {
    final config = router.routerDelegate.currentConfiguration;
    ref.read(navigationHistoryProvider.notifier).onLocationChange(
          config.uri.toString(),
          config.extra,
        );
  }

  router.routerDelegate.addListener(syncHistory);

  ref.onDispose(() {
    router.routerDelegate.removeListener(syncHistory);
  });

  return router;
});
