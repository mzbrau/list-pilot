import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/platform/import_wakelock.dart';
import '../../core/providers/app_providers.dart';
import 'meal_import_service.dart';
import 'recipe_page_fetcher.dart' hide HttpGet, HttpPost;
import 'recipe_json_ld.dart';

const defaultMenuImportLanguageCode = 'original';

const defaultMenuImportLanguage =
    RecipeImportLanguage(code: 'original', label: 'Original');

const menuImportLanguages = [
  defaultMenuImportLanguage,
  ...recipeImportLanguages,
];

bool isOriginalMenuImportLanguage(RecipeImportLanguage language) =>
    language.code == defaultMenuImportLanguageCode;

RecipeImportLanguage menuImportLanguageByCode(String code) {
  return menuImportLanguages.firstWhere(
    (language) => language.code == code,
    orElse: () => defaultMenuImportLanguage,
  );
}

class MenuImportItem {
  const MenuImportItem({
    this.itemNumber,
    required this.name,
    required this.priceDisplay,
    this.priceAmount,
  });

  final String? itemNumber;
  final String name;
  final String priceDisplay;
  final double? priceAmount;

  factory MenuImportItem.fromJson(Map<String, dynamic> json) {
    final priceAmount = json['priceAmount'];
    return MenuImportItem(
      itemNumber: (json['itemNumber'] as String?)?.trim(),
      name: (json['name'] as String?)?.trim() ?? 'Item',
      priceDisplay: (json['priceDisplay'] as String?)?.trim() ?? '',
      priceAmount: priceAmount is num ? priceAmount.toDouble() : null,
    );
  }
}

class MenuImportResult {
  const MenuImportResult({
    required this.restaurantName,
    this.location,
    this.mapsUrl,
    this.website,
    this.phone,
    this.menuUrl,
    this.currency,
    required this.items,
  });

  final String restaurantName;
  final String? location;
  final String? mapsUrl;
  final String? website;
  final String? phone;
  final String? menuUrl;
  final String? currency;
  final List<MenuImportItem> items;

  factory MenuImportResult.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final items = <MenuImportItem>[];
    if (itemsJson is List) {
      for (final entry in itemsJson) {
        if (entry is Map<String, dynamic>) {
          final item = MenuImportItem.fromJson(entry);
          if (item.name.isNotEmpty) {
            items.add(item);
          }
        }
      }
    }
    return MenuImportResult(
      restaurantName:
          (json['restaurantName'] as String?)?.trim() ?? 'Imported menu',
      location: (json['location'] as String?)?.trim(),
      mapsUrl: (json['mapsUrl'] as String?)?.trim(),
      website: (json['website'] as String?)?.trim(),
      phone: (json['phone'] as String?)?.trim(),
      menuUrl: (json['menuUrl'] as String?)?.trim(),
      currency: (json['currency'] as String?)?.trim(),
      items: items,
    );
  }
}

String stripHtmlForMenuImport(String html) {
  var text = html
      .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  const maxLength = 20000;
  if (text.length > maxLength) {
    text = text.substring(0, maxLength);
  }
  return text;
}

String buildMenuImportSystemPrompt({required RecipeImportLanguage language}) {
  final languageInstruction = isOriginalMenuImportLanguage(language)
      ? 'Keep all user-facing text fields (restaurant name, location, item names) in the original language from the source page. Do not translate.'
      : 'Write user-facing text fields (restaurant name, location, item names) in ${language.label} when translating from another language.';
  return '''
You extract restaurant takeaway menu information from webpage content. Respond with JSON only, no markdown.
$languageInstruction
Preserve original price formatting in priceDisplay (e.g. "95 kr", "£9.50"). Parse priceAmount as a numeric value for calculations.
Extract every menu dish/item with number and price where shown on the page.
Prefer a Google Maps URL for mapsUrl when an address is found.
Use this exact schema:
{
  "restaurantName": "restaurant name",
  "location": "street, city or null",
  "mapsUrl": "https://maps.google.com/... or null",
  "website": "https://... or null",
  "phone": "+46 ... or null",
  "menuUrl": "canonical menu page URL or null",
  "currency": "SEK or GBP or null",
  "items": [
    {
      "itemNumber": "12 or null",
      "name": "Chicken Tikka",
      "priceDisplay": "95 kr",
      "priceAmount": 95.0
    }
  ]
}
''';
}

