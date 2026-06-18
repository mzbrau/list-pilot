import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'meal_import_service.dart';
import 'recipe_json_ld.dart';

class RecipePageExtractor {
  MealImportResult? extract(String html, Uri pageUri) {
    final strategies = [
      _extractFromJsonLd,
      _extractFromMicrodata,
      _extractFromHRecipe,
      _extractFromPluginMarkup,
    ];

    for (final strategy in strategies) {
      final result = strategy(html, pageUri);
      if (_isUsefulResult(result)) {
        return result;
      }
    }
    return null;
  }

  bool _isUsefulResult(MealImportResult? result) {
    if (result == null) return false;
    if (result.name.trim().isEmpty) return false;
    return result.ingredients.isNotEmpty || result.steps.isNotEmpty;
  }

  MealImportResult? _extractFromJsonLd(String html, Uri pageUri) {
    for (final block in decodeJsonLdBlocks(html)) {
      for (final recipe in findRecipeNodes(block)) {
        final result = _mealImportResultFromJsonLd(recipe, pageUri);
        if (_isUsefulResult(result)) {
          return result;
        }
      }
    }
    return null;
  }

  MealImportResult? _mealImportResultFromJsonLd(
    Map<String, dynamic> recipe,
    Uri pageUri,
  ) {
    final name = (recipe['name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;

    final ingredients = ingredientsFromJsonLd(recipe['recipeIngredient']);
    final steps = instructionsFromJsonLd(recipe['recipeInstructions']);
    final notes = (recipe['description'] as String?)?.trim();
    final tags = tagsFromJsonLd(recipe);

    final rawImage = imageUrlFromValue(recipe['image']);
    final imageUrl = rawImage != null ? resolveUrl(rawImage, pageUri) : null;

    final rawRecipeUrl = recipe['url'];
    final recipeUrl = rawRecipeUrl is String
        ? resolveUrl(rawRecipeUrl, pageUri) ?? rawRecipeUrl
        : null;

    return MealImportResult(
      name: name,
      ingredients: ingredients,
      steps: steps,
      notes: notes?.isEmpty == true ? null : notes,
      tags: tags,
      imageUrl: imageUrl,
      recipeUrl: recipeUrl,
    );
  }

  MealImportResult? _extractFromMicrodata(String html, Uri pageUri) {
    final document = html_parser.parse(html);
    final recipeRoot = _findMicrodataRecipeRoot(document);
    if (recipeRoot == null) return null;

    final name = _microdataText(recipeRoot, 'name');
    if (name == null || name.isEmpty) return null;

    final ingredients = _microdataList(recipeRoot, 'recipeIngredient')
        .map(normalizeIngredientLine)
        .where((s) => s.isNotEmpty)
        .toList();
    final steps = _microdataInstructions(recipeRoot)
        .map(normalizeStepLine)
        .where((s) => s.isNotEmpty)
        .toList();
    final notes = _microdataText(recipeRoot, 'description');
    final imageRaw = _microdataContent(recipeRoot, 'image');
    final imageUrl =
        imageRaw != null ? resolveUrl(imageRaw, pageUri) ?? imageRaw : null;

    return MealImportResult(
      name: name,
      ingredients: ingredients,
      steps: steps,
      notes: notes?.isEmpty == true ? null : notes,
      tags: const [],
      imageUrl: imageUrl,
      recipeUrl: null,
    );
  }

  dom.Element? _findMicrodataRecipeRoot(dom.Document document) {
    for (final element in document.querySelectorAll('[itemscope]')) {
      final type = element.attributes['itemtype'] ?? '';
      if (type.contains('schema.org/Recipe') || type.endsWith('/Recipe')) {
        return element;
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

  String? _microdataContent(dom.Element root, String property) {
    for (final element in root.querySelectorAll('[itemprop="$property"]')) {
      final content = element.attributes['content'];
      if (content != null && content.trim().isNotEmpty) {
        return content.trim();
      }
      final src = element.attributes['src'] ?? element.attributes['href'];
      if (src != null && src.trim().isNotEmpty) {
        return src.trim();
      }
      final value = _elementText(element);
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  List<String> _microdataList(dom.Element root, String property) {
    final values = <String>[];
    for (final element in root.querySelectorAll('[itemprop="$property"]')) {
      final value = _elementText(element);
      if (value != null && value.isNotEmpty) {
        values.add(value);
      }
    }
    return values;
  }

  List<String> _microdataInstructions(dom.Element root) {
    final steps = <String>[];
    for (final element
        in root.querySelectorAll('[itemprop="recipeInstructions"]')) {
      final nestedSteps =
          element.querySelectorAll('[itemprop="text"], li, p');
      if (nestedSteps.isNotEmpty) {
        for (final step in nestedSteps) {
          final value = _elementText(step);
          if (value != null && value.isNotEmpty) {
            steps.add(value);
          }
        }
      } else {
        final value = _elementText(element);
        if (value != null && value.isNotEmpty) {
          for (final line in value.split(RegExp(r'\r?\n+'))) {
            final trimmed = line.trim();
            if (trimmed.isNotEmpty) steps.add(trimmed);
          }
        }
      }
    }
    return steps;
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

  MealImportResult? _extractFromHRecipe(String html, Uri pageUri) {
    final document = html_parser.parse(html);
    final recipeRoot = document.querySelector('.h-recipe');
    if (recipeRoot == null) return null;

    final name = _classText(recipeRoot, 'p-name');
    if (name == null || name.isEmpty) return null;

    final ingredients = recipeRoot
        .querySelectorAll('.p-ingredient, .p-ingredients')
        .map((e) => _elementText(e))
        .whereType<String>()
        .map(normalizeIngredientLine)
        .where((s) => s.isNotEmpty)
        .toList();

    final steps = <String>[];
    for (final element in recipeRoot.querySelectorAll('.e-instruction')) {
      final value = _elementText(element);
      if (value != null && value.isNotEmpty) {
        steps.add(value);
      }
    }
    if (steps.isEmpty) {
      for (final element in recipeRoot.querySelectorAll('li.e-instruction, .e-instructions li')) {
        final value = _elementText(element);
        if (value != null && value.isNotEmpty) {
          steps.add(value);
        }
      }
    }

    final notes = _classText(recipeRoot, 'p-summary') ??
        _classText(recipeRoot, 'p-description');
    final imageRaw = recipeRoot.querySelector('.u-photo')?.attributes['src'];
    final imageUrl =
        imageRaw != null ? resolveUrl(imageRaw, pageUri) ?? imageRaw : null;

    return MealImportResult(
      name: name,
      ingredients: ingredients,
      steps: steps.map(normalizeStepLine).where((s) => s.isNotEmpty).toList(),
      notes: notes?.isEmpty == true ? null : notes,
      tags: const [],
      imageUrl: imageUrl,
      recipeUrl: null,
    );
  }

  String? _classText(dom.Element root, String className) {
    final element = root.querySelector('.$className');
    return element == null ? null : _elementText(element);
  }

  MealImportResult? _extractFromPluginMarkup(String html, Uri pageUri) {
    final document = html_parser.parse(html);

    final wprm = _extractFromWprm(document, pageUri);
    if (_isUsefulResult(wprm)) return wprm;

    final tasty = _extractFromTasty(document, pageUri);
    if (_isUsefulResult(tasty)) return tasty;

    final mediavine = _extractFromMediavine(document, pageUri);
    if (_isUsefulResult(mediavine)) return mediavine;

    return null;
  }

  MealImportResult? _extractFromWprm(dom.Document document, Uri pageUri) {
    final recipeRoot = document.querySelector('.wprm-recipe');
    if (recipeRoot == null) return null;

    final nameElement = recipeRoot.querySelector('.wprm-recipe-name');
    final name = nameElement != null ? _elementText(nameElement) : _elementText(recipeRoot);
    if (name == null || name.isEmpty) return null;

    final ingredients = recipeRoot
        .querySelectorAll(
          '.wprm-recipe-ingredient, .wprm-recipe-ingredients-container li',
        )
        .map(_elementText)
        .whereType<String>()
        .map(normalizeIngredientLine)
        .where((s) => s.isNotEmpty)
        .toList();

    final steps = recipeRoot
        .querySelectorAll(
          '.wprm-recipe-instruction-text, .wprm-recipe-instructions-container li',
        )
        .map(_elementText)
        .whereType<String>()
        .map(normalizeStepLine)
        .where((s) => s.isNotEmpty)
        .toList();

    final notes = _elementText(recipeRoot.querySelector('.wprm-recipe-summary'));
    final imageRaw =
        recipeRoot.querySelector('.wprm-recipe-image img')?.attributes['src'];
    final imageUrl =
        imageRaw != null ? resolveUrl(imageRaw, pageUri) ?? imageRaw : null;

    return MealImportResult(
      name: name,
      ingredients: ingredients,
      steps: steps,
      notes: notes?.isEmpty == true ? null : notes,
      tags: const [],
      imageUrl: imageUrl,
      recipeUrl: null,
    );
  }

  MealImportResult? _extractFromTasty(dom.Document document, Uri pageUri) {
    final recipeRoot = document.querySelector('.tasty-recipes');
    if (recipeRoot == null) return null;

    final name = _elementText(recipeRoot.querySelector('.tasty-recipes-title'));
    if (name == null || name.isEmpty) return null;

    final ingredients = recipeRoot
        .querySelectorAll('.tasty-recipes-ingredients li, .tasty-recipes-ingredients p')
        .map(_elementText)
        .whereType<String>()
        .map(normalizeIngredientLine)
        .where((s) => s.isNotEmpty)
        .toList();

    final steps = recipeRoot
        .querySelectorAll('.tasty-recipes-instructions li, .tasty-recipes-instructions p')
        .map(_elementText)
        .whereType<String>()
        .map(normalizeStepLine)
        .where((s) => s.isNotEmpty)
        .toList();

    final notes = _elementText(recipeRoot.querySelector('.tasty-recipes-description'));
    final imageRaw = recipeRoot.querySelector('img')?.attributes['src'];
    final imageUrl =
        imageRaw != null ? resolveUrl(imageRaw, pageUri) ?? imageRaw : null;

    return MealImportResult(
      name: name,
      ingredients: ingredients,
      steps: steps,
      notes: notes?.isEmpty == true ? null : notes,
      tags: const [],
      imageUrl: imageUrl,
      recipeUrl: null,
    );
  }

  MealImportResult? _extractFromMediavine(dom.Document document, Uri pageUri) {
    final recipeRoot = document.querySelector('.mv-create-card');
    if (recipeRoot == null) return null;

    final name = _elementText(recipeRoot.querySelector('.mv-create-title'));
    if (name == null || name.isEmpty) return null;

    final ingredients = recipeRoot
        .querySelectorAll('.mv-create-ingredients li')
        .map(_elementText)
        .whereType<String>()
        .map(normalizeIngredientLine)
        .where((s) => s.isNotEmpty)
        .toList();

    final steps = recipeRoot
        .querySelectorAll('.mv-create-instructions li')
        .map(_elementText)
        .whereType<String>()
        .map(normalizeStepLine)
        .where((s) => s.isNotEmpty)
        .toList();

    final notes = _elementText(recipeRoot.querySelector('.mv-create-description'));
    final imageRaw = recipeRoot.querySelector('img')?.attributes['src'];
    final imageUrl =
        imageRaw != null ? resolveUrl(imageRaw, pageUri) ?? imageRaw : null;

    return MealImportResult(
      name: name,
      ingredients: ingredients,
      steps: steps,
      notes: notes?.isEmpty == true ? null : notes,
      tags: const [],
      imageUrl: imageUrl,
      recipeUrl: null,
    );
  }
}
