import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:list_pilot/router/navigation_helpers.dart';

void main() {
  testWidgets('popOrGoHome pops when the route stack can pop', (tester) async {
    late GoRouter router;
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => context.push('/feature'),
                child: const Text('Open feature'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/feature',
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              leading: overviewBackButton(context),
            ),
            body: const Center(child: Text('Feature')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open feature'));
    await tester.pumpAndSettle();
    expect(find.text('Feature'), findsOneWidget);

    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();

    expect(find.text('Open feature'), findsOneWidget);
    expect(find.text('Feature'), findsNothing);
  });

  testWidgets('popOrGoHome goes home when the route stack cannot pop',
      (tester) async {
    late GoRouter router;
    router = GoRouter(
      initialLocation: '/feature',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
        GoRoute(
          path: '/feature',
          builder: (context, state) => popOrGoHomeScope(
            child: Scaffold(
              appBar: AppBar(
                leading: overviewBackButton(context),
              ),
              body: const Center(child: Text('Feature')),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Feature'), findsOneWidget);
    expect(find.byType(BackButtonIcon), findsOneWidget);

    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Feature'), findsNothing);
  });

  testWidgets('popOrGoHomeScope routes system back to home when stack cannot pop',
      (tester) async {
    late GoRouter router;
    router = GoRouter(
      initialLocation: '/feature',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
        GoRoute(
          path: '/feature',
          builder: (context, state) => popOrGoHomeScope(
            child: const Scaffold(
              body: Center(child: Text('Feature')),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Feature'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    expect(handled, isTrue);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Feature'), findsNothing);
  });
}
