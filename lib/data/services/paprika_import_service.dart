import 'dart:io';

import 'package:path/path.dart' as p;

import '../repositories/meal_repository.dart';
import 'ingredient_catalog_matcher.dart';
import 'ingredient_parser_service.dart';
import 'meal_photo_service.dart';
import 'paprika_recipe_parser.dart';

class PaprikaImportFileError {
  const PaprikaImportFileError({
    required this.fileName,
    required this.message,
  });

  final String fileName;
  final String message;
}

/// An unmatched ingredient saved during Paprika import, awaiting review.
class PaprikaUnmatchedIngredient {
  const PaprikaUnmatchedIngredient({
    required this.mealIngredientId,
    required this.mealId,
    required this.mealName,
    required this.displayName,
    required this.matchKey,
    required this.parsed,
  });

  final int mealIngredientId;
  final int mealId;
  final String mealName;
  final String displayName;
  final String matchKey;
  final ParsedIngredientLine parsed;
}

class PaprikaImportResult {
  const PaprikaImportResult({
    required this.imported,
    required this.skipped,
    required this.failed,
    required this.errors,
    this.unmatchedIngredients = const [],
  });

  final int imported;
  final int skipped;
  final int failed;
  final List<PaprikaImportFileError> errors;
  final List<PaprikaUnmatchedIngredient> unmatchedIngredients;
}

typedef PaprikaImportProgress = void Function(int current, int total, String fileName);

class PaprikaImportService {
  PaprikaImportService({
    required MealRepository mealRepository,
    required IngredientCatalogMatcher matcher,
    required MealPhotoService photoService,
    PaprikaRecipeParser? parser,
  })  : _meals = mealRepository,
        _matcher = matcher,
        _photos = photoService,
        _parser = parser ?? PaprikaRecipeParser();

  final MealRepository _meals;
  final IngredientCatalogMatcher _matcher;
  final MealPhotoService _photos;
  final PaprikaRecipeParser _parser;

  Future<PaprikaImportResult> importFolder(
    String folderPath, {
    PaprikaImportProgress? onProgress,
  }) async {
    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw PaprikaParseException('Folder not found: $folderPath');
    }

    final htmlFiles = await _findRecipeHtmlFiles(folder);
    var imported = 0;
    var skipped = 0;
    var failed = 0;
    final errors = <PaprikaImportFileError>[];
    final unmatchedIngredients = <PaprikaUnmatchedIngredient>[];

    for (var i = 0; i < htmlFiles.length; i++) {
      final file = htmlFiles[i];
      final fileName = p.basename(file.path);
      onProgress?.call(i + 1, htmlFiles.length, fileName);

      try {
        final parsed = await _parser.parse(htmlFile: file);
        final existing = await _meals.findByName(parsed.name);
        if (existing != null) {
          skipped++;
          continue;
        }

        final drafts = await _matcher.matchAll(parsed.ingredients);
        final meal = await _meals.createMeal(
          displayName: parsed.name,
          notes: parsed.notes,
          portions: parsed.portions,
          prepTimeMinutes: parsed.prepTimeMinutes,
          recipeLink: parsed.recipeUrl,
          ingredients: drafts.map((d) => d.toInput()).toList(),
          steps: parsed.steps,
          tags: parsed.tags,
        );

        unmatchedIngredients.addAll(
          await _collectUnmatched(
            mealId: meal.id,
            mealName: meal.displayName,
            drafts: drafts,
          ),
        );

        if (parsed.localImagePath != null) {
          try {
            await _photos.savePhotoFromPath(meal.id, parsed.localImagePath!);
          } catch (_) {
            // Photo copy is best-effort; the meal is already saved.
          }
        }

        imported++;
      } on PaprikaParseException catch (e) {
        failed++;
        errors.add(PaprikaImportFileError(fileName: fileName, message: e.message));
      } catch (e) {
        failed++;
        errors.add(
          PaprikaImportFileError(
            fileName: fileName,
            message: e.toString(),
          ),
        );
      }
    }

    return PaprikaImportResult(
      imported: imported,
      skipped: skipped,
      failed: failed,
      errors: errors,
      unmatchedIngredients: unmatchedIngredients,
    );
  }

  Future<List<PaprikaUnmatchedIngredient>> _collectUnmatched({
    required int mealId,
    required String mealName,
    required List<ImportIngredientDraft> drafts,
  }) async {
    final unmatchedDrafts = drafts
        .where(
          (d) =>
              d.confidence == IngredientMatchConfidence.unmatched &&
              d.displayName.trim().isNotEmpty,
        )
        .toList();
    if (unmatchedDrafts.isEmpty) return const [];

    final saved = await _meals.getIngredientsForMeal(mealId);
    final unmatchedSaved =
        saved.where((i) => i.catalogItemId == null).toList();

    final result = <PaprikaUnmatchedIngredient>[];
    final count = unmatchedDrafts.length < unmatchedSaved.length
        ? unmatchedDrafts.length
        : unmatchedSaved.length;
    for (var i = 0; i < count; i++) {
      final draft = unmatchedDrafts[i];
      final ingredient = unmatchedSaved[i];
      result.add(
        PaprikaUnmatchedIngredient(
          mealIngredientId: ingredient.id,
          mealId: mealId,
          mealName: mealName,
          displayName: ingredient.displayName,
          matchKey: draft.matchKey,
          parsed: draft.parsed,
        ),
      );
    }
    return result;
  }

  Future<List<File>> _findRecipeHtmlFiles(Directory folder) async {
    final files = <File>[];
    await for (final entity in folder.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (!entity.path.toLowerCase().endsWith('.html')) continue;
      if (p.basename(entity.path).toLowerCase() == 'index.html') continue;
      files.add(entity);
    }
    files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    return files;
  }
}
