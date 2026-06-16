import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/services/meal_import_service.dart';

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
      httpGet: (url, {headers}) async {
        expect(url.toString(), 'https://example.com/recipe');
        return http.Response(pageHtml, 200);
      },
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
}
