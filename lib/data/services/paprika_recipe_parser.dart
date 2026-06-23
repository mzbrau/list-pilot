import 'dart:io';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;

import 'recipe_page_extractor.dart';

class PaprikaParseException implements Exception {
  PaprikaParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PaprikaParsedRecipe {
  const PaprikaParsedRecipe({
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.tags,
    required this.portions,
    this.notes,
    this.prepTimeMinutes,
    this.recipeUrl,
    this.localImagePath,
  });

  final String name;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tags;
  final int portions;
  final String? notes;
  final int? prepTimeMinutes;
  final String? recipeUrl;
  final String? localImagePath;
}

class PaprikaRecipeParser {
  PaprikaRecipeParser({RecipePageExtractor? extractor})
      : _extractor = extractor ?? RecipePageExtractor();

  final RecipePageExtractor _extractor;

  static final _scalingArtifactPattern = RegExp(
    r'^[\d/\s.]+x\s+1x\s+2x\s+3x',
    caseSensitive: false,
  );

  Future<PaprikaParsedRecipe> parse({required File htmlFile}) async {
    final html = await htmlFile.readAsString();
    final baseUri = Uri.file(htmlFile.path);
    final extracted = _extractor.extract(html, baseUri);
    final document = html_parser.parse(html);
    final recipeRoot = _findRecipeRoot(document);

    final name = extracted?.name.trim().isNotEmpty == true
        ? extracted!.name.trim()
        : p.basenameWithoutExtension(htmlFile.path);

    final ingredients = _filterIngredients(extracted?.ingredients ?? []);
    final steps = extracted?.steps ?? [];

    if (name.isEmpty || (ingredients.isEmpty && steps.isEmpty)) {
      throw PaprikaParseException(
        'No usable recipe content in ${htmlFile.path}',
      );
    }

    final tags = recipeRoot != null
        ? _extractTags(recipeRoot)
        : const <String>[];
    final portions = recipeRoot != null
        ? parsePaprikaPortions(_microdataText(recipeRoot, 'recipeYield'))
        : 4;
    final recipeUrl = recipeRoot != null
        ? _extractRecipeUrl(recipeRoot)
        : extracted?.recipeUrl;
    final notes = recipeRoot != null
        ? _buildNotes(recipeRoot, extracted?.notes)
        : extracted?.notes;
    final localImagePath = _resolveLocalImagePath(
      recipeRoot,
      htmlFile.parent,
    );

    return PaprikaParsedRecipe(
      name: name,
      ingredients: ingredients,
      steps: steps,
      tags: tags,
      portions: portions,
      notes: notes,
      prepTimeMinutes: extracted?.prepTimeMinutes,
      recipeUrl: recipeUrl,
      localImagePath: localImagePath,
    );
  }

  static int parsePaprikaPortions(String? raw) {
    if (raw == null) return 4;
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == '–' || trimmed == '-') return 4;

    final match = RegExp(r'(\d+)').firstMatch(trimmed);
    if (match == null) return 4;

    final value = int.tryParse(match.group(1)!);
    if (value == null || value < 1) return 4;
    return value.clamp(1, 99);
  }

  static List<String> filterScalingArtifacts(List<String> ingredients) {
    return ingredients
        .where((line) => !_scalingArtifactPattern.hasMatch(line.trim()))
        .toList();
  }

  List<String> _filterIngredients(List<String> ingredients) {
    return filterScalingArtifacts(ingredients);
  }

  dom.Element? _findRecipeRoot(dom.Document document) {
    for (final element in document.querySelectorAll('[itemscope]')) {
      final type = element.attributes['itemtype'] ?? '';
      if (type.contains('schema.org/Recipe') || type.endsWith('/Recipe')) {
        return element;
      }
    }
    return null;
  }

  List<String> _extractTags(dom.Element root) {
    final tags = <String>[];
    for (final element in root.querySelectorAll('[itemprop="recipeCategory"]')) {
      final value = _elementText(element);
      if (value == null || value.isEmpty) continue;
      for (final part in value.split(',')) {
        final tag = part.trim();
        if (tag.isNotEmpty && !tags.contains(tag)) {
          tags.add(tag);
        }
      }
    }
    return tags;
  }

  String? _extractRecipeUrl(dom.Element root) {
    for (final element in root.querySelectorAll('[itemprop="url"]')) {
      final href = element.attributes['href']?.trim();
      if (href != null && href.isNotEmpty) return href;
    }
    return null;
  }

  String? _buildNotes(dom.Element root, String? extractedDescription) {
    final sections = <String>[];

    void addSection(String label, String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return;
      sections.add('$label\n$trimmed');
    }

    final description = _microdataText(root, 'description') ?? extractedDescription;
    addSection('Description', description);

    final notes = _extractNotesComment(root);
    addSection('Notes', notes);

    addSection('Difficulty', _microdataText(root, 'difficulty'));

    final nutrition = root.querySelector('.nutritionbox .nutrition');
    if (nutrition != null) {
      addSection('Nutrition', _elementText(nutrition));
    }

    final rating = _extractRating(root);
    if (rating != null) {
      addSection('Rating', rating);
    }

    if (sections.isEmpty) return null;
    return sections.join('\n\n');
  }

  String? _extractNotesComment(dom.Element root) {
    final notesBox = root.querySelector('.notesbox [itemprop="comment"]');
    return notesBox != null ? _elementText(notesBox) : null;
  }

  String? _extractRating(dom.Element root) {
    for (final element in root.querySelectorAll('[itemprop="aggregateRating"]')) {
      final valueAttr = element.attributes['value'];
      final value = double.tryParse(valueAttr ?? '') ??
          double.tryParse(_elementText(element) ?? '');
      if (value != null && value > 0) {
        return value.toString();
      }
    }
    return null;
  }

  String? _resolveLocalImagePath(dom.Element? root, Directory htmlDir) {
    if (root == null) return null;

    for (final element in root.querySelectorAll('[itemprop="image"]')) {
      final src = element.attributes['src']?.trim();
      if (src == null || src.isEmpty) continue;
      if (src.startsWith('http://') || src.startsWith('https://')) continue;

      final imageFile = File(p.normalize(p.join(htmlDir.path, src)));
      if (imageFile.existsSync()) {
        return imageFile.path;
      }
    }
    return null;
  }

  String? _microdataText(dom.Element root, String property) {
    for (final element in root.querySelectorAll('[itemprop="$property"]')) {
      final value = _elementText(element);
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String? _elementText(dom.Element? element) {
    if (element == null) return null;
    final content = element.attributes['content'];
    if (content != null && content.trim().isNotEmpty) {
      return content.trim();
    }
    final text = element.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.isEmpty ? null : text;
  }
}
