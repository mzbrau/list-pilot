import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/providers/app_providers.dart';
import 'recipe_page_fetcher.dart';
import 'recipe_page_metadata.dart';

class RecipeImportLanguage {
  const RecipeImportLanguage({required this.code, required this.label});

  final String code;
  final String label;
}

const defaultRecipeImportLanguageCode = 'en';

const defaultRecipeImportLanguage =
    RecipeImportLanguage(code: 'en', label: 'English');

const recipeImportLanguages = [
  defaultRecipeImportLanguage,
  RecipeImportLanguage(code: 'es', label: 'Spanish'),
  RecipeImportLanguage(code: 'fr', label: 'French'),
  RecipeImportLanguage(code: 'de', label: 'German'),
  RecipeImportLanguage(code: 'it', label: 'Italian'),
  RecipeImportLanguage(code: 'pt', label: 'Portuguese'),
  RecipeImportLanguage(code: 'nl', label: 'Dutch'),
  RecipeImportLanguage(code: 'pl', label: 'Polish'),
  RecipeImportLanguage(code: 'sv', label: 'Swedish'),
  RecipeImportLanguage(code: 'no', label: 'Norwegian'),
  RecipeImportLanguage(code: 'da', label: 'Danish'),
  RecipeImportLanguage(code: 'fi', label: 'Finnish'),
  RecipeImportLanguage(code: 'ja', label: 'Japanese'),
  RecipeImportLanguage(code: 'zh', label: 'Chinese (Simplified)'),
  RecipeImportLanguage(code: 'ko', label: 'Korean'),
  RecipeImportLanguage(code: 'tr', label: 'Turkish'),
  RecipeImportLanguage(code: 'cs', label: 'Czech'),
  RecipeImportLanguage(code: 'hu', label: 'Hungarian'),
  RecipeImportLanguage(code: 'el', label: 'Greek'),
  RecipeImportLanguage(code: 'ro', label: 'Romanian'),
  RecipeImportLanguage(code: 'uk', label: 'Ukrainian'),
  RecipeImportLanguage(code: 'ru', label: 'Russian'),
  RecipeImportLanguage(code: 'ar', label: 'Arabic'),
  RecipeImportLanguage(code: 'hi', label: 'Hindi'),
];

RecipeImportLanguage recipeImportLanguageByCode(String code) {
  return recipeImportLanguages.firstWhere(
    (language) => language.code == code,
    orElse: () => defaultRecipeImportLanguage,
  );
}

typedef HttpGet = Future<http.Response> Function(Uri url, {Map<String, String>? headers});
typedef HttpPost = Future<http.Response> Function(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
});

class MealImportHttpClient {
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return http.post(url, headers: headers, body: body);
  }
}

class MealImportResult {
  const MealImportResult({
    required this.name,
    required this.ingredients,
    required this.steps,
    this.notes,
    required this.tags,
    this.imageUrl,
    this.recipeUrl,
  });

  final String name;
  final List<String> ingredients;
  final List<String> steps;
  final String? notes;
  final List<String> tags;
  final String? imageUrl;
  final String? recipeUrl;

