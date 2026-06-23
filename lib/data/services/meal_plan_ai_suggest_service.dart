import 'dart:convert';

import '../../core/providers/app_providers.dart';
import '../repositories/meal_repository.dart';
import 'meal_import_service.dart';

class MealPlanAiSuggestOptions {
  const MealPlanAiSuggestOptions({
    this.query = '',
    this.prioritizeNotMadeRecently = true,
    this.offerAlternatives = false,
    this.suggestionCount = 5,
  });

  final String query;
  final bool prioritizeNotMadeRecently;
  final bool offerAlternatives;
  final int suggestionCount;

  static const suggestionCountChoices = [3, 4, 5, 6, 7];

  MealPlanAiSuggestOptions copyWith({
    String? query,
    bool? prioritizeNotMadeRecently,
    bool? offerAlternatives,
    int? suggestionCount,
  }) {
    return MealPlanAiSuggestOptions(
      query: query ?? this.query,
      prioritizeNotMadeRecently:
          prioritizeNotMadeRecently ?? this.prioritizeNotMadeRecently,
      offerAlternatives: offerAlternatives ?? this.offerAlternatives,
      suggestionCount: suggestionCount ?? this.suggestionCount,
    );
  }
}

class MealPlanAiSuggestRequest {
  const MealPlanAiSuggestRequest({
    required this.options,
    required this.catalog,
    required this.activePlan,
    this.excludeMealIds = const [],
  });

  final MealPlanAiSuggestOptions options;
  final List<MealAiCatalogEntry> catalog;
  final List<MealPlanActiveEntry> activePlan;
  final List<int> excludeMealIds;
}

class MealPlanActiveEntry {
  const MealPlanActiveEntry({
    required this.mealId,
    required this.displayName,
  });

  final int mealId;
  final String displayName;

  Map<String, dynamic> toJson() => {
        'mealId': mealId,
        'displayName': displayName,
      };
}

class MealPlanAiSuggestion {
  const MealPlanAiSuggestion({
    required this.mealId,
    required this.reason,
    this.alternatives = const [],
  });

  final int mealId;
  final String reason;
  final List<int> alternatives;
}

class MealPlanAiSuggestionResult {
  const MealPlanAiSuggestionResult({
    required this.suggestions,
  });

  final List<MealPlanAiSuggestion> suggestions;
}

String buildMealPlanAiSuggestSystemPrompt() {
  return '''
You help users plan meals for the week from their saved recipe catalog only.
Respond with JSON only, no markdown.
Never invent recipes or meal names. Only use meal ids from the provided catalog.
Do not suggest meals listed in excludeMealIds.
Avoid suggesting meals already in activePlan as primary suggestions unless no other good matches exist.
When prioritizeNotMadeRecently is true, favour meals with older or missing lastEaten dates.
When offerAlternatives is true, include 1-2 alternative meal ids per suggestion from the same catalog.
Prefer lower prepTimeMinutes for weekday-style planning when the user query implies a work week; treat null prep time as unknown.
Return up to suggestionCount primary suggestions.

Use this exact schema:
{
  "suggestions": [
    {
      "mealId": 12,
      "reason": "Brief reason tied to the user query and meal metadata",
      "alternatives": [7, 19]
    }
  ]
}
Omit alternatives or use an empty array when offerAlternatives is false.
''';
}

Map<String, dynamic> buildMealPlanAiSuggestPayload(MealPlanAiSuggestRequest request) {
  return {
    'query': request.options.query.trim(),
    'prioritizeNotMadeRecently': request.options.prioritizeNotMadeRecently,
    'offerAlternatives': request.options.offerAlternatives,
    'suggestionCount': request.options.suggestionCount,
    'catalog': request.catalog.map((e) => e.toJson()).toList(),
    'activePlan': request.activePlan.map((e) => e.toJson()).toList(),
    'excludeMealIds': request.excludeMealIds,
  };
}

