import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/catalog_repository.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/services/ingredient_catalog_matcher.dart';
import 'package:list_pilot/data/services/ingredient_parser_service.dart';
import 'package:list_pilot/data/services/meal_photo_service.dart';
import 'package:list_pilot/data/services/paprika_import_service.dart';
import 'package:list_pilot/data/services/paprika_recipe_parser.dart';

void main() {
  final referenceRecipes = 'Reference/My Recipes/Recipes';
  final parser = PaprikaRecipeParser();

  group('parsePaprikaPortions', () {
    test('parses common yield formats', () {
      expect(PaprikaRecipeParser.parsePaprikaPortions('6'), 6);
      expect(PaprikaRecipeParser.parsePaprikaPortions('Servings: 6'), 6);
      expect(PaprikaRecipeParser.parsePaprikaPortions('Servings 6'), 6);
      expect(PaprikaRecipeParser.parsePaprikaPortions('Serves 4'), 4);
      expect(PaprikaRecipeParser.parsePaprikaPortions('4 to 6 servings'), 4);
      expect(PaprikaRecipeParser.parsePaprikaPortions('Yield: 12'), 12);
    });

    test('defaults invalid yields to 4', () {
      expect(PaprikaRecipeParser.parsePaprikaPortions(null), 4);
      expect(PaprikaRecipeParser.parsePaprikaPortions('–'), 4);
      expect(PaprikaRecipeParser.parsePaprikaPortions(''), 4);
    });
  });

  group('filterScalingArtifacts', () {
    test('removes Paprika scaling UI lines', () {
      final filtered = PaprikaRecipeParser.filterScalingArtifacts([
        '1/2 x 1x 2x 3x',
        '2 tablespoons olive oil',
      ]);
      expect(filtered, ['2 tablespoons olive oil']);
    });
  });

  group('PaprikaRecipeParser', () {
    test('parses Bruschetta.html', () async {
      final file = File('$referenceRecipes/Bruschetta.html');
      final recipe = await parser.parse(htmlFile: file);

      expect(recipe.name, 'Bruschetta');
      expect(recipe.tags, ['Vegetarian']);
      expect(recipe.ingredients, isNotEmpty);
      expect(recipe.steps, hasLength(3));
      expect(recipe.prepTimeMinutes, 40);
      expect(
        recipe.recipeUrl,
        'https://www.taste.com.au/recipes/bruschetta-3/00021c59-b720-4b7c-9cba-a25227b04750',
      );
      expect(recipe.localImagePath, isNotNull);
      expect(File(recipe.localImagePath!).existsSync(), isTrue);
    });

    test('parses Roast Turkey Breast notes from comment field', () async {
      final file = File(
        '$referenceRecipes/Roast Turkey Breast with Saucy Cranberry Sauce.html',
      );
      final recipe = await parser.parse(htmlFile: file);

      expect(recipe.notes, isNotNull);
      expect(recipe.notes, contains('Notes'));
      expect(recipe.notes, contains('Crockpot Alternative'));
    });

    test('parses Classic One-Pot Beef Stew nutrition and portions', () async {
      final file = File('$referenceRecipes/Classic One-Pot Beef Stew.html');
      final recipe = await parser.parse(htmlFile: file);

      expect(recipe.portions, 6);
      expect(recipe.tags, containsAll(['Beef', 'Stew']));
      expect(recipe.notes, isNotNull);
      expect(recipe.notes, contains('Nutrition'));
      expect(recipe.notes, contains('protein'));
    });
  });

  group('PaprikaImportService', () {
    late AppDatabase db;
    late MealRepository mealRepo;
    late PaprikaImportService service;
    late Directory tempDir;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp.createTemp('paprika_import_test');
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
        return tempDir.path;
      });

      db = AppDatabase.forTesting(NativeDatabase.memory());
      mealRepo = MealRepository(db);
      final catalogRepo = CatalogRepository(db);
      final matcher = IngredientCatalogMatcher(
        catalogRepo,
        const IngredientParserService(),
      );
      service = PaprikaImportService(
        mealRepository: mealRepo,
        matcher: matcher,
        photoService: MealPhotoService(mealRepo),
      );
    });

    tearDown(() async {
      await db.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('skips index.html when scanning folder', () async {
      final result = await service.importFolder('Reference/My Recipes');
      expect(result.imported, greaterThan(100));
      expect(result.failed, 0);
    });

    test('skips duplicate recipes by name', () async {
      await mealRepo.createMeal(displayName: 'Bruschetta');

      final result = await service.importFolder(
        'Reference/My Recipes/Recipes',
      );

      expect(result.skipped, greaterThan(0));
      expect(result.errors.where((e) => e.fileName == 'Bruschetta.html'), isEmpty);
    });
  });
}
