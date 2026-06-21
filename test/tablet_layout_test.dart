import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/router/navigation_history.dart';
import 'package:list_pilot/router/tablet_layout.dart';

void main() {
  group('NavigationHistoryNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('starts at home with no previous entry', () {
      final state = container.read(navigationHistoryProvider);
      expect(state.stack, hasLength(1));
      expect(state.stack.first.location, '/');
      expect(state.previous, isNull);
    });

    test('push adds entries and exposes previous', () {
      final notifier = container.read(navigationHistoryProvider.notifier);
      notifier.onLocationChange('/list/1', null);

      final state = container.read(navigationHistoryProvider);
      expect(state.stack, hasLength(2));
      expect(state.previous?.location, '/');
    });

    test('pop removes the latest entry', () {
      final notifier = container.read(navigationHistoryProvider.notifier);
      notifier.onLocationChange('/list/1', null);
      notifier.onLocationChange('/', null);

      final state = container.read(navigationHistoryProvider);
      expect(state.stack, hasLength(1));
      expect(state.stack.first.location, '/');
      expect(state.previous, isNull);
    });

    test('go to root resets the stack', () {
      final notifier = container.read(navigationHistoryProvider.notifier);
      notifier.onLocationChange('/list/1', null);
      notifier.onLocationChange('/list/1/item/2', null);
      notifier.onLocationChange('/', null);

      final state = container.read(navigationHistoryProvider);
      expect(state.stack, hasLength(1));
      expect(state.stack.first.location, '/');
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
      required NavigationHistoryState history,
      required Widget child,
    }) {
      return ProviderScope(
        overrides: [
          navigationHistoryProvider.overrideWith(
            () => _FixedNavigationHistory(history),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData(size: size),
          child: MaterialApp(
            home: Scaffold(body: TabletSplitShell(child: child)),
          ),
        ),
      );
    }

    testWidgets('shows only the current pane on phone', (tester) async {
      await tester.pumpWidget(
        buildShell(
          size: const Size(390, 844),
          history: const NavigationHistoryState(
            stack: [
              NavigationEntry(location: '/'),
              NavigationEntry(location: '/stats'),
            ],
          ),
          child: const Center(child: Text('Current pane')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Current pane'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('shows split layout on tablet when previous route exists',
        (tester) async {
      await tester.pumpWidget(
        buildShell(
          size: const Size(800, 600),
          history: const NavigationHistoryState(
            stack: [
              NavigationEntry(location: '/'),
              NavigationEntry(location: '/stats'),
            ],
          ),
          child: const Center(child: Text('Current pane')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Current pane'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('shows single column on tablet at root', (tester) async {
      await tester.pumpWidget(
        buildShell(
          size: const Size(800, 600),
          history: const NavigationHistoryState(
            stack: [NavigationEntry(location: '/')],
          ),
          child: const Center(child: Text('Current pane')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Current pane'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsNothing);
    });
  });
}

class _FixedNavigationHistory extends NavigationHistoryNotifier {
  _FixedNavigationHistory(this.initial);

  final NavigationHistoryState initial;

  @override
  NavigationHistoryState build() => initial;
}
