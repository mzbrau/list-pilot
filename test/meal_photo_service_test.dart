import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/meal_repository.dart';
import 'package:list_pilot/data/services/meal_photo_service.dart';
import 'package:list_pilot/data/services/recipe_page_fetcher.dart';

class _FakeMealRepository extends MealRepository {
  _FakeMealRepository(this._meal)
      : super(AppDatabase.forTesting(NativeDatabase.memory()));

  final Meal _meal;

  @override
  Future<Meal?> getMealById(int id) async => _meal;
}

void main() {
  test('downloadAndSavePhoto sends browser headers with referer', () async {
    Map<String, String>? capturedHeaders;
    final repo = _FakeMealRepository(
      Meal(
        id: 1,
        name: 'test',
        displayName: 'Test',
        portions: 4,
        isUserAdded: true,
        createdAt: DateTime.now(),
      ),
    );

    final service = MealPhotoService(
      repo,
      httpGet: (url, {headers}) async {
        capturedHeaders = headers;
        return http.Response('', 404);
      },
    );

    final saved = await service.downloadAndSavePhoto(
      1,
      'https://cdn.example.com/hero.jpg',
      referer: 'https://example.com/recipe',
    );

    expect(saved, isFalse);
    expect(capturedHeaders?['User-Agent'], recipeBrowserUserAgent);
    expect(capturedHeaders?['Referer'], 'https://example.com/recipe');
  });
}
