import 'dart:io';

import 'package:path/path.dart' as p;

import '../repositories/meal_repository.dart';
import 'ingredient_catalog_matcher.dart';
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

class PaprikaImportResult {
  const PaprikaImportResult({
    required this.imported,
    required this.skipped,
    required this.failed,
    required this.errors,
  });

  final int imported;
  final int skipped;
  final int failed;
  final List<PaprikaImportFileError> errors;
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
    );
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
