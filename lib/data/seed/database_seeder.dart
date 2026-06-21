import 'dart:convert';

import 'package:flutter/services.dart';

import '../database/app_database.dart';

class DatabaseSeeder {
  DatabaseSeeder(this._db);

  final AppDatabase _db;

  Future<Map<String, dynamic>> _loadSeedCatalog() async {
    final jsonString = await rootBundle.loadString('assets/seed_catalog.json');
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<void> seedIfNeeded() async {
    final hasCategories = await _db.hasCategories();
    final hasItems = await _db.hasCatalogItems();

    final data = await _loadSeedCatalog();

    final categories = (data['categories'] as List<dynamic>)
        .map((c) => c as Map<String, dynamic>);

    final items = (data['items'] as List<dynamic>)
        .map((i) => i as Map<String, dynamic>);

    final now = DateTime.now();

    if (!hasCategories || !hasItems) {
      await _db.transaction(() async {
        await _db.batch((batch) {
          if (!hasCategories) {
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
          }

          if (!hasItems) {
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
          }
        });
      });
    }

    await mergeMissingSeedItems();
  }

  Future<void> mergeMissingSeedItems() async {
    final data = await _loadSeedCatalog();
    final items = (data['items'] as List<dynamic>)
        .map((i) => i as Map<String, dynamic>);
    final now = DateTime.now();

    await _db.transaction(() async {
      for (final item in items) {
        final displayName = item['name'] as String;
        final normalized = displayName.toLowerCase();
        if (await _db.isCatalogNameExcluded(normalized)) continue;

        final existing = await _db.findCatalogByName(displayName);
        if (existing != null) continue;

        await _db.into(_db.catalogItems).insert(
              CatalogItemsCompanion.insert(
                name: normalized,
                displayName: displayName,
                categoryId: item['categoryId'] as String,
                createdAt: now,
              ),
            );
      }
    });
  }
}