Map<String, dynamic> buildMenuChatCompletionsBody({
  required String model,
  required String pageUrl,
  required String pageContent,
  required RecipeImportLanguage language,
}) {
  final userInstruction = isOriginalMenuImportLanguage(language)
      ? 'Extract the takeaway restaurant menu from this webpage without translating any text.'
      : 'Extract the takeaway restaurant menu from this webpage and write it in ${language.label}.';
  return {
    'model': model,
    'messages': [
      {
        'role': 'system',
        'content': buildMenuImportSystemPrompt(language: language),
      },
      {
        'role': 'user',
        'content': '$userInstruction\nURL: $pageUrl\n\nContent:\n$pageContent',
      },
    ],
    'response_format': {'type': 'json_object'},
  };
}

MenuImportResult parseMenuImportResponseBody(String responseBody) {
  final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
  final choices = decoded['choices'] as List<dynamic>?;
  if (choices == null || choices.isEmpty) {
    throw const FormatException('No choices in AI response');
  }
  final message = choices.first as Map<String, dynamic>;
  final content =
      (message['message'] as Map<String, dynamic>)['content'] as String;
  final menuJson = jsonDecode(content) as Map<String, dynamic>;
  return MenuImportResult.fromJson(menuJson);
}

class MenuImportService {
  MenuImportService({
    required AiConfig aiConfig,
    HttpGet? httpGet,
    HttpPost? httpPost,
    PageHtmlFetcher? pageHtmlFetcher,
  })  : _aiConfig = aiConfig,
        _httpGet = httpGet ?? MealImportHttpClient().get,
        _httpPost = httpPost ?? MealImportHttpClient().post,
        _pageHtmlFetcher = pageHtmlFetcher;

  final AiConfig _aiConfig;
  final HttpGet _httpGet;
  final HttpPost _httpPost;
  final PageHtmlFetcher? _pageHtmlFetcher;

  bool get isConfigured => _aiConfig.isConfigured;

  Future<String> _fetchPageHtml(Uri pageUri) async {
    try {
      final fetcher = _pageHtmlFetcher;
      if (fetcher != null) {
        return await fetcher(pageUri);
      }
      return await RecipePageFetcher(httpGet: _httpGet).fetchHtml(pageUri);
    } on RecipePageFetchException catch (e) {
      throw MenuImportException(e.message);
    }
  }

  Future<MenuImportResult> importFromUrl(
    String url, {
    RecipeImportLanguage language = defaultMenuImportLanguage,
  }) {
    return runWithImportWakelock(() async {
    if (!_aiConfig.isConfigured) {
      throw StateError('AI configuration is incomplete');
    }

    final pageUri = Uri.parse(url.trim());
    final pageHtml = await _fetchPageHtml(pageUri);
    final stripped = stripHtmlForMenuImport(pageHtml);
    final baseUri = _aiConfig.apiUri!.trim().replaceAll(RegExp(r'/+$'), '');
    final apiUri = Uri.parse('$baseUri/chat/completions');

    final body = buildMenuChatCompletionsBody(
      model: _aiConfig.modelName!.trim(),
      pageUrl: pageUri.toString(),
      pageContent: stripped,
      language: language,
    );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_aiConfig.apiKey!.trim()}',
    };

    var aiResponse = await _httpPost(
      apiUri,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 90));

    if (aiResponse.statusCode != 200) {
      body.remove('response_format');
      aiResponse = await _httpPost(
        apiUri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 90));
    }

    if (aiResponse.statusCode != 200) {
      throw MenuImportException(
        'AI request failed (${aiResponse.statusCode})',
      );
    }

    final result = parseMenuImportResponseBody(aiResponse.body);
    return MenuImportResult(
      restaurantName: result.restaurantName,
      location: result.location,
      mapsUrl: result.mapsUrl != null
          ? resolveUrl(result.mapsUrl!, pageUri) ?? result.mapsUrl
          : null,
      website: result.website != null
          ? resolveUrl(result.website!, pageUri) ?? result.website
          : null,
      phone: result.phone,
      menuUrl: result.menuUrl ?? pageUri.toString(),
      currency: result.currency,
      items: result.items,
    );
    });
  }
}

class MenuImportException implements Exception {
  const MenuImportException(this.message);
  final String message;

  @override
  String toString() => message;
}
