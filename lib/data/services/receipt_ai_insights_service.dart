import 'dart:convert';

import '../../core/providers/app_providers.dart';
import '../database/app_database.dart';
import 'meal_import_service.dart';

String buildReceiptAiInsightsSystemPrompt() {
  return '''
You analyze grocery receipt spending data and provide concise, practical insights.
Write in clear UK English using short sections and bullet points where helpful.
Focus on spending patterns, category trends, notable items, and simple suggestions.
Do not invent data that is not in the input.
''';
}

class ReceiptAiInsightsService {
  ReceiptAiInsightsService({
    required AiConfig aiConfig,
    HttpPost? httpPost,
  })  : _aiConfig = aiConfig,
        _httpPost = httpPost ?? MealImportHttpClient().post;

  final AiConfig _aiConfig;
  final HttpPost _httpPost;

  bool get isConfigured => _aiConfig.isConfigured;

  Future<String> generateInsights({
    required List<Receipt> receipts,
    required List<ReceiptLineWithReceipt> lines,
  }) async {
    if (!_aiConfig.isConfigured) {
      throw StateError('AI configuration is incomplete');
    }

    final payload = {
      'receipts': receipts
          .map(
            (receipt) => {
              'date': receipt.purchasedAt.toIso8601String(),
              'shop': receipt.shopName,
              'total': receipt.totalAmount,
              'currency': receipt.currency,
            },
          )
          .toList(),
      'items': lines
          .map(
            (entry) => {
              'date': entry.receipt.purchasedAt.toIso8601String(),
              'shop': entry.receipt.shopName,
              'item': entry.line.englishName,
              'originalItem': entry.line.originalDescription,
              'categoryId': entry.line.categoryId,
              'quantity': entry.line.quantity,
              'quantityUnit': entry.line.quantityUnit,
              'lineTotal': entry.line.lineTotal,
            },
          )
          .toList(),
    };

    final baseUri = _aiConfig.apiUri!.trim().replaceAll(RegExp(r'/+$'), '');
    final apiUri = Uri.parse('$baseUri/chat/completions');
    final body = {
      'model': _aiConfig.modelName!.trim(),
      'messages': [
        {
          'role': 'system',
          'content': buildReceiptAiInsightsSystemPrompt(),
        },
        {
          'role': 'user',
          'content':
              'Provide spending insights from this receipt data:\n${jsonEncode(payload)}',
        },
      ],
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_aiConfig.apiKey!.trim()}',
    };

    final response = await _httpPost(
      apiUri,
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      throw ReceiptAiInsightsException(
        'AI request failed (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const ReceiptAiInsightsException('No choices in AI response');
    }
    final message = choices.first as Map<String, dynamic>;
    final content =
        (message['message'] as Map<String, dynamic>)['content'] as String;
    return content.trim();
  }
}

class ReceiptAiInsightsException implements Exception {
  const ReceiptAiInsightsException(this.message);
  final String message;

  @override
  String toString() => message;
}
