import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/router/route_utils.dart';
import 'package:list_pilot/router/tablet_layout.dart';

void main() {
  group('normalizeLocation', () {
    test('normalizes root paths', () {
      expect(normalizeLocation('/'), '/');
      expect(normalizeLocation(''), '/');
    });

    test('adds leading slash and strips trailing slash', () {
      expect(normalizeLocation('list/1'), '/list/1');
      expect(normalizeLocation('/list/1/'), '/list/1');
    });

    test('strips query strings via path extraction', () {
      expect(normalizeLocation('/list/1?x=1'), '/list/1');
    });
  });

  group('isTabletTopLevelDetailRoute', () {
    test('returns false for root', () {
      expect(isTabletTopLevelDetailRoute('/'), isFalse);
    });

    test('returns true for top-level feature routes', () {
      expect(isTabletTopLevelDetailRoute('/stats'), isTrue);
      expect(isTabletTopLevelDetailRoute('/meals'), isTrue);
      expect(isTabletTopLevelDetailRoute('/meal-manager'), isTrue);
      expect(isTabletTopLevelDetailRoute('/todo/1'), isTrue);
      expect(isTabletTopLevelDetailRoute('/list/2'), isTrue);
    });

    test('returns false for nested routes', () {
      expect(isTabletTopLevelDetailRoute('/todo/1/task/2'), isFalse);
      expect(isTabletTopLevelDetailRoute('/list/1/item/3'), isFalse);
      expect(isTabletTopLevelDetailRoute('/meals/calendar'), isFalse);
      expect(isTabletTopLevelDetailRoute('/meals/5'), isFalse);
    });
  });

  group('isOverviewRouteSelected', () {
    test('matches exact routes for catalog items', () {
      expect(isOverviewRouteSelected('/meals', '/meals'), isTrue);
      expect(isOverviewRouteSelected('/meals', '/meals/calendar'), isFalse);
    });

    test('matches prefix for list routes', () {
      expect(isOverviewRouteSelected('/todo/1', '/todo/1'), isTrue);
      expect(isOverviewRouteSelected('/todo/1', '/todo/1/task/2'), isTrue);
      expect(isOverviewRouteSelected('/todo/1', '/todo/2'), isFalse);
    });
  });

  group('isTabletLayoutFromSizes', () {
    test('returns true when window shortest side is at least 600', () {
      expect(
        isTabletLayoutFromSizes(windowSize: const Size(800, 600)),
        isTrue,
      );
    });

    test('returns false for phone window sizes', () {
      expect(
        isTabletLayoutFromSizes(windowSize: const Size(390, 844)),
        isFalse,
      );
    });

    test('returns false for phone landscape without tablet display', () {
      expect(
        isTabletLayoutFromSizes(windowSize: const Size(915, 412)),
        isFalse,
      );
    });

    test('returns true for letterboxed tablet window with tablet display', () {
      expect(
        isTabletLayoutFromSizes(
          windowSize: const Size(520, 900),
          displayLogicalSize: const Size(800, 1280),
        ),
        isTrue,
      );
    });

    test('returns false for narrow multi-window even with tablet display', () {
      expect(
        isTabletLayoutFromSizes(
          windowSize: const Size(400, 900),
          displayLogicalSize: const Size(800, 1280),
        ),
        isFalse,
      );
    });
  });

  group('isTabletLayout', () {
    testWidgets('returns false for phone widths', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Builder(
            builder: (context) {
              expect(isTabletLayout(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns true for tablet widths', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Builder(
            builder: (context) {
              expect(isTabletLayout(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('TabletSplitShell', () {
    Widget buildShell({
      required Size size,
      required String location,
      required Widget child,
    }) {
      return ProviderScope(
        child: MediaQuery(
          data: MediaQueryData(size: size),
          child: MaterialApp(
            home: Scaffold(
              body: TabletSplitShell(location: location, child: child),
            ),
          ),
        ),
      );
    }

    testWidgets('shows only the current pane on phone', (tester) async {
      await tester.pumpWidget(
        buildShell(
          size: const Size(390, 844),
          location: '/stats',
          child: const Center(child: Text('Current pane')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Current pane'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsNothing);
      expect(find.text('Select a list to get started'), findsNothing);
    });

    testWidgets('shows sidebar and placeholder on tablet at root',
        (tester) async {
      await tester.pumpWidget(
        buildShell(
          size: const Size(800, 600),
          location: '/',
          child: const Center(child: Text('Root child')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('List Pilot'), findsOneWidget);
      expect(find.text('Select a list to get started'), findsOneWidget);
      expect(find.text('Root child'), findsNothing);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('shows sidebar and detail pane on tablet for detail routes',
        (tester) async {
      await tester.pumpWidget(
        buildShell(
          size: const Size(800, 600),
          location: '/stats',
          child: const Center(child: Text('Current pane')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('List Pilot'), findsOneWidget);
      expect(find.text('Current pane'), findsOneWidget);
      expect(find.text('Select a list to get started'), findsNothing);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });
  });
}
