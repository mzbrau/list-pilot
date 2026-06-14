import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/repositories/learning_repository.dart';
import 'package:list_pilot/data/repositories/list_repository.dart';
import 'package:list_pilot/features/shopping_list/widgets/item_autocomplete_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Autocomplete shows suggestions when typing', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'dairy',
            name: 'Dairy',
            sortOrder: 0,
          ),
        );
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'milk',
            displayName: 'Milk',
            categoryId: 'dairy',
            createdAt: DateTime.now(),
          ),
        );

    final listId = await db.into(db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            name: 'Test',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          catalogRepositoryProvider.overrideWithValue(CatalogRepository(db)),
          learningRepositoryProvider
              .overrideWithValue(LearningRepository(db)),
          listRepositoryProvider.overrideWithValue(
            ListRepository(
              db,
              CatalogRepository(db),
              LearningRepository(db),
            ),
          ),
          appInitProvider.overrideWith((ref) async {}),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ItemAutocompleteField(listId: listId),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'mi');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsOneWidget);
  });
}
