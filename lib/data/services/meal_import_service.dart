import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/providers/app_providers.dart';

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

String buildImportSystemPrompt() {
  return '''
You extract recipe information from webpage content. Respond with JSON only, no markdown.
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
}) {
  return {
    'model': model,
    'messages': [
      {'role': 'system', 'content': buildImportSystemPrompt()},
      {
        'role': 'user',
        'content':
            'Extract the recipe from this webpage.\nURL: $pageUrl\n\nContent:\n$pageContent',
      },
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
  })  : _aiConfig = aiConfig,
        _httpGet = httpGet ?? MealImportHttpClient().get,
        _httpPost = httpPost ?? MealImportHttpClient().post;

  final AiConfig _aiConfig;
  final HttpGet _httpGet;
  final HttpPost _httpPost;

  bool get isConfigured => _aiConfig.isConfigured;

  Future<MealImportResult> importFromUrl(String url) async {
    if (!_aiConfig.isConfigured) {
      throw StateError('AI configuration is incomplete');
    }

    final pageUri = Uri.parse(url.trim());
    final pageResponse = await _httpGet(
      pageUri,
      headers: const {
        'User-Agent':
            'Mozilla/5.0 (compatible; ListPilot/1.0; +https://listpilot.app)',
      },
    ).timeout(const Duration(seconds: 15));

    if (pageResponse.statusCode != 200) {
      throw MealImportException(
        'Failed to fetch page (${pageResponse.statusCode})',
      );
    }

    final stripped = stripHtmlForImport(pageResponse.body);
    final baseUri = _aiConfig.apiUri!.trim().replaceAll(RegExp(r'/+$'), '');
    final apiUri = Uri.parse('$baseUri/chat/completions');

    final body = buildChatCompletionsBody(
      model: _aiConfig.modelName!.trim(),
      pageUrl: pageUri.toString(),
      pageContent: stripped,
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
    return MealImportResult(
      name: result.name,
      ingredients: result.ingredients,
      steps: result.steps,
      notes: result.notes,
      tags: result.tags,
      imageUrl: result.imageUrl,
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
