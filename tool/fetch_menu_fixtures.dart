// ignore_for_file: avoid_print

/// Anonymizes menu page HTML fixtures (see test/fixtures/menu_pages/README.md).
String anonymizeMenuHtml(String html) {
  var result = html;

  final domainPattern = RegExp(
    r'https?://(?:www\.)?(?:singhwebordring\.com|kvartersmenyn\.se)'
    r'(?:/[^\s"\'<>]*)?',
    caseSensitive: false,
  );
  result = result.replaceAll(domainPattern, 'https://example-menus.test/path');

  result = result.replaceAll(
    RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
    'user@example-menus.test',
  );

  return result;
}
