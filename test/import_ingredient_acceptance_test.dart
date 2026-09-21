import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/services/import_ingredient_acceptance.dart';
import 'package:list_pilot/data/services/ingredient_catalog_matcher.dart';
import 'package:list_pilot/data/services/ingredient_parser_service.dart';
import 'package:list_pilot/data/services/paprika_import_service.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository catalogRepo;
  late MealRepository mealRepo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'fruit_veg',
            name: 'Fruit & Veg',
            sortOrder: 0,
          ),
        );
    await db.into(db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: 'spring onions',
            displayName: 'Spring onions',
            categoryId: 'fruit_veg',
            createdAt: DateTime.now(),
          ),
        );
    catalogRepo = CatalogRepository(db);
    mealRepo = MealRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('finalizeDrafts adds alias when linking unmatched draft', () async {
    final springOnions = (await catalogRepo.findByName('spring onions'))!;
    final draft = ImportIngredientDraft(
      parsed: const ParsedIngredientLine(
        itemName: 'green onion, sliced',
        originalLine: '1 green onion , sliced',
      ),
      confidence: IngredientMatchConfidence.matched,
      catalogItem: springOnions,
      displayName: springOnions.displayName,
    );

    await ImportIngredientAcceptance.finalizeDrafts(
      catalog: catalogRepo,
      drafts: [draft],
    );

    final aliases = await catalogRepo.getAliases(springOnions.id);
    expect(aliases.map((a) => a.alias), contains('green onion'));
  });

  test('finalizeDrafts does not alias when adding to catalog', () async {
    final draft = ImportIngredientDraft(
      parsed: const ParsedIngredientLine(
        itemName: 'mystery spice',
        originalLine: '1 tsp mystery spice',
      ),
      confidence: IngredientMatchConfidence.unmatched,
      displayName: 'Mystery spice',
      addToCatalog: true,
      categoryId: 'fruit_veg',
    );

    final result = await ImportIngredientAcceptance.finalizeDrafts(
      catalog: catalogRepo,
      drafts: [draft],
    );

    expect(result.single.catalogItem, isNotNull);
    final aliases =
        await catalogRepo.getAliases(result.single.catalogItem!.id);
    expect(aliases, isEmpty);
  });

  test('groupByMatchKey dedupes paprika unmatched rows', () {
    const parsed = ParsedIngredientLine(
      itemName: 'green onion, sliced',
      originalLine: '1 green onion , sliced',
    );
    final unmatched = [
      PaprikaUnmatchedIngredient(
        mealIngredientId: 1,
        mealId: 10,
        mealName: 'Quiche A',
        displayName: 'green onion, sliced',
        matchKey: 'green onion',
        parsed: parsed,
      ),
      PaprikaUnmatchedIngredient(
        mealIngredientId: 2,
        mealId: 11,
        mealName: 'Quiche B',
        displayName: 'green onion, sliced',
        matchKey: 'green onion',
        parsed: parsed,
      ),
    ];

    final groups = ImportIngredientAcceptance.groupByMatchKey(unmatched);
    expect(groups.keys, ['green onion']);
    expect(groups['green onion'], hasLength(2));

    final drafts =
        ImportIngredientAcceptance.draftsFromPaprikaGroups(groups);
    expect(drafts, hasLength(1));
    expect(drafts.single.matchKey, 'green onion');
  });

  test('applyPaprikaReviews links all ingredients in a match-key group',
      () async {
    final springOnions = (await catalogRepo.findByName('spring onions'))!;

    final mealA = await mealRepo.createMeal(
      displayName: 'Quiche A',
      ingredients: [
        const MealIngredientInput(displayName: 'green onion, sliced'),
      ],
    );
    final mealB = await mealRepo.createMeal(
      displayName: 'Quiche B',
      ingredients: [
        const MealIngredientInput(displayName: 'green onion, sliced'),
      ],
    );

    final ingredientsA = await mealRepo.getIngredientsForMeal(mealA.id);
    final ingredientsB = await mealRepo.getIngredientsForMeal(mealB.id);

    const parsed = ParsedIngredientLine(
      itemName: 'green onion, sliced',
      originalLine: '1 green onion , sliced',
    );
    final groups = ImportIngredientAcceptance.groupByMatchKey([
      PaprikaUnmatchedIngredient(
        mealIngredientId: ingredientsA.single.id,
        mealId: mealA.id,
        mealName: mealA.displayName,
        displayName: ingredientsA.single.displayName,
        matchKey: 'green onion',
        parsed: parsed,
      ),
      PaprikaUnmatchedIngredient(
        mealIngredientId: ingredientsB.single.id,
        mealId: mealB.id,
        mealName: mealB.displayName,
        displayName: ingredientsB.single.displayName,
        matchKey: 'green onion',
        parsed: parsed,
      ),
    ]);

    final reviewed = [
      ImportIngredientDraft(
        parsed: parsed,
        confidence: IngredientMatchConfidence.matched,
        catalogItem: springOnions,
        displayName: springOnions.displayName,
      ),
    ];

    await ImportIngredientAcceptance.finalizeDrafts(
      catalog: catalogRepo,
      drafts: reviewed,
    );
    await ImportIngredientAcceptance.applyPaprikaReviews(
      meals: mealRepo,
      groups: groups,
      reviewed: reviewed,
    );

    final updatedA = await mealRepo.getIngredientsForMeal(mealA.id);
    final updatedB = await mealRepo.getIngredientsForMeal(mealB.id);
    expect(updatedA.single.catalogItemId, springOnions.id);
    expect(updatedB.single.catalogItemId, springOnions.id);
    expect(updatedA.single.displayName, 'Spring onions');
    expect(
      (await catalogRepo.getAliases(springOnions.id)).map((a) => a.alias),
      contains('green onion'),
    );
  });

  test('matchAll leaves green onion unmatched and spring onions matched',
      () async {
    final matcher = IngredientCatalogMatcher(
      catalogRepo,
      const IngredientParserService(),
    );

    final drafts = await matcher.matchAll([
      '1 green onion, sliced',
      '2 spring onions',
    ]);
    expect(drafts[0].confidence, IngredientMatchConfidence.unmatched);
    expect(drafts[0].matchKey, 'green onion');
    expect(drafts[1].confidence, IngredientMatchConfidence.matched);

    final meal = await mealRepo.createMeal(
      displayName: 'Test Green Onion Recipe',
      ingredients: drafts.map((d) => d.toInput()).toList(),
    );
    final saved = await mealRepo.getIngredientsForMeal(meal.id);
    final unmatched = saved.where((i) => i.catalogItemId == null).toList();
    expect(unmatched, hasLength(1));
  });
}
