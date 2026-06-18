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

bool isRecipeType(dynamic type) {
  if (type == 'Recipe') return true;
  if (type is List) {
    return type.any((t) => t == 'Recipe');
  }
  return false;
}

List<Map<String, dynamic>> findRecipeNodes(dynamic node) {
  final results = <Map<String, dynamic>>[];
  _collectRecipeNodes(node, results);
  return results;
}

void _collectRecipeNodes(dynamic node, List<Map<String, dynamic>> results) {
  if (node is List) {
    for (final item in node) {
      _collectRecipeNodes(item, results);
    }
    return;
  }

  if (node is! Map) return;

  final map = Map<String, dynamic>.from(node);
  if (isRecipeType(map['@type'])) {
    results.add(map);
  }

  if (map.containsKey('@graph')) {
    _collectRecipeNodes(map['@graph'], results);
    return;
  }

  for (final value in map.values) {
    if (value is Map || value is List) {
      _collectRecipeNodes(value, results);
    }
  }
}

List<dynamic> decodeJsonLdBlocks(String html) {
  final pattern = RegExp(
    "<script[^>]*type=['\"]application/ld\\+json['\"][^>]*>([\\s\\S]*?)</script>",
    caseSensitive: false,
  );

  final blocks = <dynamic>[];
  for (final match in pattern.allMatches(html)) {
    final rawJson = match.group(1)?.trim();
    if (rawJson == null || rawJson.isEmpty) continue;
    try {
      blocks.add(jsonDecode(rawJson));
    } catch (_) {
      continue;
    }
  }
  return blocks;
}

String? imageUrlFromValue(dynamic value) {
  if (value is String) return value;
  if (value is List && value.isNotEmpty) {
    return imageUrlFromValue(value.first);
  }
  if (value is Map) {
    final url = value['url'] ?? value['contentUrl'];
    if (url is String) return url;
  }
  return null;
}

String normalizeIngredientLine(String raw) {
  var line = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  line = line.replaceAll(RegExp(r'^[\u2022\u2023\u25E6\u2043\u2219•\-–—]\s*'), '');
  return line;
}

String normalizeStepLine(String raw) {
  var line = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  line = line.replaceAll(RegExp(r'^\d+[\.\):\-]\s*'), '');
  line = line.replaceAll(RegExp(r'^[\u2022\u2023\u25E6\u2043\u2219•\-–—]\s*'), '');
  return line;
}

List<String> stringListFromValue(dynamic value) {
  if (value == null) return [];
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? [] : [trimmed];
  }
  if (value is List) {
    return value
        .expand((item) => stringListFromValue(item))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  if (value is Map) {
    final text = value['text'] ?? value['name'] ?? value['description'];
    if (text is String && text.trim().isNotEmpty) {
      return [text.trim()];
    }
  }
  return [];
}

List<String> ingredientsFromJsonLd(dynamic value) {
  if (value == null) return [];
  if (value is String) {
    final line = normalizeIngredientLine(value);
    return line.isEmpty ? [] : [line];
  }
  if (value is List) {
    return value
        .expand((item) => ingredientsFromJsonLd(item))
        .where((s) => s.isNotEmpty)
        .toList();
  }
  if (value is Map) {
    final name = value['name'];
    if (name is String) {
      final line = normalizeIngredientLine(name);
      return line.isEmpty ? [] : [line];
    }
    return stringListFromValue(value);
  }
  return [];
}

List<String> instructionsFromJsonLd(dynamic value) {
  if (value == null) return [];
  if (value is String) {
    final lines = value
        .split(RegExp(r'\r?\n+'))
        .map(normalizeStepLine)
        .where((s) => s.isNotEmpty);
    return lines.isEmpty
        ? (normalizeStepLine(value).isEmpty ? [] : [normalizeStepLine(value)])
        : lines.toList();
  }
  if (value is List) {
    return value
        .expand((item) => instructionsFromJsonLd(item))
        .where((s) => s.isNotEmpty)
        .toList();
  }
  if (value is Map) {
    final type = value['@type'];
    if (type == 'HowToSection' || (type is List && type.contains('HowToSection'))) {
      final items = value['itemListElement'] ?? value['hasPart'];
      return instructionsFromJsonLd(items);
    }
    if (type == 'HowToStep' || (type is List && type.contains('HowToStep'))) {
      final text = value['text'] ?? value['name'] ?? value['description'];
      if (text is String) {
        final line = normalizeStepLine(text);
        return line.isEmpty ? [] : [line];
      }
      final items = value['itemListElement'];
      if (items != null) {
        return instructionsFromJsonLd(items);
      }
    }
    final text = value['text'] ?? value['name'] ?? value['description'];
    if (text is String) {
      final line = normalizeStepLine(text);
      return line.isEmpty ? [] : [line];
    }
    final items = value['itemListElement'] ?? value['hasPart'];
    if (items != null) {
      return instructionsFromJsonLd(items);
    }
  }
  return [];
}

List<String> tagsFromJsonLd(Map<String, dynamic> recipe) {
  final tags = <String>{};
  for (final key in ['recipeCategory', 'recipeCuisine']) {
    final value = recipe[key];
    if (value is String && value.trim().isNotEmpty) {
      tags.add(value.trim());
    } else if (value is List) {
      for (final item in value) {
        if (item is String && item.trim().isNotEmpty) {
          tags.add(item.trim());
        }
      }
    }
  }
  final keywords = recipe['keywords'];
  if (keywords is String) {
    for (final part in keywords.split(RegExp(r'[,;]'))) {
      final tag = part.trim();
      if (tag.isNotEmpty) tags.add(tag);
    }
  } else if (keywords is List) {
    for (final item in keywords) {
      if (item is String && item.trim().isNotEmpty) {
        tags.add(item.trim());
      }
    }
  }
  return tags.toList();
}
