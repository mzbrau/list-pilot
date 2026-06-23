import 'dart:convert';
import 'dart:io';

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
    this.prepTimeMinutes,
    this.imageUrl,
    this.recipeUrl,
  });

  final String name;
  final List<String> ingredients;
  final List<String> steps;
  final String? notes;
  final List<String> tags;
  final int? prepTimeMinutes;
  final String? imageUrl;
  final String? recipeUrl;

  factory MealImportResult.fromJson(Map<String, dynamic> json) {
    return MealImportResult(
      name: (json['name'] as String?)?.trim() ?? 'Imported meal',
      ingredients: _stringList(json['ingredients']),
      steps: _stringList(json['steps']),
      notes: (json['notes'] as String?)?.trim(),
      tags: _stringList(json['tags']),
      prepTimeMinutes: _prepTimeFromJson(json['prepTimeMinutes']),
      imageUrl: (json['imageUrl'] as String?)?.trim(),
      recipeUrl: (json['recipeUrl'] as String?)?.trim(),
    );
  }

  static int? _prepTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value > 0 ? value : null;
    if (value is num) {
      final minutes = value.round();
      return minutes > 0 ? minutes : null;
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
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
Put one ingredient per line with the quantity and unit first (e.g. "750 g potatoes", "2 cups flour").
Use this exact schema:
{
  "name": "recipe title",
  "ingredients": ["ingredient 1", "ingredient 2"],
  "steps": ["step 1", "step 2"],
  "notes": "optional tips or description",
  "tags": ["Dinner", "Chicken"],
  "prepTimeMinutes": 45,
  "imageUrl": "absolute URL of main recipe image or null",
  "recipeUrl": "canonical recipe page URL or null"
}
Include prepTimeMinutes as total preparation plus cooking time in minutes when stated on the page, or null if unknown.
''';
}

String buildPhotoImportSystemPrompt({required String languageLabel}) {
  return '''
You extract recipe information from a photo of a recipe (cookbook page, screenshot, handwritten card, etc.). Respond with JSON only, no markdown.
Write all user-facing text fields (name, ingredients, steps, notes, tags) in $languageLabel. If the source text is in another language, translate into $languageLabel. Keep units and measurements sensible for the target language.
Put one ingredient per line with the quantity and unit first (e.g. "750 g potatoes", "2 cups flour").
Use this exact schema:
{
  "name": "recipe title",
  "ingredients": ["ingredient 1", "ingredient 2"],
  "steps": ["step 1", "step 2"],
  "notes": "optional tips or description",
  "tags": ["Dinner", "Chicken"],
  "prepTimeMinutes": 45
}
Include prepTimeMinutes as total preparation plus cooking time in minutes when stated, or null if unknown.
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

Map<String, dynamic> buildPhotoImportChatCompletionsBody({
  required String model,
  required String imageBase64,
  required String mimeType,
  required String languageLabel,
}) {
  return {
    'model': model,
    'messages': [
      {
        'role': 'system',
        'content': buildPhotoImportSystemPrompt(languageLabel: languageLabel),
      },
      {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text':
                'Extract the recipe from this photo and write it in $languageLabel.',
          },
          {
            'type': 'image_url',
            'image_url': {'url': 'data:$mimeType;base64,$imageBase64'},
          },
        ],
      },
    ],
    'response_format': {'type': 'json_object'},
  };
}

String? mimeTypeForImagePath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return null;
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
      prepTimeMinutes: result.prepTimeMinutes,
      imageUrl: imageUrl,
      recipeUrl: result.recipeUrl ?? pageUri.toString(),
    );
  }

  Future<MealImportResult> importFromPhoto(
    String imagePath, {
    RecipeImportLanguage language = defaultRecipeImportLanguage,
  }) async {
    if (!_aiConfig.isConfigured) {
      throw StateError('AI configuration is incomplete');
    }

    final photoModel = _aiConfig.effectivePhotoImportModel;
    if (photoModel == null || photoModel.isEmpty) {
      throw StateError('Photo import model is not configured');
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw MealImportException('Image file not found');
    }

    final mimeType = mimeTypeForImagePath(imagePath);
    if (mimeType == null) {
      throw MealImportException('Unsupported image format');
    }

    final imageBytes = await file.readAsBytes();
    if (imageBytes.isEmpty) {
      throw MealImportException('Image file is empty');
    }

    final baseUri = _aiConfig.apiUri!.trim().replaceAll(RegExp(r'/+$'), '');
    final apiUri = Uri.parse('$baseUri/chat/completions');
    final body = buildPhotoImportChatCompletionsBody(
      model: photoModel,
      imageBase64: base64Encode(imageBytes),
      mimeType: mimeType,
      languageLabel: language.label,
    );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_aiConfig.apiKey!.trim()}',
    };

    http.Response aiResponse = await _httpPost(
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
      throw MealImportException('AI request failed (${aiResponse.statusCode})');
    }

    return parseImportResponseBody(aiResponse.body);
  }
}

class MealImportException implements Exception {
  const MealImportException(this.message);
  final String message;

  @override
  String toString() => message;
}
