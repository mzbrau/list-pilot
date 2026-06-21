import 'package:drift/drift.dart';

import '../database/app_database.dart';

class CatalogAliasConflictException implements Exception {
  CatalogAliasConflictException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CatalogRepository {
  CatalogRepository(this._db);

  final AppDatabase _db;

  Future<List<CatalogItem>> search(String query, {int limit = 8}) {
    return _db.searchCatalogAndAliases(query, limit: limit);
  }

  Future<CatalogItem?> findByName(String name) {
    return _db.findCatalogByName(name);
  }

  Future<CatalogItem?> findByNameOrAlias(String name) {
    return _db.findCatalogByNameOrAlias(name);
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

  Future<void> deleteCatalogItem(int id) async {
    final item = await getById(id);
    if (item == null) return;

    await _db.transaction(() async {
      await _db.clearCatalogItemReferences(id);
      await _db.deleteCatalogItemById(id);
      if (!item.isUserAdded) {
        await _db.addCatalogExclusion(item.name);
      }
    });
  }

  Future<CatalogItem?> getById(int id) {
    return _db.getCatalogItemById(id);
  }

  Future<List<Category>> getCategories() => _db.getAllCategories();

  Future<List<CatalogItem>> getUserAddedItems() {
    return (_db.select(_db.catalogItems)
          ..where((t) => t.isUserAdded.equals(true)))
        .get();
  }

  Future<List<CatalogItem>> getAllCatalogItems() {
    return _db.getAllCatalogItemsOrdered();
  }

  Future<Map<int, int>> getAliasCountsByCatalogItemId() {
    return _db.getAliasCountsByCatalogItemId();
  }

  Future<List<CatalogItemAlias>> getAliases(int catalogItemId) {
    return _db.getAliasesForCatalogItem(catalogItemId);
  }

  Future<List<CatalogItemAlias>> getAllAliases() {
    return _db.select(_db.catalogItemAliases).get();
  }

  Future<CatalogItemAlias> addAlias({
    required int catalogItemId,
    required String alias,
  }) async {
    final normalized = alias.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw CatalogAliasConflictException('Alias cannot be empty');
    }

    final existingItem = await findByName(normalized);
    if (existingItem != null) {
      throw CatalogAliasConflictException(
        'That name is already used by "${existingItem.displayName}"',
      );
    }

    final existingAlias = await _db.findCatalogByAlias(normalized);
    if (existingAlias != null) {
      throw CatalogAliasConflictException(
        'That alias is already used by "${existingAlias.displayName}"',
      );
    }

    final id = await _db.into(_db.catalogItemAliases).insert(
          CatalogItemAliasesCompanion.insert(
            catalogItemId: catalogItemId,
            alias: normalized,
            createdAt: DateTime.now(),
          ),
        );

    return (await (_db.select(_db.catalogItemAliases)
          ..where((t) => t.id.equals(id)))
        .getSingle());
  }

  Future<void> deleteAlias(int aliasId) async {
    await (_db.delete(_db.catalogItemAliases)
          ..where((t) => t.id.equals(aliasId)))
        .go();
  }
}
