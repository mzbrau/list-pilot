import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:list_pilot/data/services/openai_models_service.dart';

void main() {
  const sampleResponse = '''
{
  "object": "list",
  "data": [
    {"id": "gpt-4o", "object": "model"},
    {"id": "gpt-4o-mini", "object": "model"},
    {"id": "o3-mini", "object": "model"},
    {"id": "text-embedding-3-small", "object": "model"},
    {"id": "whisper-1", "object": "model"},
    {"id": "dall-e-3", "object": "model"}
  ]
}
''';

  test('parseModelsResponse extracts and filters chat models', () {
    final models = parseModelsResponse(sampleResponse);
    expect(models, ['gpt-4o', 'gpt-4o-mini', 'o3-mini']);
  });

  test('filterChatModels keeps gpt and o-series models', () {
    final models = filterChatModels([
      'gpt-4o',
      'gpt-4o-mini',
      'o3-mini',
      'text-embedding-3-small',
      'whisper-1',
      'dall-e-3',
    ]);
    expect(models, ['gpt-4o', 'gpt-4o-mini', 'o3-mini']);
  });

  test('mergeModelOptions includes current model when missing', () {
    expect(
      mergeModelOptions(['gpt-4o'], 'custom-model'),
      ['custom-model', 'gpt-4o'],
    );
    expect(
      mergeModelOptions(['gpt-4o'], 'gpt-4o'),
      ['gpt-4o'],
    );
  });

  test('fetchModels requests models endpoint and parses response', () async {
    final service = OpenAiModelsService(
      httpGet: (uri, {headers}) async {
        expect(uri.toString(), 'https://api.openai.com/v1/models');
        expect(headers?['Authorization'], 'Bearer test-key');
        return http.Response(sampleResponse, 200);
      },
    );

    final models = await service.fetchModels(
      apiUri: 'https://api.openai.com/v1/',
      apiKey: 'test-key',
    );

    expect(models, ['gpt-4o', 'gpt-4o-mini', 'o3-mini']);
  });

  test('fetchModels throws on non-200 response', () async {
    final service = OpenAiModelsService(
      httpGet: (uri, {headers}) async => http.Response('Unauthorized', 401),
    );

    expect(
      () => service.fetchModels(
        apiUri: 'https://api.openai.com/v1',
        apiKey: 'bad-key',
      ),
      throwsA(isA<OpenAiModelsException>()),
    );
  });
}
