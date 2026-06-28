/// Syncable entity types exchanged via the Firestore change feed.
enum SyncEntityType {
  shoppingList('shoppingList'),
  listItem('listItem'),
  todoList('todoList'),
  todoItem('todoItem'),
  meal('meal'),
  mealIngredient('mealIngredient'),
  mealStep('mealStep'),
  mealTag('mealTag'),
  mealTagAssignment('mealTagAssignment'),
  mealPlanItem('mealPlanItem'),
  catalogItem('catalogItem'),
  catalogItemAlias('catalogItemAlias'),
  receiptList('receiptList'),
  receipt('receipt'),
  receiptLine('receiptLine'),
  takeAwayList('takeAwayList');

  const SyncEntityType(this.wireValue);

  final String wireValue;

  static SyncEntityType? fromWire(String value) {
    for (final type in SyncEntityType.values) {
      if (type.wireValue == value) return type;
    }
    return null;
  }
}
