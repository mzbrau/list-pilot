import '../repositories/catalog_repository.dart';
import '../repositories/meal_repository.dart';
import 'ingredient_catalog_matcher.dart';
import 'paprika_import_service.dart';

/// Shared logic for persisting catalog links accepted during import review.
class ImportIngredientAcceptance {
  ImportIngredientAcceptance._();

  /// Creates an alias from the draft's match key when the user linked an
  /// existing catalog item (not when adding a brand-new catalog item).
  static Future<void> maybeAddAlias({
    required CatalogRepository catalog,
    required ImportIngredientDraft draft,
  }) async {
    final item = draft.catalogItem;
    if (item == null || draft.addToCatalog) return;

    final key = draft.matchKey;
    if (key.isEmpty || key == item.name) return;

    try {
      await catalog.addAlias(catalogItemId: item.id, alias: key);
    } on CatalogAliasConflictException {
      // Alias already exists or conflicts; the link is still valid.
    }
  }

  /// Runs [maybeAddAlias] (and getOrCreate for add-to-catalog) for each draft.
  static Future<List<ImportIngredientDraft>> finalizeDrafts({
    required CatalogRepository catalog,
    required List<ImportIngredientDraft> drafts,
  }) async {
    for (final draft in drafts) {
      if (draft.addToCatalog && draft.catalogItem == null) {
        final name = draft.displayName.trim();
        if (name.isEmpty) continue;
        final item = await catalog.getOrCreate(
          displayName: name,
          categoryId: draft.categoryId,
          isUserAdded: true,
        );
        draft.catalogItem = item;
        draft.displayName = item.displayName;
        draft.confidence = IngredientMatchConfidence.matched;
        continue;
      }

      if (draft.catalogItem != null &&
          draft.confidence == IngredientMatchConfidence.matched) {
        await maybeAddAlias(catalog: catalog, draft: draft);
      }
    }

    return drafts
        .where((d) => d.displayName.trim().isNotEmpty)
        .toList();
  }

  /// Groups unmatched Paprika rows by match key for a single review pass.
  static Map<String, List<PaprikaUnmatchedIngredient>> groupByMatchKey(
    List<PaprikaUnmatchedIngredient> unmatched,
  ) {
    final groups = <String, List<PaprikaUnmatchedIngredient>>{};
    for (final row in unmatched) {
      final key = row.matchKey.isNotEmpty
          ? row.matchKey
          : row.displayName.trim().toLowerCase();
      if (key.isEmpty) continue;
      groups.putIfAbsent(key, () => []).add(row);
    }
    return groups;
  }

  /// Builds one review draft per unique match key.
  static List<ImportIngredientDraft> draftsFromPaprikaGroups(
    Map<String, List<PaprikaUnmatchedIngredient>> groups,
  ) {
    return groups.entries.map((entry) {
      final first = entry.value.first;
      return ImportIngredientDraft(
        parsed: first.parsed,
        confidence: IngredientMatchConfidence.unmatched,
        displayName: first.displayName,
      );
    }).toList();
  }

  /// Links reviewed catalog items to all meal ingredients in each match-key group.
  ///
  /// Expects [reviewed] drafts already finalized by
  /// [ImportIngredientReviewSheet] (aliases / new catalog items applied).
  static Future<void> applyPaprikaReviews({
    required MealRepository meals,
    required Map<String, List<PaprikaUnmatchedIngredient>> groups,
    required List<ImportIngredientDraft> reviewed,
  }) async {
    for (final draft in reviewed) {
      final item = draft.catalogItem;
      if (item == null) continue;

      final key = draft.matchKey.isNotEmpty
          ? draft.matchKey
          : draft.displayName.trim().toLowerCase();
      final group = groups[key];
      if (group == null || group.isEmpty) continue;

      for (final row in group) {
        await meals.updateIngredient(
          id: row.mealIngredientId,
          catalogItemId: item.id,
          displayName: item.displayName,
        );
      }
    }
  }
}