  factory MealImportResult.fromJson(Map<String, dynamic> json) {
    return MealImportResult(
      name: (json['name'] as String?)?.trim() ?? 'Imported meal',
      ingredients: _stringList(json['ingredients']),
      steps: _stringList(json['steps']),
      notes: (json['notes'] as String?)?.trim(),
      tags: _stringList(json['tags']),
      imageUrl: (json['imageUrl'] as String?)?.trim(),
      recipeUrl: (json['recipeUrl'] as String?)?.trim(),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
  }
}

String stripHtmlForImport(String html) {
  var text = html
      .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  const maxLength = 12000;
  if (text.length > maxLength) {
    text = text.substring(0, maxLength);
  }
  return text;
}

String buildImportSystemPrompt({required String languageLabel}) {
  return '''
You extract recipe information from webpage content. Respond with JSON only, no markdown.
Write all user-facing text fields (name, ingredients, steps, notes, tags) in $languageLabel. If the source page is in another language, translate into $languageLabel. Keep units and measurements sensible for the target language.
Use this exact schema:
{
  "name": "recipe title",
  "ingredients": ["ingredient 1", "ingredient 2"],
  "steps": ["step 1", "step 2"],
  "notes": "optional tips or description",
  "tags": ["Dinner", "Chicken"],
  "imageUrl": "absolute URL of main recipe image or null",
  "recipeUrl": "canonical recipe page URL or null"
}
''';
}

Map<String, dynamic> buildChatCompletionsBody({
  required String model,
  required String pageUrl,
  required String pageContent,
  required String languageLabel,
  String? knownImageUrl,
}) {
  var userContent =
      'Extract the recipe from this webpage and write it in $languageLabel.\nURL: $pageUrl\n\nContent:\n$pageContent';
  if (knownImageUrl != null && knownImageUrl.isNotEmpty) {
    userContent += '\n\nKnown hero image: $knownImageUrl';
  }

  return {
    'model': model,
    'messages': [
      {'role': 'system', 'content': buildImportSystemPrompt(languageLabel: languageLabel)},
      {'role': 'user', 'content': userContent},
    ],
    'response_format': {'type': 'json_object'},
  };
}

MealImportResult parseImportResponseBody(String responseBody) {
  final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
  final choices = decoded['choices'] as List<dynamic>?;
  if (choices == null || choices.isEmpty) {
    throw const FormatException('No choices in AI response');
  }
  final message = choices.first as Map<String, dynamic>;
  final content = (message['message'] as Map<String, dynamic>)['content'] as String;
  final recipeJson = jsonDecode(content) as Map<String, dynamic>;
  return MealImportResult.fromJson(recipeJson);
}

class MealImportService {
  MealImportService({
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
      throw MealImportException(e.message);
    }
  }

  Future<MealImportResult> importFromUrl(
    String url, {
    RecipeImportLanguage language = defaultRecipeImportLanguage,
  }) async {
    if (!_aiConfig.isConfigured) {
      throw StateError('AI configuration is incomplete');
    }

    final pageUri = Uri.parse(url.trim());
    final pageHtml = await _fetchPageHtml(pageUri);
    final extractedImageUrl = extractRecipeImageUrl(pageHtml, pageUri);
    final stripped = stripHtmlForImport(pageHtml);
    final baseUri = _aiConfig.apiUri!.trim().replaceAll(RegExp(r'/+$'), '');
    final apiUri = Uri.parse('$baseUri/chat/completions');

    final body = buildChatCompletionsBody(
      model: _aiConfig.modelName!.trim(),
      pageUrl: pageUri.toString(),
      pageContent: stripped,
      languageLabel: language.label,
      knownImageUrl: extractedImageUrl,
    );

    http.Response aiResponse;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_aiConfig.apiKey!.trim()}',
    };

    aiResponse = await _httpPost(
      apiUri,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60));

    if (aiResponse.statusCode != 200) {
      body.remove('response_format');
      aiResponse = await _httpPost(
        apiUri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60));
    }

    if (aiResponse.statusCode != 200) {
      throw MealImportException('AI request failed (${aiResponse.statusCode})');
    }

    final result = parseImportResponseBody(aiResponse.body);
    final imageUrl = (result.imageUrl != null && result.imageUrl!.isNotEmpty)
        ? resolveUrl(result.imageUrl!, pageUri) ?? result.imageUrl
        : extractedImageUrl;

    return MealImportResult(
      name: result.name,
      ingredients: result.ingredients,
      steps: result.steps,
      notes: result.notes,
      tags: result.tags,
      imageUrl: imageUrl,
      recipeUrl: result.recipeUrl ?? pageUri.toString(),
    );
  }
}

class MealImportException implements Exception {
  const MealImportException(this.message);
  final String message;

  @override
  String toString() => message;
}
