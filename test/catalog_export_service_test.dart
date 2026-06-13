import 'package:flutter_test/flutter_test.dart';

import 'package:shop_flow/data/database/app_database.dart';
import 'package:shop_flow/data/services/catalog_export_service.dart';

void main() {
  group('buildCatalogExportData', () {
    const seedCategories = {
      'milk': 'dairy',
      'apples': 'fruit_veg',
    };

    CatalogItem catalogItem({
      required int id,
      required String name,
      required String displayName,
      required String categoryId,
      bool isUserAdded = false,
    }) {
      return CatalogItem(
        id: id,
        name: name,
        displayName: displayName,
        categoryId: categoryId,
        isUserAdded: isUserAdded,
        createdAt: DateTime(2026, 1, 1),
      );
    }

    test('includes user-added items in customItems', () {
      final userAdded = [
        catalogItem(
          id: 1,
          name: 'my snack',
          displayName: 'My Snack',
          categoryId: 'snacks',
          isUserAdded: true,
        ),
      ];

      final result = buildCatalogExportData(
        userAdded: userAdded,
        allItems: userAdded,
        seedCategoriesByName: seedCategories,
      );

      expect(result.customItems, [
        {'displayName': 'My Snack', 'categoryId': 'snacks'},
      ]);
      expect(result.recategorizedItems, isEmpty);
    });

    test('includes built-in items with changed category in recategorizedItems',
        () {
      final milk = catalogItem(
        id: 2,
        name: 'milk',
        displayName: 'Milk',
        categoryId: 'drinks',
      );

      final result = buildCatalogExportData(
        userAdded: const [],
        allItems: [milk],
        seedCategoriesByName: seedCategories,
      );

      expect(result.customItems, isEmpty);
      expect(result.recategorizedItems, [
        {
          'displayName': 'Milk',
          'categoryId': 'drinks',
          'originalCategoryId': 'dairy',
        },
      ]);
    });

    test('excludes built-in items with unchanged category', () {
      final apples = catalogItem(
        id: 3,
        name: 'apples',
        displayName: 'Apples',
        categoryId: 'fruit_veg',
      );

      final result = buildCatalogExportData(
        userAdded: const [],
        allItems: [apples],
        seedCategoriesByName: seedCategories,
      );

      expect(result.customItems, isEmpty);
      expect(result.recategorizedItems, isEmpty);
    });

    test('does not duplicate user-added items in recategorizedItems', () {
      final custom = catalogItem(
        id: 4,
        name: 'special tea',
        displayName: 'Special Tea',
        categoryId: 'drinks',
        isUserAdded: true,
      );

      final result = buildCatalogExportData(
        userAdded: [custom],
        allItems: [custom],
        seedCategoriesByName: seedCategories,
      );

      expect(result.customItems, hasLength(1));
      expect(result.recategorizedItems, isEmpty);
    });
  });
}
