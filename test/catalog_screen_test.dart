import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/features/catalog/catalog_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('catalog screen shows source chips for items', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async => db.close());

    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'fruit_veg',
            name: 'Fruit & Veg',
            sortOrder: 0,
          ),
        );
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'apples',
            displayName: 'Apples',
            categoryId: 'fruit_veg',
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'my item',
            displayName: 'My Item',
            categoryId: 'fruit_veg',
            isUserAdded: const Value(true),
            createdAt: DateTime.now(),
          ),
        );

    final catalogRepo = CatalogRepository(db);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        catalogRepositoryProvider.overrideWithValue(catalogRepo),
        appInitProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const CatalogScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('My Item'), findsOneWidget);
    expect(find.text('Built-in'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });
}
