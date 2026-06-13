import 'dart:convert';

import 'package:flutter/services.dart';

import '../database/app_database.dart';

class DatabaseSeeder {
  DatabaseSeeder(this._db);

  final AppDatabase _db;

  Future<void> seedIfNeeded() async {
    if (await _db.hasCategories()) return;

    final jsonString = await rootBundle.loadString('assets/seed_catalog.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;

    final categories = (data['categories'] as List<dynamic>)
        .map((c) => c as Map<String, dynamic>);

    await _db.batch((batch) {
      for (final cat in categories) {
        batch.insert(
          _db.categories,
          CategoriesCompanion.insert(
            id: cat['id'] as String,
            name: cat['name'] as String,
            sortOrder: cat['sortOrder'] as int,
          ),
        );
      }
    });

    final items = (data['items'] as List<dynamic>)
        .map((i) => i as Map<String, dynamic>);

    final now = DateTime.now();
    await _db.batch((batch) {
      for (final item in items) {
        final displayName = item['name'] as String;
        batch.insert(
          _db.catalogItems,
          CatalogItemsCompanion.insert(
            name: displayName.toLowerCase(),
            displayName: displayName,
            categoryId: item['categoryId'] as String,
            createdAt: now,
          ),
        );
      }
    });
  }
}
