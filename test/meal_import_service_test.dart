import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/services/meal_import_service.dart';
import 'package:list_pilot/data/services/recipe_page_fetcher.dart';
import 'package:list_pilot/data/services/recipe_page_metadata.dart';

void main() {
  test('stripHtmlForImport removes scripts and tags', () {
    const html = '''
    <html><head><style>body{}</style><script>alert(1)</script></head>
    <body><h1>Title</h1><p>Recipe text</p></body></html>
    ''';
    final result = stripHtmlForImport(html);
    expect(result, contains('Title'));
    expect(result, contains('Recipe text'));
    expect(result, isNot(contains('alert')));
    expect(result, isNot(contains('<h1>')));
  });

  test('resolveUrl resolves relative paths', () {
    final base = Uri.parse('https://example.com/recipes/pasta');
    expect(resolveUrl('/images/hero.jpg', base), 'https://example.com/images/hero.jpg');
    expect(resolveUrl('//cdn.example.com/img.jpg', base), 'https://cdn.example.com/img.jpg');
    expect(resolveUrl('https://cdn.example.com/img.jpg', base), 'https://cdn.example.com/img.jpg');
  });

  test('extractRecipeImageUrl parses og:image', () {
    const html = '''
    <html><head>
    <meta property="og:image" content="https://example.com/hero.jpg" />
    </head><body></body></html>
    ''';
    final uri = Uri.parse('https://example.com/recipe');
    expect(extractRecipeImageUrl(html, uri), 'https://example.com/hero.jpg');
  });

  test('extractRecipeImageUrl parses JSON-LD Recipe image array', () {
    final html = '''
    <html><head>
    <script type="application/ld+json">
    ${jsonEncode({
      '@type': 'Recipe',
      'name': 'Soup',
      'image': [
        'https://example.com/hero-large.jpg',
        'https://example.com/hero-small.jpg',
      ],
    })}
    </script>
    </head><body></body></html>
    ''';
    final uri = Uri.parse('https://example.com/recipe');
    expect(extractRecipeImageUrl(html, uri), 'https://example.com/hero-large.jpg');
  });

  test('extractRecipeImageUrl resolves relative JSON-LD image URLs', () {
    final html = '''
    <html><head>
    <script type="application/ld+json">
    ${jsonEncode({
      '@type': 'Recipe',
      'image': '/images/pasta.jpg',
    })}
    </script>
    </head></html>
    ''';
    final uri = Uri.parse('https://example.com/recipes/pasta');
    expect(extractRecipeImageUrl(html, uri), 'https://example.com/images/pasta.jpg');
  });

  test('MealImportResult.fromJson parses fields', () {
    final result = MealImportResult.fromJson({
      'name': 'Pasta',
      'ingredients': ['Noodles', 'Sauce'],
      'steps': ['Boil', 'Serve'],
      'notes': 'Easy',
      'tags': ['Dinner'],
      'imageUrl': 'https://example.com/img.jpg',
      'recipeUrl': 'https://example.com/pasta',
    });

    expect(result.name, 'Pasta');
    expect(result.ingredients, hasLength(2));
    expect(result.steps, hasLength(2));
    expect(result.tags, ['Dinner']);
    expect(result.imageUrl, 'https://example.com/img.jpg');
  });

  test('parseImportResponseBody extracts recipe JSON', () {
    final aiBody = jsonEncode({
      'choices': [
        {
          'message': {
            'content': jsonEncode({
              'name': 'Soup',
              'ingredients': ['Water'],
              'steps': ['Boil'],
              'tags': [],
            }),
          },
        },
      ],
    });

    final result = parseImportResponseBody(aiBody);
    expect(result.name, 'Soup');
    expect(result.ingredients, ['Water']);
  });

  test('importFromUrl fetches page and calls AI', () async {
    const pageHtml = '<html><body><h1>Test Recipe</h1></body></html>';
    final recipeJson = jsonEncode({
      'name': 'Test Recipe',
      'ingredients': ['A'],
      'steps': ['Do it'],
      'tags': ['Lunch'],
      'imageUrl': null,
      'recipeUrl': 'https://example.com/recipe',
    });

    final service = MealImportService(
      aiConfig: const AiConfig(
        apiUri: 'https://api.example.com/v1',
        apiKey: 'test-key',
        modelName: 'test-model',
      ),
      pageHtmlFetcher: (url) async => pageHtml,
      httpPost: (url, {headers, body}) async {
        expect(url.toString(), 'https://api.example.com/v1/chat/completions');
        expect(headers?['Authorization'], 'Bearer test-key');
        return http.Response(
          jsonEncode({
            'choices': [
              {'message': {'content': recipeJson}},
            ],
          }),
          200,
        );
      },
    );

    final result = await service.importFromUrl('https://example.com/recipe');
    expect(result.name, 'Test Recipe');
    expect(result.ingredients, ['A']);
    expect(result.recipeUrl, 'https://example.com/recipe');
  });

  test('importFromUrl uses metadata image when AI returns null imageUrl', () async {
    const pageHtml = '''
    <html><head>
    <meta property="og:image" content="https://example.com/hero.jpg" />
    </head><body><h1>Pasta</h1></body></html>
    ''';
    final recipeJson = jsonEncode({
      'name': 'Pasta',
      'ingredients': ['Noodles'],
      'steps': ['Boil'],
      'tags': [],
      'imageUrl': null,
    });

    final service = MealImportService(
      aiConfig: const AiConfig(
        apiUri: 'https://api.example.com/v1',
        apiKey: 'test-key',
        modelName: 'test-model',
      ),
      pageHtmlFetcher: (url) async => pageHtml,
      httpPost: (url, {headers, body}) async {
        return http.Response(
          jsonEncode({
            'choices': [
              {'message': {'content': recipeJson}},
            ],
          }),
          200,
        );
      },
    );

    final result = await service.importFromUrl('https://example.com/recipe');
    expect(result.imageUrl, 'https://example.com/hero.jpg');
  });

  test('RecipePageFetcher falls back to WebView when HTTP is blocked', () async {
    var httpCalls = 0;
    final fetcher = RecipePageFetcher(
      httpGet: (url, {headers}) async {
        httpCalls++;
        expect(headers?['User-Agent'], contains('Chrome'));
        return http.Response('blocked', 403);
      },
      webViewFetcher: (url) async => '<html><body>fallback</body></html>',
    );

    final html = await fetcher.fetchHtml(Uri.parse('https://example.com/recipe'));
    expect(httpCalls, 1);
    expect(html, contains('fallback'));
  });

  test('buildChatCompletionsBody includes known hero image hint', () {
    final body = buildChatCompletionsBody(
      model: 'test',
      pageUrl: 'https://example.com',
      pageContent: 'content',
      knownImageUrl: 'https://example.com/hero.jpg',
    );
    final userMessage = (body['messages'] as List).last as Map<String, dynamic>;
    expect(userMessage['content'], contains('Known hero image: https://example.com/hero.jpg'));
  });
}
