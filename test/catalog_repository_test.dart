import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/seed/database_seeder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CatalogRepository catalogRepo;
  late DatabaseSeeder seeder;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    catalogRepo = CatalogRepository(db);
    seeder = DatabaseSeeder(db);

    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'fruit_veg',
            name: 'Fruit & Veg',
            sortOrder: 0,
          ),
        );
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'capsicum',
            displayName: 'Capsicum',
            categoryId: 'fruit_veg',
            createdAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('addAlias stores normalized alias and resolves via findByNameOrAlias',
      () async {
    final item = (await catalogRepo.getAllCatalogItems()).single;

    await catalogRepo.addAlias(
      catalogItemId: item.id,
      alias: 'Bell Peppers',
    );

    final aliases = await catalogRepo.getAliases(item.id);
    expect(aliases, hasLength(1));
    expect(aliases.single.alias, 'bell peppers');

    final match = await catalogRepo.findByNameOrAlias('bell peppers');
    expect(match?.displayName, 'Capsicum');
  });

  test('addAlias rejects duplicate catalog item names', () async {
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'onion',
            displayName: 'Onion',
            categoryId: 'fruit_veg',
            createdAt: DateTime.now(),
          ),
        );
    final item = (await catalogRepo.getAllCatalogItems())
        .firstWhere((entry) => entry.displayName == 'Capsicum');

    expect(
      () => catalogRepo.addAlias(catalogItemId: item.id, alias: 'Onion'),
      throwsA(isA<CatalogAliasConflictException>()),
    );
  });

  test('deleteCatalogItem on built-in item creates exclusion', () async {
    final item = (await catalogRepo.getAllCatalogItems()).single;

    await catalogRepo.deleteCatalogItem(item.id);

    expect(await catalogRepo.getById(item.id), isNull);
    expect(await db.isCatalogNameExcluded('capsicum'), isTrue);
  });

  test('mergeMissingSeedItems skips excluded built-in names', () async {
    final item = (await catalogRepo.getAllCatalogItems()).single;
    await catalogRepo.deleteCatalogItem(item.id);
    expect(await db.findCatalogByName('Capsicum'), isNull);

    await seeder.mergeMissingSeedItems();

    expect(await db.findCatalogByName('Capsicum'), isNull);
  });

  test('deleteCatalogItem clears references before deleting', () async {
    final item = (await catalogRepo.getAllCatalogItems()).single;
    final listId = await db.into(db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            name: 'Weekly',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    await db.into(db.listItems).insert(
          ListItemsCompanion.insert(
            listId: listId,
            catalogItemId: Value(item.id),
            displayName: item.displayName,
            categoryId: item.categoryId,
            addedAt: DateTime.now(),
          ),
        );

    await catalogRepo.deleteCatalogItem(item.id);

    final listItems = await db.watchListItems(listId).first;
    expect(listItems.single.catalogItemId, isNull);
  });

  group('search', () {
    Future<void> insertItem({
      required String name,
      required String displayName,
    }) async {
      await db.into(db.catalogItems).insert(
            CatalogItemsCompanion.insert(
              name: name,
              displayName: displayName,
              categoryId: 'fruit_veg',
              createdAt: DateTime.now(),
            ),
          );
    }

    test('finds substring matches in name', () async {
      await insertItem(name: 'beef mince', displayName: 'Beef mince');

      final results = await catalogRepo.search('min');

      expect(results.map((item) => item.displayName), contains('Beef mince'));
    });

    test('finds prefix matches', () async {
      await insertItem(name: 'milk', displayName: 'Milk');

      final results = await catalogRepo.search('mi');

      expect(results, hasLength(1));
      expect(results.first.displayName, 'Milk');
    });

    test('ranks prefix name matches before later substring matches', () async {
      await insertItem(name: 'chicken breast', displayName: 'Chicken breast');
      await insertItem(name: 'apple chicken', displayName: 'Apple chicken');

      final results = await catalogRepo.search('chicken');

      expect(results, hasLength(2));
      expect(results.first.displayName, 'Chicken breast');
      expect(results.last.displayName, 'Apple chicken');
    });

    test('finds substring matches via alias', () async {
      final item = (await catalogRepo.getAllCatalogItems()).single;

      await catalogRepo.addAlias(
        catalogItemId: item.id,
        alias: 'ground mince',
      );

      final results = await catalogRepo.search('min');

      expect(results.map((entry) => entry.displayName), contains('Capsicum'));
    });
  });
}
