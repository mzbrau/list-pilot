import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/services/recipe_page_extractor.dart';

void main() {
  final extractor = RecipePageExtractor();
  final fixtureDir = Directory('test/fixtures/recipe_pages');
  final baseUri = Uri.parse('https://example-recipes.test');

  final fixtures = fixtureDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.html'))
      .where((f) => !f.path.endsWith('no_recipe.html'))
      .map((f) => f.uri.pathSegments.last.replaceAll('.html', ''))
      .toList();

  for (final id in fixtures) {
    test('fixture $id matches expected extraction', () {
      final html = File('${fixtureDir.path}/$id.html').readAsStringSync();
      final expectedFile = File('${fixtureDir.path}/$id.expected.json');
      expect(expectedFile.existsSync(), isTrue, reason: 'missing expected JSON for $id');

      final expected = jsonDecode(expectedFile.readAsStringSync()) as Map<String, dynamic>;
      final result = extractor.extract(html, baseUri.resolve('/$id/'));

      expect(result, isNotNull, reason: 'extraction returned null for $id');
      expect(result!.name, expected['name']);

      expect(
        result.ingredients,
        expected['ingredients'],
        reason: 'ingredients mismatch for $id',
      );
      expect(
        result.steps,
        expected['steps'],
        reason: 'steps mismatch for $id',
      );

      if (expected.containsKey('notes')) {
        expect(result.notes, expected['notes']);
      }

      final expectedTags = (expected['tags'] as List<dynamic>?)?.cast<String>() ?? [];
      expect(result.tags, expectedTags, reason: 'tags mismatch for $id');

      if (expected.containsKey('imageUrl')) {
        expect(result.imageUrl, expected['imageUrl']);
      }
      if (expected.containsKey('recipeUrl')) {
        expect(result.recipeUrl, expected['recipeUrl']);
      }
    });
  }

  test('no_recipe fixture returns null', () {
    final html = File('${fixtureDir.path}/no_recipe.html').readAsStringSync();
    expect(extractor.extract(html, baseUri), isNull);
  });
}
