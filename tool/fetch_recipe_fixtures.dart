// ignore_for_file: avoid_print

/// Documents the fixture fetch workflow and provides [anonymizeRecipeHtml].
///
/// Live fetching is done via curl (see test/fixtures/recipe_pages/README.md) because
/// this project depends on Flutter packages that cannot be run with `dart run`.
///
/// To regenerate expected JSON after editing fixtures:
///   flutter test test/recipe_fixture_generator_test.dart

String anonymizeRecipeHtml(String html) {
  var result = html;

  // Replace recipe site domains but preserve schema.org URLs.
  final domainPattern = RegExp(
    r'https?://(?:www\.)?(?:bbcgoodfood\.com|allrecipes\.com|seriouseats\.com|'
    r'jamieoliver\.com|delish\.com|foodnetwork\.com|taste\.com\.au|'
    r'budgetbytes\.com|pinchofyum\.com|cookieandkate\.com|'
    r'images\.immediate\.co\.uk|pinchofyum\.com)'
    r'(?:/[^\s"\'<>]*)?',
    caseSensitive: false,
  );
  result = result.replaceAll(domainPattern, 'https://example-recipes.test/path');

  result = result.replaceAll(
    RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
    'user@example-recipes.test',
  );

  result = result.replaceAll(
    RegExp(r'<script[^>]*google-analytics[^>]*>[\s\S]*?</script>', caseSensitive: false),
    '',
  );
  result = result.replaceAll(
    RegExp(r'<script[^>]*googletagmanager[^>]*>[\s\S]*?</script>', caseSensitive: false),
    '',
  );

  return result;
}
