import 'dart:convert';

String? resolveUrl(String raw, Uri base) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('//')) {
    return '${base.scheme}:$trimmed';
  }
  final resolved = base.resolve(trimmed);
  if (!resolved.hasScheme || !resolved.scheme.startsWith('http')) {
    return null;
  }
  return resolved.toString();
}

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
  final pattern = RegExp(
    "<script[^>]*type=['\"]application/ld\\+json['\"][^>]*>([\\s\\S]*?)</script>",
    caseSensitive: false,
  );

  for (final match in pattern.allMatches(html)) {
    final rawJson = match.group(1)?.trim();
    if (rawJson == null || rawJson.isEmpty) continue;

    try {
      final decoded = jsonDecode(rawJson);
      final image = _recipeImageFromJsonLd(decoded);
      if (image != null) {
        return resolveUrl(image, pageUri);
      }
    } catch (_) {
      continue;
    }
  }
  return null;
}

String? _recipeImageFromJsonLd(dynamic node) {
  if (node is List) {
    for (final item in node) {
      final image = _recipeImageFromJsonLd(item);
      if (image != null) return image;
    }
    return null;
  }

  if (node is! Map) return null;

  final type = node['@type'];
  final isRecipe = type == 'Recipe' ||
      (type is List && type.any((t) => t == 'Recipe'));

  if (isRecipe) {
    return _imageUrlFromValue(node['image']);
  }

  if (node.containsKey('@graph')) {
    return _recipeImageFromJsonLd(node['@graph']);
  }

  for (final value in node.values) {
    final image = _recipeImageFromJsonLd(value);
    if (image != null) return image;
  }
  return null;
}

String? _imageUrlFromValue(dynamic value) {
  if (value is String) return value;
  if (value is List && value.isNotEmpty) {
    return _imageUrlFromValue(value.first);
  }
  if (value is Map) {
    final url = value['url'] ?? value['contentUrl'];
    if (url is String) return url;
  }
  return null;
}
