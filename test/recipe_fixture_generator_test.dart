import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/services/recipe_page_extractor.dart';

/// Generates `.expected.json` files from HTML fixtures. Run manually when updating fixtures:
///   flutter test test/recipe_fixture_generator_test.dart
void main() {
  test('generate expected JSON for recipe fixtures', () {
    final dir = Directory('test/fixtures/recipe_pages');
    final extractor = RecipePageExtractor();
    final baseUri = Uri.parse('https://example-recipes.test');

    for (final entity in dir.listSync()) {
      if (entity is! File || !entity.path.endsWith('.html')) continue;
      final id = entity.uri.pathSegments.last.replaceAll('.html', '');
      if (id == 'no_recipe') continue;

      final html = entity.readAsStringSync();
      final result = extractor.extract(html, baseUri.resolve('/$id/'));
      expect(result, isNotNull, reason: 'extraction failed for $id');

      final expected = <String, dynamic>{
        'name': result!.name,
        'ingredients': result.ingredients,
        'steps': result.steps,
        if (result.notes != null) 'notes': result.notes,
        'tags': result.tags,
        if (result.imageUrl != null) 'imageUrl': result.imageUrl,
        if (result.recipeUrl != null) 'recipeUrl': result.recipeUrl,
      };

      File('${dir.path}/$id.expected.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(expected),
      );
    }
  });
}
