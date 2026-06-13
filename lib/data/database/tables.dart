import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CatalogItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get displayName => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  BoolColumn get isUserAdded =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class ShoppingLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastCheckOffAt => dateTime().nullable()();
  IntColumn get currentTripId => integer().withDefault(const Constant(0))();
  IntColumn get currentTripSequence =>
      integer().withDefault(const Constant(0))();
}

class ListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId => integer().references(ShoppingLists, #id)();
  IntColumn get catalogItemId =>
      integer().nullable().references(CatalogItems, #id)();
  TextColumn get displayName => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  RealColumn get quantityValue => real().nullable()();
  TextColumn get quantityUnit => text().nullable()();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get addedAt => dateTime()();
}

class CheckOffEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId => integer().references(ShoppingLists, #id)();
  IntColumn get listItemId => integer().references(ListItems, #id)();
  TextColumn get categoryId => text()();
  IntColumn get catalogItemId => integer().nullable()();
  DateTimeColumn get checkedAt => dateTime()();
  IntColumn get sequenceIndex => integer()();
  IntColumn get tripId => integer()();
  RealColumn get weight => real().withDefault(const Constant(1.0))();
}

class CategoryRankStats extends Table {
  IntColumn get listId => integer().references(ShoppingLists, #id)();
  TextColumn get categoryId => text()();
  RealColumn get medianRank => real()();
  IntColumn get sampleCount => integer()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {listId, categoryId};
}

class ItemRankStats extends Table {
  IntColumn get listId => integer().references(ShoppingLists, #id)();
  IntColumn get catalogItemId => integer()();
  TextColumn get categoryId => text()();
  RealColumn get medianRank => real()();
  IntColumn get sampleCount => integer()();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {listId, catalogItemId};
}
