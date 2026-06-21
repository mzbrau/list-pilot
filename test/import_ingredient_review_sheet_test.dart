import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/core/widgets/keyboard_inset_padding.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/services/ingredient_catalog_matcher.dart';
import 'package:list_pilot/data/services/ingredient_parser_service.dart';
import 'package:list_pilot/features/meal_manager/widgets/import_ingredient_review_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ImportIngredientReviewSheet pads content for keyboard insets',
      (tester) async {
    const keyboardHeight = 300.0;
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final catalogRepo = CatalogRepository(db);
    final drafts = [
      ImportIngredientDraft(
        parsed: const ParsedIngredientLine(
          itemName: 'Mystery Spice',
          originalLine: '1 tsp mystery spice',
        ),
        confidence: IngredientMatchConfidence.unmatched,
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        appInitProvider.overrideWith((ref) async {}),
        databaseProvider.overrideWithValue(db),
        catalogRepositoryProvider.overrideWithValue(catalogRepo),
        ingredientCatalogMatcherProvider.overrideWithValue(
          IngredientCatalogMatcher(
            catalogRepo,
            const IngredientParserService(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MediaQuery(
          data: const MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: keyboardHeight),
          ),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return FilledButton(
                    onPressed: () {
                      ImportIngredientReviewSheet.show(
                        context,
                        drafts: drafts,
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Review ingredients'), findsOneWidget);

    final sheetContext = tester.element(find.text('Review ingredients'));
    expect(
      keyboardAwareSheetPadding(sheetContext),
      const EdgeInsets.fromLTRB(16, 8, 16, 316),
    );

    final paddingFinder = find.descendant(
      of: find.byType(DraggableScrollableSheet),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Padding &&
            widget.padding == keyboardAwareSheetPadding(sheetContext),
      ),
    );
    expect(paddingFinder, findsOneWidget);
  });
}
