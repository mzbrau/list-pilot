import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/services/meal_import_service.dart';
import 'package:list_pilot/data/services/menu_import_service.dart';

void main() {
  test('buildMenuImportSystemPrompt preserves original language when selected', () {
    final prompt = buildMenuImportSystemPrompt(language: defaultMenuImportLanguage);
    expect(prompt, contains('Do not translate'));
    expect(prompt, isNot(contains('when translating')));
  });

  test('buildMenuImportSystemPrompt requests translation for other languages', () {
    final prompt = buildMenuImportSystemPrompt(
      language: const RecipeImportLanguage(code: 'sv', label: 'Swedish'),
    );
    expect(prompt, contains('Swedish'));
    expect(prompt, contains('when translating'));
  });

  test('buildMenuChatCompletionsBody omits translation for original language', () {
    final body = buildMenuChatCompletionsBody(
      model: 'test-model',
      pageUrl: 'https://example.com/menu',
      pageContent: 'Menu content',
      language: defaultMenuImportLanguage,
    );
    final messages = body['messages'] as List<dynamic>;
    final systemMessage = messages.first as Map<String, dynamic>;
    final userMessage = messages.last as Map<String, dynamic>;
    expect(systemMessage['content'], contains('Do not translate'));
    expect(userMessage['content'], contains('without translating'));
    expect(userMessage['content'], isNot(contains('write it in Original')));
  });

  test('menuImportLanguageByCode falls back to original for unknown code', () {
    expect(menuImportLanguageByCode('xx').code, 'original');
    expect(menuImportLanguageByCode('en').label, 'English');
  });

  test('stripHtmlForMenuImport removes scripts and tags', () {
    const html = '''
    <html><head><style>body{}</style><script>alert(1)</script></head>
    <body><h1>Restaurant</h1><p>Menu item 95 kr</p></body></html>
    ''';
    final result = stripHtmlForMenuImport(html);
    expect(result, contains('Restaurant'));
    expect(result, contains('95 kr'));
    expect(result, isNot(contains('alert')));
    expect(result, isNot(contains('<h1>')));
  });

  test('MenuImportResult.fromJson parses restaurant and items', () {
    final result = MenuImportResult.fromJson({
      'restaurantName': 'Singh Restaurant',
      'location': 'Main Street 1',
      'mapsUrl': 'https://maps.google.com/?q=test',
      'website': 'https://example.com',
      'phone': '+46 123 456',
      'menuUrl': 'https://example.com/menu',
      'currency': 'SEK',
      'items': [
        {
          'itemNumber': '12',
          'name': 'Chicken Tikka',
          'priceDisplay': '95 kr',
          'priceAmount': 95.0,
        },
      ],
    });

    expect(result.restaurantName, 'Singh Restaurant');
    expect(result.location, 'Main Street 1');
    expect(result.currency, 'SEK');
    expect(result.items, hasLength(1));
    expect(result.items.first.name, 'Chicken Tikka');
    expect(result.items.first.priceAmount, 95.0);
  });

  test('parseMenuImportResponseBody extracts menu JSON', () {
    final aiBody = jsonEncode({
      'choices': [
        {
          'message': {
            'content': jsonEncode({
              'restaurantName': 'Local Place',
              'items': [
                {
                  'name': 'Pizza',
                  'priceDisplay': '120 kr',
                  'priceAmount': 120,
                },
              ],
            }),
          },
        },
      ],
    });

    final result = parseMenuImportResponseBody(aiBody);
    expect(result.restaurantName, 'Local Place');
    expect(result.items.first.name, 'Pizza');
  });

  test('importFromUrl fetches page and calls AI', () async {
    const pageHtml = '<html><body><h1>Restaurant Menu</h1></body></html>';
    final menuJson = jsonEncode({
      'restaurantName': 'Test Restaurant',
      'location': 'Stockholm',
      'mapsUrl': null,
      'website': 'https://example.com',
      'phone': '+46 111',
      'menuUrl': 'https://example.com/menu',
      'currency': 'SEK',
      'items': [
        {
          'itemNumber': '1',
          'name': 'Burger',
          'priceDisplay': '99 kr',
          'priceAmount': 99,
        },
      ],
    });

    final service = MenuImportService(
      aiConfig: const AiConfig(
        apiUri: 'https://api.example.com/v1',
        apiKey: 'test-key',
        modelName: 'test-model',
      ),
      pageHtmlFetcher: (url) async => pageHtml,
      httpPost: (url, {headers, body}) async {
        expect(url.toString(), 'https://api.example.com/v1/chat/completions');
        expect(headers?['Authorization'], 'Bearer test-key');
        final decoded = jsonDecode(body as String) as Map<String, dynamic>;
        final userMessage =
            (decoded['messages'] as List).last['content'] as String;
        expect(userMessage, contains('Restaurant Menu'));
        expect(userMessage, contains('without translating'));
        return http.Response(
          jsonEncode({
            'choices': [
              {'message': {'content': menuJson}},
            ],
          }),
          200,
        );
      },
    );

    final result =
        await service.importFromUrl('https://example.com/menu');
    expect(result.restaurantName, 'Test Restaurant');
    expect(result.items, hasLength(1));
    expect(result.menuUrl, 'https://example.com/menu');
  });

  test('importFromUrl strips HTML before sending to AI', () async {
    const pageHtml = '''
    <html><body>
    <script>track()</script>
    <div class="item">Chicken 95 kr</div>
    </body></html>
    ''';

    final service = MenuImportService(
      aiConfig: const AiConfig(
        apiUri: 'https://api.example.com/v1',
        apiKey: 'test-key',
        modelName: 'test-model',
      ),
      pageHtmlFetcher: (url) async => pageHtml,
      httpPost: (url, {headers, body}) async {
        final decoded = jsonDecode(body as String) as Map<String, dynamic>;
        final userMessage =
            (decoded['messages'] as List).last['content'] as String;
        expect(userMessage, contains('Chicken 95 kr'));
        expect(userMessage, isNot(contains('track()')));
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'restaurantName': 'Place',
                    'items': [],
                  }),
                },
              },
            ],
          }),
          200,
        );
      },
    );

    await service.importFromUrl('https://example.com/menu');
  });

  test('fixture HTML is stripped for AI import pipeline', () async {
    final singhHtml = await File(
      'test/fixtures/menu_pages/singhwebordring.html',
    ).readAsString();
    final kvartersHtml = await File(
      'test/fixtures/menu_pages/kvartersmenyn.html',
    ).readAsString();

    final singhStripped = stripHtmlForMenuImport(singhHtml);
    final kvartersStripped = stripHtmlForMenuImport(kvartersHtml);

    expect(singhStripped, isNotEmpty);
    expect(kvartersStripped, isNotEmpty);
    expect(singhStripped, isNot(contains('<script')));
    expect(kvartersStripped, isNot(contains('<script')));
  });

  test('importFromUrl works with singh fixture and mocked AI', () async {
    final pageHtml = await File(
      'test/fixtures/menu_pages/singhwebordring.html',
    ).readAsString();
    final menuJson = jsonEncode({
      'restaurantName': 'Singh Restaurant',
      'location': 'Test City',
      'mapsUrl': null,
      'website': 'https://example.com',
      'phone': '+46 123',
      'menuUrl': 'https://example.com/menu',
      'currency': 'SEK',
      'items': [
        {
          'itemNumber': '1',
          'name': 'Chicken Tikka',
          'priceDisplay': '95 kr',
          'priceAmount': 95,
        },
      ],
    });

    final service = MenuImportService(
      aiConfig: const AiConfig(
        apiUri: 'https://api.example.com/v1',
        apiKey: 'test-key',
        modelName: 'test-model',
      ),
      pageHtmlFetcher: (url) async => pageHtml,
      httpPost: (url, {headers, body}) async {
        final decoded = jsonDecode(body as String) as Map<String, dynamic>;
        final userMessage =
            (decoded['messages'] as List).last['content'] as String;
        expect(userMessage, contains('Online Ordering'));
        return http.Response(
          jsonEncode({
            'choices': [
              {'message': {'content': menuJson}},
            ],
          }),
          200,
        );
      },
    );

    final result = await service.importFromUrl(
      'https://www.singhwebordring.com/ordering/restaurant/menu',
    );
    expect(result.restaurantName, 'Singh Restaurant');
    expect(result.items.first.name, 'Chicken Tikka');
  });
}