MealPlanAiSuggestionResult parseMealPlanAiSuggestResponse(
  String responseBody, {
  required Set<int> validMealIds,
  required Set<int> activePlanMealIds,
  required List<int> excludeMealIds,
  required bool offerAlternatives,
}) {
  final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
  final choices = decoded['choices'] as List<dynamic>?;
  if (choices == null || choices.isEmpty) {
    throw const MealPlanAiSuggestException('No choices in AI response');
  }
  final message = choices.first as Map<String, dynamic>;
  final content =
      (message['message'] as Map<String, dynamic>)['content'] as String;
  final resultJson = jsonDecode(content) as Map<String, dynamic>;
  final rawSuggestions = resultJson['suggestions'];
  if (rawSuggestions is! List) {
    throw const MealPlanAiSuggestException('Invalid suggestions in AI response');
  }

  final excludeSet = excludeMealIds.toSet();
  final suggestions = <MealPlanAiSuggestion>[];

  for (final item in rawSuggestions) {
    if (item is! Map<String, dynamic>) continue;
    final mealId = _parseMealId(item['mealId']);
    if (mealId == null ||
        !validMealIds.contains(mealId) ||
        excludeSet.contains(mealId) ||
        activePlanMealIds.contains(mealId)) {
      continue;
    }

    final reason = (item['reason'] as String?)?.trim();
    if (reason == null || reason.isEmpty) continue;

    final alternatives = <int>[];
    if (offerAlternatives && item['alternatives'] is List) {
      for (final alt in item['alternatives'] as List) {
        final altId = _parseMealId(alt);
        if (altId == null ||
            altId == mealId ||
            !validMealIds.contains(altId) ||
            excludeSet.contains(altId)) {
          continue;
        }
        if (!alternatives.contains(altId)) {
          alternatives.add(altId);
        }
      }
    }

    suggestions.add(
      MealPlanAiSuggestion(
        mealId: mealId,
        reason: reason,
        alternatives: alternatives,
      ),
    );
  }

  if (suggestions.isEmpty) {
    throw const MealPlanAiSuggestException(
      'No valid meal suggestions returned. Try adjusting your query or try again.',
    );
  }

  return MealPlanAiSuggestionResult(suggestions: suggestions);
}

int? _parseMealId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

class MealPlanAiSuggestService {
  MealPlanAiSuggestService({
    required AiConfig aiConfig,
    HttpPost? httpPost,
  })  : _aiConfig = aiConfig,
        _httpPost = httpPost ?? MealImportHttpClient().post;

  final AiConfig _aiConfig;
  final HttpPost _httpPost;

  bool get isConfigured => _aiConfig.isConfigured;

  Future<MealPlanAiSuggestionResult> suggestMeals(
    MealPlanAiSuggestRequest request,
  ) async {
    if (!_aiConfig.isConfigured) {
      throw StateError('AI configuration is incomplete');
    }
    if (request.catalog.isEmpty) {
      throw const MealPlanAiSuggestException(
        'Add meals to Meal Manager before requesting suggestions.',
      );
    }

    final validMealIds = request.catalog.map((e) => e.id).toSet();
    final activePlanMealIds =
        request.activePlan.map((e) => e.mealId).toSet();

    final baseUri = _aiConfig.apiUri!.trim().replaceAll(RegExp(r'/+$'), '');
    final apiUri = Uri.parse('$baseUri/chat/completions');
    final payload = buildMealPlanAiSuggestPayload(request);

    final body = {
      'model': _aiConfig.modelName!.trim(),
      'messages': [
        {
          'role': 'system',
          'content': buildMealPlanAiSuggestSystemPrompt(),
        },
        {
          'role': 'user',
          'content':
              'Suggest meals from this data:\n${jsonEncode(payload)}',
        },
      ],
      'response_format': {'type': 'json_object'},
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_aiConfig.apiKey!.trim()}',
    };

    var response = await _httpPost(
      apiUri,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      body.remove('response_format');
      response = await _httpPost(
        apiUri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 90));
    }

    if (response.statusCode != 200) {
      throw MealPlanAiSuggestException(
        'AI request failed (${response.statusCode})',
      );
    }

    return parseMealPlanAiSuggestResponse(
      response.body,
      validMealIds: validMealIds,
      activePlanMealIds: activePlanMealIds,
      excludeMealIds: request.excludeMealIds,
      offerAlternatives: request.options.offerAlternatives,
    );
  }
}

class MealPlanAiSuggestException implements Exception {
  const MealPlanAiSuggestException(this.message);
  final String message;

  @override
  String toString() => message;
}
