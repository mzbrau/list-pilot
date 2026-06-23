import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../repositories/meal_repository.dart';

class MealExportResult {
  const MealExportResult({
    required this.filePath,
    required this.displayLocation,
    required this.mealCount,
    required this.checkOffCount,
  });

  final String filePath;
  final String displayLocation;
  final int mealCount;
  final int checkOffCount;
}

Map<String, dynamic> buildMealExportPayload(MealExportData data) {
  return {
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'meals': data.meals
        .map(
          (meal) => {
            'displayName': meal.displayName,
            if (meal.notes != null && meal.notes!.isNotEmpty)
              'notes': meal.notes,
            'portions': meal.portions,
            if (meal.prepTimeMinutes != null)
              'prepTimeMinutes': meal.prepTimeMinutes,
            if (meal.recipeLink != null && meal.recipeLink!.isNotEmpty)
              'recipeLink': meal.recipeLink,
            'ingredients': meal.ingredients
                .map(
                  (i) => {
                    'displayName': i.displayName,
                    'addToShoppingList': i.addToShoppingList,
                    if (i.quantityValue != null) 'quantityValue': i.quantityValue,
                    if (i.quantityUnit != null) 'quantityUnit': i.quantityUnit,
                    if (i.catalogItemId != null) 'catalogItemId': i.catalogItemId,
                  },
                )
                .toList(),
            if (meal.steps.isNotEmpty) 'steps': meal.steps,
            if (meal.tags.isNotEmpty) 'tags': meal.tags,
          },
        )
        .toList(),
    'checkOffHistory': data.checkOffHistory
        .map(
          (e) => {
            'displayName': e.displayName,
            'checkedAt': e.checkedAt.toUtc().toIso8601String(),
          },
        )
        .toList(),
  };
}

class MealExportService {
  MealExportService(this._meals);

  final MealRepository _meals;

  Future<MealExportResult> exportToFile() async {
    final exportData = await _meals.getAllMealsForExport();
    final payload = buildMealExportPayload(exportData);

    final date = DateTime.now().toIso8601String().split('T').first;
    final fileName = 'list-pilot-meals-export-$date';
    final contents = const JsonEncoder.withIndent('  ').convert(payload);

    final writeResult = await _writeExportFile(fileName, contents);

    return MealExportResult(
      filePath: writeResult.filePath,
      displayLocation: writeResult.displayLocation,
      mealCount: exportData.meals.length,
      checkOffCount: exportData.checkOffHistory.length,
    );
  }

  Future<({String filePath, String displayLocation})> _writeExportFile(
    String fileName,
    String contents,
  ) async {
    if (!kIsWeb && Platform.isAndroid) {
      final savedPath = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: utf8.encode(contents),
        fileExtension: 'json',
        mimeType: MimeType.json,
      );
      return (
        filePath: savedPath,
        displayLocation: 'Downloads',
      );
    }

    final directory = await _exportDirectory();
    await directory.create(recursive: true);
    final filePath = p.join(directory.path, '$fileName.json');
    await File(filePath).writeAsString(contents);

    return (filePath: filePath, displayLocation: directory.path);
  }

  Future<Directory> _exportDirectory() async {
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    } catch (_) {
      // Fall through to app documents.
    }
    return getApplicationDocumentsDirectory();
  }
}
