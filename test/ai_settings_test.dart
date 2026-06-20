import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:list_pilot/core/constants/app_constants.dart';
import 'package:list_pilot/core/providers/app_providers.dart';
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/services/openai_models_service.dart';
import 'package:list_pilot/features/lists/lists_overview_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleModelsResponse = '''
{
  "object": "list",
  "data": [
    {"id": "gpt-4o", "object": "model"},
    {"id": "gpt-4o-mini", "object": "model"}
  ]
}
''';

  Future<void> pumpOverview(
    WidgetTester tester, {
    required AppDatabase db,
    Map<String, Object> prefs = const {},
    List<Override> overrides = const [],
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        appInitProvider.overrideWith((ref) async {}),
        appVersionProvider.overrideWith(
          (ref) async => PackageInfo(
            appName: 'List Pilot',
            packageName: 'com.example.list_pilot',
            version: '1.0.0',
            buildNumber: '1',
          ),
        ),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ListsOverviewScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
  }

  test('AiConfig masks API keys with asterisks', () {
    const config = AiConfig(apiKey: 'sk-test-key');
    expect(config.maskedApiKey, '***********');
  });

  test('AiConfig detects OpenAI endpoint host', () {
    expect(
      AiConfig.isOpenAiUri('https://api.openai.com/v1'),
      isTrue,
    );
    expect(
      AiConfig.isOpenAiUri('https://api.example.com/v1'),
      isFalse,
    );
  });

  test('AiConfig effectivePhotoImportModel falls back to main model', () {
    const config = AiConfig(
      modelName: 'gpt-4o-mini',
      photoImportModelName: 'gpt-4o',
    );
    expect(config.effectivePhotoImportModel, 'gpt-4o');

    const fallback = AiConfig(modelName: 'gpt-4o-mini');
    expect(fallback.effectivePhotoImportModel, 'gpt-4o-mini');
  });

  test('filterVisionModels keeps vision-capable chat models', () {
    final models = filterVisionModels([
      'gpt-4o',
      'gpt-4o-mini',
      'gpt-4-turbo',
      'gpt-3.5-turbo',
      'text-embedding-3-small',
      'dall-e-3',
    ]);
    expect(models, ['gpt-4-turbo', 'gpt-4o', 'gpt-4o-mini']);
  });

  testWidgets('configured AI settings show summary with masked key',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await pumpOverview(
      tester,
      db: db,
      prefs: {
        AppConstants.mealManagerEnabledKey: true,
        AppConstants.aiApiUriKey: 'https://api.openai.com/v1',
        AppConstants.aiApiKeyKey: 'secret-key-12',
        AppConstants.aiModelNameKey: 'gpt-4o-mini',
      },
    );
    await openSettings(tester);

    expect(find.text('https://api.openai.com/v1'), findsOneWidget);
    expect(find.text('gpt-4o-mini'), findsOneWidget);
    expect(
      find.text(const AiConfig(apiKey: 'secret-key-12').maskedApiKey),
      findsOneWidget,
    );
    expect(find.text('Edit AI settings'), findsOneWidget);
    expect(find.text('Save AI settings'), findsNothing);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
  });

  testWidgets('edit mode shows OpenAI model dropdown from cache',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await pumpOverview(
      tester,
      db: db,
      prefs: {
        AppConstants.mealManagerEnabledKey: true,
        AppConstants.aiApiUriKey: 'https://api.openai.com/v1',
        AppConstants.aiApiKeyKey: 'secret-key',
        AppConstants.aiModelNameKey: 'gpt-4o-mini',
        AppConstants.openAiModelsCacheKey: jsonEncode([
          'gpt-4o-mini',
          'gpt-4o',
        ]),
      },
    );
    await openSettings(tester);

    await tester.scrollUntilVisible(
      find.text('Edit AI settings'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Edit AI settings'));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
    expect(find.text('gpt-4o-mini'), findsWidgets);
    expect(find.byTooltip('Refresh models'), findsOneWidget);
    expect(find.text('Save AI settings'), findsOneWidget);
  });

  testWidgets('refresh models button fetches from OpenAI API', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    var fetchCount = 0;

    await pumpOverview(
      tester,
      db: db,
      prefs: {
        AppConstants.mealManagerEnabledKey: true,
        AppConstants.aiApiUriKey: 'https://api.openai.com/v1',
        AppConstants.aiApiKeyKey: 'secret-key',
        AppConstants.aiModelNameKey: 'gpt-4o-mini',
        AppConstants.openAiModelsCacheKey: jsonEncode(['gpt-4o-mini']),
      },
      overrides: [
        openAiModelsServiceProvider.overrideWithValue(
          OpenAiModelsService(
            httpGet: (uri, {headers}) async {
              fetchCount++;
              expect(uri.toString(), 'https://api.openai.com/v1/models');
              return http.Response(sampleModelsResponse, 200);
            },
          ),
        ),
      ],
    );
    await openSettings(tester);

    await tester.scrollUntilVisible(
      find.text('Edit AI settings'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Edit AI settings'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byTooltip('Refresh models'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byTooltip('Refresh models'));
    await tester.pumpAndSettle();

    expect(fetchCount, 1);
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
  });

  testWidgets('non-OpenAI endpoint uses free-text model field', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await pumpOverview(
      tester,
      db: db,
      prefs: {
        AppConstants.mealManagerEnabledKey: true,
      },
    );
    await openSettings(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'API URI'),
      'https://api.example.com/v1',
    );
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.widgetWithText(TextField, 'Model name'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Photo import model'), findsOneWidget);
    expect(find.byTooltip('Refresh models'), findsNothing);
  });
}
