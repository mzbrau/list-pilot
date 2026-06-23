import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/services/meal_plan_ai_suggest_service.dart';

void main() {
  test('buildMealPlanAiSuggestPayload includes options and catalog', () {
    final request = MealPlanAiSuggestRequest(
      options: const MealPlanAiSuggestOptions(
        query: 'quick weeknight dinners',
        prioritizeNotMadeRecently: true,
        offerAlternatives: true,
        suggestionCount: 4,
      ),
      catalog: const [
        MealAiCatalogEntry(
          id: 1,
          displayName: 'Pasta',
          tags: ['Dinner'],
          prepTimeMinutes: 25,
          stepCount: 3,
          ingredientCount: 5,
        ),
      ],
      activePlan: const [
        MealPlanActiveEntry(mealId: 2, displayName: 'Salad'),
      ],
      excludeMealIds: [3],
    );

    final payload = buildMealPlanAiSuggestPayload(request);
    expect(payload['query'], 'quick weeknight dinners');
    expect(payload['suggestionCount'], 4);
    expect(payload['excludeMealIds'], [3]);
    expect((payload['catalog'] as List).length, 1);
    expect((payload['activePlan'] as List).length, 1);
  });

  test('parseMealPlanAiSuggestResponse validates meal ids', () {
    const validIds = {1, 2, 7};
    final body = jsonEncode({
      'choices': [
        {
          'message': {
            'content': jsonEncode({
              'suggestions': [
                {
                  'mealId': 1,
                  'reason': 'A good match',
                  'alternatives': [7, 99],
                },
                {
                  'mealId': 2,
                  'reason': 'Already planned',
                },
                {
                  'mealId': 99,
                  'reason': 'Unknown meal',
                },
              ],
            }),
          },
        },
      ],
    });

    final result = parseMealPlanAiSuggestResponse(
      body,
      validMealIds: validIds,
      activePlanMealIds: {2},
      excludeMealIds: const [],
      offerAlternatives: true,
    );

    expect(result.suggestions.length, 1);
    expect(result.suggestions.first.mealId, 1);
    expect(result.suggestions.first.alternatives, [7]);
  });

  test('parseMealPlanAiSuggestResponse throws when no valid suggestions', () {
    final body = jsonEncode({
      'choices': [
        {
          'message': {
            'content': jsonEncode({
              'suggestions': [
                {'mealId': 99, 'reason': 'Unknown'},
              ],
            }),
          },
        },
      ],
    });

    expect(
      () => parseMealPlanAiSuggestResponse(
        body,
        validMealIds: {1},
        activePlanMealIds: {},
        excludeMealIds: const [],
        offerAlternatives: false,
      ),
      throwsA(isA<MealPlanAiSuggestException>()),
    );
  });
}
