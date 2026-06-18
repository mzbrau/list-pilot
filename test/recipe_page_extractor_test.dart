import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/services/recipe_page_extractor.dart';

void main() {
  final extractor = RecipePageExtractor();

  test('extracts h-recipe microformat', () {
    const html = '''
    <div class="h-recipe">
      <h1 class="p-name">Gratin</h1>
      <li class="p-ingredient">cheese</li>
      <li class="e-instruction">bake</li>
    </div>
    ''';
    final result = extractor.extract(
      html,
      Uri.parse('https://example-recipes.test/gratin'),
    );
    expect(result?.name, 'Gratin');
    expect(result?.ingredients, ['cheese']);
    expect(result?.steps, ['bake']);
  });

  test('extracts WP Recipe Maker markup', () {
    const html = '''
    <div class="wprm-recipe">
      <span class="wprm-recipe-name">WPRM Soup</span>
      <li class="wprm-recipe-ingredient">broth</li>
      <div class="wprm-recipe-instruction-text">simmer</div>
    </div>
    ''';
    final result = extractor.extract(
      html,
      Uri.parse('https://example-recipes.test/soup'),
    );
    expect(result?.name, 'WPRM Soup');
    expect(result?.ingredients, ['broth']);
    expect(result?.steps, ['simmer']);
  });

  test('extracts Tasty Recipes markup', () {
    const html = '''
    <div class="tasty-recipes">
      <h2 class="tasty-recipes-title">Tasty Chicken</h2>
      <ul class="tasty-recipes-ingredients"><li>chicken</li></ul>
      <ol class="tasty-recipes-instructions"><li>roast</li></ol>
    </div>
    ''';
    final result = extractor.extract(
      html,
      Uri.parse('https://example-recipes.test/chicken'),
    );
    expect(result?.name, 'Tasty Chicken');
    expect(result?.ingredients, ['chicken']);
    expect(result?.steps, ['roast']);
  });

  test('extracts Mediavine Create markup', () {
    const html = '''
    <div class="mv-create-card">
      <h2 class="mv-create-title">MV Chicken</h2>
      <ul class="mv-create-ingredients"><li>thighs</li></ul>
      <ol class="mv-create-instructions"><li>roast</li></ol>
    </div>
    ''';
    final result = extractor.extract(
      html,
      Uri.parse('https://example-recipes.test/mv'),
    );
    expect(result?.name, 'MV Chicken');
    expect(result?.ingredients, ['thighs']);
    expect(result?.steps, ['roast']);
  });

  test('resolves relative image URLs from JSON-LD', () {
    const html = '''
    <script type="application/ld+json">
    {"@type":"Recipe","name":"Img Test","image":"/img.jpg","recipeIngredient":["a"],"recipeInstructions":["b"]}
    </script>
    ''';
    final result = extractor.extract(
      html,
      Uri.parse('https://example-recipes.test/recipe'),
    );
    expect(result?.imageUrl, 'https://example-recipes.test/img.jpg');
  });
}
