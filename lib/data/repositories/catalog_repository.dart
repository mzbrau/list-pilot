import 'package:drift/drift.dart';

import '../database/app_database.dart';

class CatalogRepository {
  CatalogRepository(this._db);

  final AppDatabase _db;

  Future<List<CatalogItem>> search(String query, {int limit = 8}) {
    return _db.searchCatalog(query, limit: limit);
  }

  Future<CatalogItem?> findByName(String name) {
    return _db.findCatalogByName(name);
  }

  Future<CatalogItem> getOrCreate({
    required String displayName,
    required String categoryId,
    bool isUserAdded = false,
  }) async {
    final existing = await findByName(displayName);
    if (existing != null) return existing;

    final id = await _db.into(_db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            name: displayName.trim().toLowerCase(),
            displayName: displayName.trim(),
            categoryId: categoryId,
            isUserAdded: Value(isUserAdded),
            createdAt: DateTime.now(),
          ),
        );

    return (await (_db.select(_db.catalogItems)
          ..where((t) => t.id.equals(id)))
        .getSingle());
  }

  Future<void> updateCatalogItem({
    required int id,
    String? displayName,
    String? categoryId,
  }) async {
    await (_db.update(_db.catalogItems)..where((t) => t.id.equals(id))).write(
      CatalogItemsCompanion(
        name: displayName != null
            ? Value(displayName.trim().toLowerCase())
            : const Value.absent(),
        displayName:
            displayName != null ? Value(displayName.trim()) : const Value.absent(),
        categoryId:
            categoryId != null ? Value(categoryId) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteUserCatalogItem(int id) async {
    await (_db.delete(_db.catalogItems)
          ..where((t) => t.id.equals(id) & t.isUserAdded.equals(true)))
        .go();
  }

  Future<CatalogItem?> getById(int id) {
    return (_db.select(_db.catalogItems)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Category>> getCategories() => _db.getAllCategories();

  Future<List<CatalogItem>> getUserAddedItems() {
    return (_db.select(_db.catalogItems)
          ..where((t) => t.isUserAdded.equals(true)))
        .get();
  }

  Future<List<CatalogItem>> getAllCatalogItems() {
    return _db.select(_db.catalogItems).get();
  }
}
