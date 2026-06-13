import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../repositories/catalog_repository.dart';

class CatalogExportData {
  const CatalogExportData({
    required this.customItems,
    required this.recategorizedItems,
  });

  final List<Map<String, String>> customItems;
  final List<Map<String, String>> recategorizedItems;
}

class CatalogExportResult {
  const CatalogExportResult({
    required this.filePath,
    required this.customItemCount,
    required this.recategorizedItemCount,
  });

  final String filePath;
  final int customItemCount;
  final int recategorizedItemCount;
}

CatalogExportData buildCatalogExportData({
  required List<CatalogItem> userAdded,
  required List<CatalogItem> allItems,
  required Map<String, String> seedCategoriesByName,
}) {
  final customItems = userAdded
      .map(
        (item) => {
          'displayName': item.displayName,
          'categoryId': item.categoryId,
        },
      )
      .toList();

  final recategorizedItems = <Map<String, String>>[];
  for (final item in allItems) {
    if (item.isUserAdded) continue;
    final originalCategoryId = seedCategoriesByName[item.name];
    if (originalCategoryId == null) continue;
    if (item.categoryId == originalCategoryId) continue;
    recategorizedItems.add({
      'displayName': item.displayName,
      'categoryId': item.categoryId,
      'originalCategoryId': originalCategoryId,
    });
  }

  return CatalogExportData(
    customItems: customItems,
    recategorizedItems: recategorizedItems,
  );
}

Future<Map<String, String>> loadSeedCategoryMap() async {
  final jsonString = await rootBundle.loadString('assets/seed_catalog.json');
  final data = json.decode(jsonString) as Map<String, dynamic>;
  final items =
      (data['items'] as List<dynamic>).map((i) => i as Map<String, dynamic>);

  return {
    for (final item in items)
      (item['name'] as String).toLowerCase(): item['categoryId'] as String,
  };
}

class CatalogExportService {
  CatalogExportService(this._catalog);

  final CatalogRepository _catalog;

  Future<CatalogExportResult> exportToFile() async {
    final seedCategories = await loadSeedCategoryMap();
    final userAdded = await _catalog.getUserAddedItems();
    final allItems = await _catalog.getAllCatalogItems();

    final exportData = buildCatalogExportData(
      userAdded: userAdded,
      allItems: allItems,
      seedCategoriesByName: seedCategories,
    );

    final payload = {
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'customItems': exportData.customItems,
      'recategorizedItems': exportData.recategorizedItems,
    };

    final directory = await _exportDirectory();
    final date = DateTime.now().toIso8601String().split('T').first;
    final filePath =
        p.join(directory.path, 'shop-flow-catalog-export-$date.json');
    await File(filePath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );

    return CatalogExportResult(
      filePath: filePath,
      customItemCount: exportData.customItems.length,
      recategorizedItemCount: exportData.recategorizedItems.length,
    );
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
