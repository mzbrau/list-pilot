import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/services/recipe_json_ld.dart';
import 'package:list_pilot/data/services/recipe_page_extractor.dart';

void main() {
  group('findRecipeNodes', () {
    test('finds Recipe in @graph', () {
      final nodes = findRecipeNodes({
        '@graph': [
          {'@type': 'WebSite', 'name': 'Site'},
          {'@type': 'Recipe', 'name': 'Soup'},
        ],
      });
      expect(nodes, hasLength(1));
      expect(nodes.first['name'], 'Soup');
    });

    test('finds Recipe when @type is a list', () {
      final nodes = findRecipeNodes({
        '@type': ['Recipe', 'HowTo'],
        'name': 'Pasta',
      });
      expect(nodes, hasLength(1));
    });
  });

  group('normalizeIngredientLine', () {
    test('strips bullet prefix', () {
      expect(normalizeIngredientLine('• 2 cups flour'), '2 cups flour');
    });
  });

  group('normalizeStepLine', () {
    test('strips numbered prefix', () {
      expect(normalizeStepLine('1. Boil water'), 'Boil water');
      expect(normalizeStepLine('2) Simmer'), 'Simmer');
    });
  });

  group('ingredientsFromJsonLd', () {
    test('parses string list and object names', () {
      expect(
        ingredientsFromJsonLd(['1 cup milk', {'name': '2 eggs'}]),
        ['1 cup milk', '2 eggs'],
      );
    });
  });

  group('instructionsFromJsonLd', () {
    test('parses HowToSection steps', () {
      final steps = instructionsFromJsonLd({
        '@type': 'HowToSection',
        'itemListElement': [
          {'@type': 'HowToStep', 'text': 'Step one'},
          {'@type': 'HowToStep', 'text': 'Step two'},
        ],
      });
      expect(steps, ['Step one', 'Step two']);
    });

    test('splits multiline string instructions', () {
      final steps = instructionsFromJsonLd('First line\n\nSecond line');
      expect(steps, ['First line', 'Second line']);
    });
  });

  group('tagsFromJsonLd', () {
    test('collects category, cuisine, and keywords', () {
      final tags = tagsFromJsonLd({
        'recipeCategory': 'Dinner',
        'recipeCuisine': 'Italian',
        'keywords': 'pasta, easy, weeknight',
      });
      expect(tags, containsAll(['Dinner', 'Italian', 'pasta', 'easy', 'weeknight']));
    });
  });

  group('RecipePageExtractor unit strategies', () {
    final extractor = RecipePageExtractor();
    final pageUri = Uri.parse('https://example-recipes.test/recipe');

    test('extracts JSON-LD recipe', () {
      const html = '''
      <html><head><script type="application/ld+json">
      {"@type":"Recipe","name":"Test Soup","recipeIngredient":["water"],"recipeInstructions":["boil"]}
      </script></head></html>
      ''';
      final result = extractor.extract(html, pageUri);
      expect(result?.name, 'Test Soup');
      expect(result?.ingredients, ['water']);
      expect(result?.steps, ['boil']);
    });

    test('extracts microdata recipe', () {
      const html = '''
      <div itemscope itemtype="https://schema.org/Recipe">
        <span itemprop="name">Micro Soup</span>
        <span itemprop="recipeIngredient">salt</span>
        <span itemprop="recipeInstructions">stir</span>
      </div>
      ''';
      final result = extractor.extract(html, pageUri);
      expect(result?.name, 'Micro Soup');
    });

    test('returns null for pages without recipe data', () {
      const html = '<html><body><h1>Hello</h1></body></html>';
      expect(extractor.extract(html, pageUri), isNull);
    });
  });
}
