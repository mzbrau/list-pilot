import 'recipe_json_ld.dart';

export 'recipe_json_ld.dart' show resolveUrl;

String? extractRecipeImageUrl(String html, Uri pageUri) {
  final fromMeta = _extractMetaImage(html, pageUri);
  if (fromMeta != null) return fromMeta;

  final fromJsonLd = _extractJsonLdRecipeImage(html, pageUri);
  if (fromJsonLd != null) return fromJsonLd;

  return null;
}

String? _extractMetaImage(String html, Uri pageUri) {
  const properties = ['og:image', 'twitter:image', 'twitter:image:src'];
  for (final property in properties) {
    final patterns = [
      RegExp(
        '<meta[^>]+property=["\']$property["\'][^>]+content=["\']([^"\']+)["\']',
        caseSensitive: false,
      ),
      RegExp(
        '<meta[^>]+content=["\']([^"\']+)["\'][^>]+property=["\']$property["\']',
        caseSensitive: false,
      ),
      RegExp(
        '<meta[^>]+name=["\']$property["\'][^>]+content=["\']([^"\']+)["\']',
        caseSensitive: false,
      ),
      RegExp(
        '<meta[^>]+content=["\']([^"\']+)["\'][^>]+name=["\']$property["\']',
        caseSensitive: false,
      ),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(html);
      if (match != null) {
        return resolveUrl(match.group(1)!, pageUri);
      }
    }
  }
  return null;
}

String? _extractJsonLdRecipeImage(String html, Uri pageUri) {
  for (final decoded in decodeJsonLdBlocks(html)) {
    for (final recipe in findRecipeNodes(decoded)) {
      final image = imageUrlFromValue(recipe['image']);
      if (image != null) {
        return resolveUrl(image, pageUri);
      }
    }
  }
  return null;
}
