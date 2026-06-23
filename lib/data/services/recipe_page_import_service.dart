import 'package:http/http.dart' as http;

import 'meal_import_service.dart' show MealImportResult;
import 'recipe_page_extractor.dart';
import 'recipe_page_fetcher.dart';
import 'recipe_page_metadata.dart';

class RecipeImportException implements Exception {
  const RecipeImportException(this.message);
  final String message;

  @override
  String toString() => message;
}

class RecipePageImportService {
  RecipePageImportService({
    HttpGet? httpGet,
    PageHtmlFetcher? pageHtmlFetcher,
    RecipePageExtractor? extractor,
  })  : _httpGet = httpGet ?? http.get,
        _pageHtmlFetcher = pageHtmlFetcher,
        _extractor = extractor ?? RecipePageExtractor();

  final HttpGet _httpGet;
  final PageHtmlFetcher? _pageHtmlFetcher;
  final RecipePageExtractor _extractor;

  Future<String> _fetchPageHtml(Uri pageUri) async {
    try {
      final fetcher = _pageHtmlFetcher;
      if (fetcher != null) {
        return await fetcher(pageUri);
      }
      return await RecipePageFetcher(httpGet: _httpGet).fetchHtml(pageUri);
    } on RecipePageFetchException catch (e) {
      throw RecipeImportException(e.message);
    }
  }

  Future<MealImportResult> importFromUrl(String url) async {
    final pageUri = Uri.parse(url.trim());
    final pageHtml = await _fetchPageHtml(pageUri);
    final extracted = _extractor.extract(pageHtml, pageUri);

    if (extracted == null) {
      throw const RecipeImportException(
        'Could not extract a recipe from this page. '
        'The site may not publish structured recipe data.',
      );
    }

    final fallbackImage = extractRecipeImageUrl(pageHtml, pageUri);
    final imageUrl = (extracted.imageUrl != null && extracted.imageUrl!.isNotEmpty)
        ? extracted.imageUrl
        : fallbackImage;

    return MealImportResult(
      name: extracted.name,
      ingredients: extracted.ingredients,
      steps: extracted.steps,
      notes: extracted.notes,
      tags: extracted.tags,
      prepTimeMinutes: extracted.prepTimeMinutes,
      imageUrl: imageUrl,
      recipeUrl: extracted.recipeUrl ?? pageUri.toString(),
    );
  }
}
