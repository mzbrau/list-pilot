import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/features/meal_manager/widgets/create_meal_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSheet(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const _SheetLauncher(),
        ),
        GoRoute(
          path: '/meal-manager/import',
          builder: (context, state) => const Scaffold(body: Text('AI Import')),
        ),
        GoRoute(
          path: '/meal-manager/import/extract',
          builder: (context, state) => const Scaffold(body: Text('Extract Import')),
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        mealRepositoryProvider.overrideWithValue(MealRepository(db)),
        appInitProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows manual and code import without AI config', (tester) async {
    await pumpSheet(tester);

    expect(find.text('Create manually'), findsOneWidget);
    expect(find.text('Import from webpage'), findsOneWidget);
    expect(find.text('Import with AI'), findsNothing);
  });

  testWidgets('shows all three options when AI configured', (tester) async {
    await pumpSheet(tester, prefs: {
      'ai_api_uri': 'https://api.example.com/v1',
      'ai_api_key': 'key',
      'ai_model_name': 'model',
    });

    expect(find.text('Create manually'), findsOneWidget);
    expect(find.text('Import from webpage'), findsOneWidget);
    expect(find.text('Import with AI'), findsOneWidget);
  });

  testWidgets('code import navigates to extract route', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Import from webpage'));
    await tester.pumpAndSettle();

    expect(find.text('Extract Import'), findsOneWidget);
  });

  testWidgets('AI import navigates to AI route when configured', (tester) async {
    await pumpSheet(tester, prefs: {
      'ai_api_uri': 'https://api.example.com/v1',
      'ai_api_key': 'key',
      'ai_model_name': 'model',
    });

    await tester.tap(find.text('Import with AI'));
    await tester.pumpAndSettle();

    expect(find.text('AI Import'), findsOneWidget);
  });
}

class _SheetLauncher extends ConsumerWidget {
  const _SheetLauncher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => CreateMealSheet.show(context, ref),
          child: const Text('Open sheet'),
        ),
      ),
    );
  }
}
