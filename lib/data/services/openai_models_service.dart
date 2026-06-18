import 'dart:convert';

import 'package:http/http.dart' as http;

import 'meal_import_service.dart';

class OpenAiModelsException implements Exception {
  OpenAiModelsException(this.message);

  final String message;

  @override
  String toString() => message;
}

List<String> parseModelsResponse(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw OpenAiModelsException('Invalid models response');
  }
  final data = decoded['data'];
  if (data is! List) {
    throw OpenAiModelsException('Invalid models response');
  }

  final ids = <String>[];
  for (final entry in data) {
    if (entry is Map<String, dynamic>) {
      final id = entry['id'];
      if (id is String && id.trim().isNotEmpty) {
        ids.add(id.trim());
      }
    }
  }
  return filterChatModels(ids);
}

List<String> filterChatModels(List<String> ids) {
  final filtered = ids.where(_isChatCapableModel).toSet().toList()..sort();
  return filtered;
}

List<String> mergeModelOptions(List<String> models, String? currentModel) {
  final model = currentModel?.trim();
  if (model == null || model.isEmpty || models.contains(model)) {
    return models;
  }
  return [model, ...models];
}

bool _isChatCapableModel(String id) {
  final lower = id.toLowerCase();

  const excludedPrefixes = [
    'text-embedding',
    'whisper',
    'dall-e',
    'tts-',
    'omni-moderation',
    'davinci',
    'babbage',
    'curie',
    'ada',
  ];
  if (excludedPrefixes.any(lower.startsWith)) return false;

  const excludedSubstrings = [
    'embed',
    'image',
    'audio',
    'realtime',
    'search',
    'transcribe',
    'tts',
    'instruct',
    'legacy',
  ];
  if (excludedSubstrings.any(lower.contains)) return false;

  if (lower.startsWith('gpt-')) return true;

  if (lower == 'o1') return true;
  if (RegExp(r'^o\d').hasMatch(lower)) return true;

  return false;
}

class OpenAiModelsService {
  OpenAiModelsService({HttpGet? httpGet})
      : _httpGet = httpGet ?? OpenAiModelsHttpClient().get;

  final HttpGet _httpGet;

  Future<List<String>> fetchModels({
    required String apiUri,
    required String apiKey,
  }) async {
    final baseUri = apiUri.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$baseUri/models');
    final response = await _httpGet(
      uri,
      headers: {'Authorization': 'Bearer ${apiKey.trim()}'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw OpenAiModelsException(
        'Failed to load models (${response.statusCode})',
      );
    }

    return parseModelsResponse(response.body);
  }
}

class OpenAiModelsHttpClient {
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return http.get(url, headers: headers);
  }
}
