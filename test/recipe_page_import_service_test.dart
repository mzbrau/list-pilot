import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/services/recipe_page_extractor.dart';
import 'package:list_pilot/data/services/recipe_page_import_service.dart';

void main() {
  test('importFromUrl extracts recipe from fetched HTML', () async {
    const html = '''
    <html><head><script type="application/ld+json">
    {"@type":"Recipe","name":"Fetched Soup","recipeIngredient":["stock"],"recipeInstructions":["heat"]}
    </script></head></html>
    ''';

    final service = RecipePageImportService(
      pageHtmlFetcher: (_) async => html,
    );

    final result = await service.importFromUrl('https://example-recipes.test/soup');
    expect(result.name, 'Fetched Soup');
    expect(result.ingredients, ['stock']);
    expect(result.steps, ['heat']);
    expect(result.recipeUrl, 'https://example-recipes.test/soup');
  });

  test('importFromUrl throws when extraction fails', () async {
    final service = RecipePageImportService(
      pageHtmlFetcher: (_) async => '<html><body>no recipe</body></html>',
    );

    expect(
      () => service.importFromUrl('https://example-recipes.test/empty'),
      throwsA(isA<RecipeImportException>()),
    );
  });

  test('importFromUrl uses metadata image fallback', () async {
    const html = '''
    <html><head>
    <meta property="og:image" content="https://example-recipes.test/hero.jpg" />
    <script type="application/ld+json">
    {"@type":"Recipe","name":"Img Soup","recipeIngredient":["a"],"recipeInstructions":["b"]}
    </script>
    </head></html>
    ''';

    final service = RecipePageImportService(
      pageHtmlFetcher: (_) async => html,
      extractor: RecipePageExtractor(),
    );

    final result = await service.importFromUrl('https://example-recipes.test/img');
    expect(result.imageUrl, 'https://example-recipes.test/hero.jpg');
  });
}
