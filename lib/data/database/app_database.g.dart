// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final int sortOrder;
  const Category(
      {required this.id, required this.name, required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Category copyWith({String? id, String? name, int? sortOrder}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required int sortOrder,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        sortOrder = Value(sortOrder);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemsTable extends CatalogItems
    with TableInfo<$CatalogItemsTable, CatalogItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isUserAddedMeta =
      const VerificationMeta('isUserAdded');
  @override
  late final GeneratedColumn<bool> isUserAdded = GeneratedColumn<bool>(
      'is_user_added', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_user_added" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, displayName, categoryId, isUserAdded, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('is_user_added')) {
      context.handle(
          _isUserAddedMeta,
          isUserAdded.isAcceptableOrUnknown(
              data['is_user_added']!, _isUserAddedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      isUserAdded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_user_added'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }
}

class CatalogItem extends DataClass implements Insertable<CatalogItem> {
  final int id;
  final String name;
  final String displayName;
  final String categoryId;
  final bool isUserAdded;
  final DateTime createdAt;
  const CatalogItem(
      {required this.id,
      required this.name,
      required this.displayName,
      required this.categoryId,
      required this.isUserAdded,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['display_name'] = Variable<String>(displayName);
    map['category_id'] = Variable<String>(categoryId);
    map['is_user_added'] = Variable<bool>(isUserAdded);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      id: Value(id),
      name: Value(name),
      displayName: Value(displayName),
      categoryId: Value(categoryId),
      isUserAdded: Value(isUserAdded),
      createdAt: Value(createdAt),
    );
  }

  factory CatalogItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      displayName: serializer.fromJson<String>(json['displayName']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      isUserAdded: serializer.fromJson<bool>(json['isUserAdded']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'displayName': serializer.toJson<String>(displayName),
      'categoryId': serializer.toJson<String>(categoryId),
      'isUserAdded': serializer.toJson<bool>(isUserAdded),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CatalogItem copyWith(
          {int? id,
          String? name,
          String? displayName,
          String? categoryId,
          bool? isUserAdded,
          DateTime? createdAt}) =>
      CatalogItem(
        id: id ?? this.id,
        name: name ?? this.name,
        displayName: displayName ?? this.displayName,
        categoryId: categoryId ?? this.categoryId,
        isUserAdded: isUserAdded ?? this.isUserAdded,
        createdAt: createdAt ?? this.createdAt,
      );
  CatalogItem copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      isUserAdded:
          data.isUserAdded.present ? data.isUserAdded.value : this.isUserAdded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('categoryId: $categoryId, ')
          ..write('isUserAdded: $isUserAdded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, displayName, categoryId, isUserAdded, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.displayName == this.displayName &&
          other.categoryId == this.categoryId &&
          other.isUserAdded == this.isUserAdded &&
          other.createdAt == this.createdAt);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> displayName;
  final Value<String> categoryId;
  final Value<bool> isUserAdded;
  final Value<DateTime> createdAt;
  const CatalogItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.displayName = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isUserAdded = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String displayName,
    required String categoryId,
    this.isUserAdded = const Value.absent(),
    required DateTime createdAt,
  })  : name = Value(name),
        displayName = Value(displayName),
        categoryId = Value(categoryId),
        createdAt = Value(createdAt);
  static Insertable<CatalogItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? displayName,
    Expression<String>? categoryId,
    Expression<bool>? isUserAdded,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
      if (categoryId != null) 'category_id': categoryId,
      if (isUserAdded != null) 'is_user_added': isUserAdded,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CatalogItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? displayName,
      Value<String>? categoryId,
      Value<bool>? isUserAdded,
      Value<DateTime>? createdAt}) {
    return CatalogItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      categoryId: categoryId ?? this.categoryId,
      isUserAdded: isUserAdded ?? this.isUserAdded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (isUserAdded.present) {
      map['is_user_added'] = Variable<bool>(isUserAdded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('categoryId: $categoryId, ')
          ..write('isUserAdded: $isUserAdded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListsTable extends ShoppingLists
    with TableInfo<$ShoppingListsTable, ShoppingList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastCheckOffAtMeta =
      const VerificationMeta('lastCheckOffAt');
  @override
  late final GeneratedColumn<DateTime> lastCheckOffAt =
      GeneratedColumn<DateTime>('last_check_off_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _currentTripIdMeta =
      const VerificationMeta('currentTripId');
  @override
  late final GeneratedColumn<int> currentTripId = GeneratedColumn<int>(
      'current_trip_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _currentTripSequenceMeta =
      const VerificationMeta('currentTripSequence');
  @override
  late final GeneratedColumn<int> currentTripSequence = GeneratedColumn<int>(
      'current_trip_sequence', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _activeShopStartedAtMeta =
      const VerificationMeta('activeShopStartedAt');
  @override
  late final GeneratedColumn<DateTime> activeShopStartedAt =
      GeneratedColumn<DateTime>('active_shop_started_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        createdAt,
        updatedAt,
        lastCheckOffAt,
        currentTripId,
        currentTripSequence,
        activeShopStartedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_lists';
  @override
  VerificationContext validateIntegrity(Insertable<ShoppingList> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_check_off_at')) {
      context.handle(
          _lastCheckOffAtMeta,
          lastCheckOffAt.isAcceptableOrUnknown(
              data['last_check_off_at']!, _lastCheckOffAtMeta));
    }
    if (data.containsKey('current_trip_id')) {
      context.handle(
          _currentTripIdMeta,
          currentTripId.isAcceptableOrUnknown(
              data['current_trip_id']!, _currentTripIdMeta));
    }
    if (data.containsKey('current_trip_sequence')) {
      context.handle(
          _currentTripSequenceMeta,
          currentTripSequence.isAcceptableOrUnknown(
              data['current_trip_sequence']!, _currentTripSequenceMeta));
    }
    if (data.containsKey('active_shop_started_at')) {
      context.handle(
          _activeShopStartedAtMeta,
          activeShopStartedAt.isAcceptableOrUnknown(
              data['active_shop_started_at']!, _activeShopStartedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingList(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      lastCheckOffAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_check_off_at']),
      currentTripId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_trip_id'])!,
      currentTripSequence: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}current_trip_sequence'])!,
      activeShopStartedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}active_shop_started_at']),
    );
  }

  @override
  $ShoppingListsTable createAlias(String alias) {
    return $ShoppingListsTable(attachedDatabase, alias);
  }
}

class ShoppingList extends DataClass implements Insertable<ShoppingList> {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastCheckOffAt;
  final int currentTripId;
  final int currentTripSequence;
  final DateTime? activeShopStartedAt;
  const ShoppingList(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt,
      this.lastCheckOffAt,
      required this.currentTripId,
      required this.currentTripSequence,
      this.activeShopStartedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastCheckOffAt != null) {
      map['last_check_off_at'] = Variable<DateTime>(lastCheckOffAt);
    }
    map['current_trip_id'] = Variable<int>(currentTripId);
    map['current_trip_sequence'] = Variable<int>(currentTripSequence);
    if (!nullToAbsent || activeShopStartedAt != null) {
      map['active_shop_started_at'] = Variable<DateTime>(activeShopStartedAt);
    }
    return map;
  }

  ShoppingListsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastCheckOffAt: lastCheckOffAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckOffAt),
      currentTripId: Value(currentTripId),
      currentTripSequence: Value(currentTripSequence),
      activeShopStartedAt: activeShopStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(activeShopStartedAt),
    );
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastCheckOffAt: serializer.fromJson<DateTime?>(json['lastCheckOffAt']),
      currentTripId: serializer.fromJson<int>(json['currentTripId']),
      currentTripSequence:
          serializer.fromJson<int>(json['currentTripSequence']),
      activeShopStartedAt:
          serializer.fromJson<DateTime?>(json['activeShopStartedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastCheckOffAt': serializer.toJson<DateTime?>(lastCheckOffAt),
      'currentTripId': serializer.toJson<int>(currentTripId),
      'currentTripSequence': serializer.toJson<int>(currentTripSequence),
      'activeShopStartedAt': serializer.toJson<DateTime?>(activeShopStartedAt),
    };
  }

  ShoppingList copyWith(
          {int? id,
          String? name,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> lastCheckOffAt = const Value.absent(),
          int? currentTripId,
          int? currentTripSequence,
          Value<DateTime?> activeShopStartedAt = const Value.absent()}) =>
      ShoppingList(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastCheckOffAt:
            lastCheckOffAt.present ? lastCheckOffAt.value : this.lastCheckOffAt,
        currentTripId: currentTripId ?? this.currentTripId,
        currentTripSequence: currentTripSequence ?? this.currentTripSequence,
        activeShopStartedAt: activeShopStartedAt.present
            ? activeShopStartedAt.value
            : this.activeShopStartedAt,
      );
  ShoppingList copyWithCompanion(ShoppingListsCompanion data) {
    return ShoppingList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastCheckOffAt: data.lastCheckOffAt.present
          ? data.lastCheckOffAt.value
          : this.lastCheckOffAt,
      currentTripId: data.currentTripId.present
          ? data.currentTripId.value
          : this.currentTripId,
      currentTripSequence: data.currentTripSequence.present
          ? data.currentTripSequence.value
          : this.currentTripSequence,
      activeShopStartedAt: data.activeShopStartedAt.present
          ? data.activeShopStartedAt.value
          : this.activeShopStartedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastCheckOffAt: $lastCheckOffAt, ')
          ..write('currentTripId: $currentTripId, ')
          ..write('currentTripSequence: $currentTripSequence, ')
          ..write('activeShopStartedAt: $activeShopStartedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt,
      lastCheckOffAt, currentTripId, currentTripSequence, activeShopStartedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingList &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastCheckOffAt == this.lastCheckOffAt &&
          other.currentTripId == this.currentTripId &&
          other.currentTripSequence == this.currentTripSequence &&
          other.activeShopStartedAt == this.activeShopStartedAt);
}

class ShoppingListsCompanion extends UpdateCompanion<ShoppingList> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastCheckOffAt;
  final Value<int> currentTripId;
  final Value<int> currentTripSequence;
  final Value<DateTime?> activeShopStartedAt;
  const ShoppingListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastCheckOffAt = const Value.absent(),
    this.currentTripId = const Value.absent(),
    this.currentTripSequence = const Value.absent(),
    this.activeShopStartedAt = const Value.absent(),
  });
  ShoppingListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastCheckOffAt = const Value.absent(),
    this.currentTripId = const Value.absent(),
    this.currentTripSequence = const Value.absent(),
    this.activeShopStartedAt = const Value.absent(),
  })  : name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ShoppingList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastCheckOffAt,
    Expression<int>? currentTripId,
    Expression<int>? currentTripSequence,
    Expression<DateTime>? activeShopStartedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastCheckOffAt != null) 'last_check_off_at': lastCheckOffAt,
      if (currentTripId != null) 'current_trip_id': currentTripId,
      if (currentTripSequence != null)
        'current_trip_sequence': currentTripSequence,
      if (activeShopStartedAt != null)
        'active_shop_started_at': activeShopStartedAt,
    });
  }

  ShoppingListsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? lastCheckOffAt,
      Value<int>? currentTripId,
      Value<int>? currentTripSequence,
      Value<DateTime?>? activeShopStartedAt}) {
    return ShoppingListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastCheckOffAt: lastCheckOffAt ?? this.lastCheckOffAt,
      currentTripId: currentTripId ?? this.currentTripId,
      currentTripSequence: currentTripSequence ?? this.currentTripSequence,
      activeShopStartedAt: activeShopStartedAt ?? this.activeShopStartedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastCheckOffAt.present) {
      map['last_check_off_at'] = Variable<DateTime>(lastCheckOffAt.value);
    }
    if (currentTripId.present) {
      map['current_trip_id'] = Variable<int>(currentTripId.value);
    }
    if (currentTripSequence.present) {
      map['current_trip_sequence'] = Variable<int>(currentTripSequence.value);
    }
    if (activeShopStartedAt.present) {
      map['active_shop_started_at'] =
          Variable<DateTime>(activeShopStartedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastCheckOffAt: $lastCheckOffAt, ')
          ..write('currentTripId: $currentTripId, ')
          ..write('currentTripSequence: $currentTripSequence, ')
          ..write('activeShopStartedAt: $activeShopStartedAt')
          ..write(')'))
        .toString();
  }
}

class $ListItemsTable extends ListItems
    with TableInfo<$ListItemsTable, ListItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
      'list_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _catalogItemIdMeta =
      const VerificationMeta('catalogItemId');
  @override
  late final GeneratedColumn<int> catalogItemId = GeneratedColumn<int>(
      'catalog_item_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityValueMeta =
      const VerificationMeta('quantityValue');
  @override
  late final GeneratedColumn<double> quantityValue = GeneratedColumn<double>(
      'quantity_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _quantityUnitMeta =
      const VerificationMeta('quantityUnit');
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
      'quantity_unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        listId,
        catalogItemId,
        displayName,
        categoryId,
        quantityValue,
        quantityUnit,
        isCompleted,
        completedAt,
        addedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_items';
  @override
  VerificationContext validateIntegrity(Insertable<ListItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('catalog_item_id')) {
      context.handle(
          _catalogItemIdMeta,
          catalogItemId.isAcceptableOrUnknown(
              data['catalog_item_id']!, _catalogItemIdMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('quantity_value')) {
      context.handle(
          _quantityValueMeta,
          quantityValue.isAcceptableOrUnknown(
              data['quantity_value']!, _quantityValueMeta));
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
          _quantityUnitMeta,
          quantityUnit.isAcceptableOrUnknown(
              data['quantity_unit']!, _quantityUnitMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_id'])!,
      catalogItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}catalog_item_id']),
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      quantityValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity_value']),
      quantityUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity_unit']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $ListItemsTable createAlias(String alias) {
    return $ListItemsTable(attachedDatabase, alias);
  }
}

class ListItem extends DataClass implements Insertable<ListItem> {
  final int id;
  final int listId;
  final int? catalogItemId;
  final String displayName;
  final String categoryId;
  final double? quantityValue;
  final String? quantityUnit;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime addedAt;
  const ListItem(
      {required this.id,
      required this.listId,
      this.catalogItemId,
      required this.displayName,
      required this.categoryId,
      this.quantityValue,
      this.quantityUnit,
      required this.isCompleted,
      this.completedAt,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    if (!nullToAbsent || catalogItemId != null) {
      map['catalog_item_id'] = Variable<int>(catalogItemId);
    }
    map['display_name'] = Variable<String>(displayName);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || quantityValue != null) {
      map['quantity_value'] = Variable<double>(quantityValue);
    }
    if (!nullToAbsent || quantityUnit != null) {
      map['quantity_unit'] = Variable<String>(quantityUnit);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  ListItemsCompanion toCompanion(bool nullToAbsent) {
    return ListItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      catalogItemId: catalogItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogItemId),
      displayName: Value(displayName),
      categoryId: Value(categoryId),
      quantityValue: quantityValue == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityValue),
      quantityUnit: quantityUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityUnit),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      addedAt: Value(addedAt),
    );
  }

  factory ListItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListItem(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      catalogItemId: serializer.fromJson<int?>(json['catalogItemId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      quantityValue: serializer.fromJson<double?>(json['quantityValue']),
      quantityUnit: serializer.fromJson<String?>(json['quantityUnit']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'catalogItemId': serializer.toJson<int?>(catalogItemId),
      'displayName': serializer.toJson<String>(displayName),
      'categoryId': serializer.toJson<String>(categoryId),
      'quantityValue': serializer.toJson<double?>(quantityValue),
      'quantityUnit': serializer.toJson<String?>(quantityUnit),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  ListItem copyWith(
          {int? id,
          int? listId,
          Value<int?> catalogItemId = const Value.absent(),
          String? displayName,
          String? categoryId,
          Value<double?> quantityValue = const Value.absent(),
          Value<String?> quantityUnit = const Value.absent(),
          bool? isCompleted,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? addedAt}) =>
      ListItem(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        catalogItemId:
            catalogItemId.present ? catalogItemId.value : this.catalogItemId,
        displayName: displayName ?? this.displayName,
        categoryId: categoryId ?? this.categoryId,
        quantityValue:
            quantityValue.present ? quantityValue.value : this.quantityValue,
        quantityUnit:
            quantityUnit.present ? quantityUnit.value : this.quantityUnit,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        addedAt: addedAt ?? this.addedAt,
      );
  ListItem copyWithCompanion(ListItemsCompanion data) {
    return ListItem(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      catalogItemId: data.catalogItemId.present
          ? data.catalogItemId.value
          : this.catalogItemId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      quantityValue: data.quantityValue.present
          ? data.quantityValue.value
          : this.quantityValue,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListItem(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('displayName: $displayName, ')
          ..write('categoryId: $categoryId, ')
          ..write('quantityValue: $quantityValue, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      listId,
      catalogItemId,
      displayName,
      categoryId,
      quantityValue,
      quantityUnit,
      isCompleted,
      completedAt,
      addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListItem &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.catalogItemId == this.catalogItemId &&
          other.displayName == this.displayName &&
          other.categoryId == this.categoryId &&
          other.quantityValue == this.quantityValue &&
          other.quantityUnit == this.quantityUnit &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.addedAt == this.addedAt);
}

class ListItemsCompanion extends UpdateCompanion<ListItem> {
  final Value<int> id;
  final Value<int> listId;
  final Value<int?> catalogItemId;
  final Value<String> displayName;
  final Value<String> categoryId;
  final Value<double?> quantityValue;
  final Value<String?> quantityUnit;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<DateTime> addedAt;
  const ListItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.catalogItemId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.quantityValue = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  ListItemsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    this.catalogItemId = const Value.absent(),
    required String displayName,
    required String categoryId,
    this.quantityValue = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime addedAt,
  })  : listId = Value(listId),
        displayName = Value(displayName),
        categoryId = Value(categoryId),
        addedAt = Value(addedAt);
  static Insertable<ListItem> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<int>? catalogItemId,
    Expression<String>? displayName,
    Expression<String>? categoryId,
    Expression<double>? quantityValue,
    Expression<String>? quantityUnit,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (catalogItemId != null) 'catalog_item_id': catalogItemId,
      if (displayName != null) 'display_name': displayName,
      if (categoryId != null) 'category_id': categoryId,
      if (quantityValue != null) 'quantity_value': quantityValue,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  ListItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? listId,
      Value<int?>? catalogItemId,
      Value<String>? displayName,
      Value<String>? categoryId,
      Value<double?>? quantityValue,
      Value<String?>? quantityUnit,
      Value<bool>? isCompleted,
      Value<DateTime?>? completedAt,
      Value<DateTime>? addedAt}) {
    return ListItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      displayName: displayName ?? this.displayName,
      categoryId: categoryId ?? this.categoryId,
      quantityValue: quantityValue ?? this.quantityValue,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (catalogItemId.present) {
      map['catalog_item_id'] = Variable<int>(catalogItemId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (quantityValue.present) {
      map['quantity_value'] = Variable<double>(quantityValue.value);
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('displayName: $displayName, ')
          ..write('categoryId: $categoryId, ')
          ..write('quantityValue: $quantityValue, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $CheckOffEventsTable extends CheckOffEvents
    with TableInfo<$CheckOffEventsTable, CheckOffEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckOffEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
      'list_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _listItemIdMeta =
      const VerificationMeta('listItemId');
  @override
  late final GeneratedColumn<int> listItemId = GeneratedColumn<int>(
      'list_item_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _catalogItemIdMeta =
      const VerificationMeta('catalogItemId');
  @override
  late final GeneratedColumn<int> catalogItemId = GeneratedColumn<int>(
      'catalog_item_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _checkedAtMeta =
      const VerificationMeta('checkedAt');
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
      'checked_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sequenceIndexMeta =
      const VerificationMeta('sequenceIndex');
  @override
  late final GeneratedColumn<int> sequenceIndex = GeneratedColumn<int>(
      'sequence_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
      'trip_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        listId,
        listItemId,
        categoryId,
        catalogItemId,
        checkedAt,
        sequenceIndex,
        tripId,
        weight
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'check_off_events';
  @override
  VerificationContext validateIntegrity(Insertable<CheckOffEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('list_item_id')) {
      context.handle(
          _listItemIdMeta,
          listItemId.isAcceptableOrUnknown(
              data['list_item_id']!, _listItemIdMeta));
    } else if (isInserting) {
      context.missing(_listItemIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('catalog_item_id')) {
      context.handle(
          _catalogItemIdMeta,
          catalogItemId.isAcceptableOrUnknown(
              data['catalog_item_id']!, _catalogItemIdMeta));
    }
    if (data.containsKey('checked_at')) {
      context.handle(_checkedAtMeta,
          checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta));
    } else if (isInserting) {
      context.missing(_checkedAtMeta);
    }
    if (data.containsKey('sequence_index')) {
      context.handle(
          _sequenceIndexMeta,
          sequenceIndex.isAcceptableOrUnknown(
              data['sequence_index']!, _sequenceIndexMeta));
    } else if (isInserting) {
      context.missing(_sequenceIndexMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CheckOffEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckOffEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_id'])!,
      listItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_item_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      catalogItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}catalog_item_id']),
      checkedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}checked_at'])!,
      sequenceIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence_index'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}trip_id'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
    );
  }

  @override
  $CheckOffEventsTable createAlias(String alias) {
    return $CheckOffEventsTable(attachedDatabase, alias);
  }
}

class CheckOffEvent extends DataClass implements Insertable<CheckOffEvent> {
  final int id;
  final int listId;
  final int listItemId;
  final String categoryId;
  final int? catalogItemId;
  final DateTime checkedAt;
  final int sequenceIndex;
  final int tripId;
  final double weight;
  const CheckOffEvent(
      {required this.id,
      required this.listId,
      required this.listItemId,
      required this.categoryId,
      this.catalogItemId,
      required this.checkedAt,
      required this.sequenceIndex,
      required this.tripId,
      required this.weight});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['list_item_id'] = Variable<int>(listItemId);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || catalogItemId != null) {
      map['catalog_item_id'] = Variable<int>(catalogItemId);
    }
    map['checked_at'] = Variable<DateTime>(checkedAt);
    map['sequence_index'] = Variable<int>(sequenceIndex);
    map['trip_id'] = Variable<int>(tripId);
    map['weight'] = Variable<double>(weight);
    return map;
  }

  CheckOffEventsCompanion toCompanion(bool nullToAbsent) {
    return CheckOffEventsCompanion(
      id: Value(id),
      listId: Value(listId),
      listItemId: Value(listItemId),
      categoryId: Value(categoryId),
      catalogItemId: catalogItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogItemId),
      checkedAt: Value(checkedAt),
      sequenceIndex: Value(sequenceIndex),
      tripId: Value(tripId),
      weight: Value(weight),
    );
  }

  factory CheckOffEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckOffEvent(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      listItemId: serializer.fromJson<int>(json['listItemId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      catalogItemId: serializer.fromJson<int?>(json['catalogItemId']),
      checkedAt: serializer.fromJson<DateTime>(json['checkedAt']),
      sequenceIndex: serializer.fromJson<int>(json['sequenceIndex']),
      tripId: serializer.fromJson<int>(json['tripId']),
      weight: serializer.fromJson<double>(json['weight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'listItemId': serializer.toJson<int>(listItemId),
      'categoryId': serializer.toJson<String>(categoryId),
      'catalogItemId': serializer.toJson<int?>(catalogItemId),
      'checkedAt': serializer.toJson<DateTime>(checkedAt),
      'sequenceIndex': serializer.toJson<int>(sequenceIndex),
      'tripId': serializer.toJson<int>(tripId),
      'weight': serializer.toJson<double>(weight),
    };
  }

  CheckOffEvent copyWith(
          {int? id,
          int? listId,
          int? listItemId,
          String? categoryId,
          Value<int?> catalogItemId = const Value.absent(),
          DateTime? checkedAt,
          int? sequenceIndex,
          int? tripId,
          double? weight}) =>
      CheckOffEvent(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        listItemId: listItemId ?? this.listItemId,
        categoryId: categoryId ?? this.categoryId,
        catalogItemId:
            catalogItemId.present ? catalogItemId.value : this.catalogItemId,
        checkedAt: checkedAt ?? this.checkedAt,
        sequenceIndex: sequenceIndex ?? this.sequenceIndex,
        tripId: tripId ?? this.tripId,
        weight: weight ?? this.weight,
      );
  CheckOffEvent copyWithCompanion(CheckOffEventsCompanion data) {
    return CheckOffEvent(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      listItemId:
          data.listItemId.present ? data.listItemId.value : this.listItemId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      catalogItemId: data.catalogItemId.present
          ? data.catalogItemId.value
          : this.catalogItemId,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
      sequenceIndex: data.sequenceIndex.present
          ? data.sequenceIndex.value
          : this.sequenceIndex,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      weight: data.weight.present ? data.weight.value : this.weight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckOffEvent(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('listItemId: $listItemId, ')
          ..write('categoryId: $categoryId, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('tripId: $tripId, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listId, listItemId, categoryId,
      catalogItemId, checkedAt, sequenceIndex, tripId, weight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckOffEvent &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.listItemId == this.listItemId &&
          other.categoryId == this.categoryId &&
          other.catalogItemId == this.catalogItemId &&
          other.checkedAt == this.checkedAt &&
          other.sequenceIndex == this.sequenceIndex &&
          other.tripId == this.tripId &&
          other.weight == this.weight);
}

class CheckOffEventsCompanion extends UpdateCompanion<CheckOffEvent> {
  final Value<int> id;
  final Value<int> listId;
  final Value<int> listItemId;
  final Value<String> categoryId;
  final Value<int?> catalogItemId;
  final Value<DateTime> checkedAt;
  final Value<int> sequenceIndex;
  final Value<int> tripId;
  final Value<double> weight;
  const CheckOffEventsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.listItemId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.catalogItemId = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.sequenceIndex = const Value.absent(),
    this.tripId = const Value.absent(),
    this.weight = const Value.absent(),
  });
  CheckOffEventsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required int listItemId,
    required String categoryId,
    this.catalogItemId = const Value.absent(),
    required DateTime checkedAt,
    required int sequenceIndex,
    required int tripId,
    this.weight = const Value.absent(),
  })  : listId = Value(listId),
        listItemId = Value(listItemId),
        categoryId = Value(categoryId),
        checkedAt = Value(checkedAt),
        sequenceIndex = Value(sequenceIndex),
        tripId = Value(tripId);
  static Insertable<CheckOffEvent> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<int>? listItemId,
    Expression<String>? categoryId,
    Expression<int>? catalogItemId,
    Expression<DateTime>? checkedAt,
    Expression<int>? sequenceIndex,
    Expression<int>? tripId,
    Expression<double>? weight,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (listItemId != null) 'list_item_id': listItemId,
      if (categoryId != null) 'category_id': categoryId,
      if (catalogItemId != null) 'catalog_item_id': catalogItemId,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (sequenceIndex != null) 'sequence_index': sequenceIndex,
      if (tripId != null) 'trip_id': tripId,
      if (weight != null) 'weight': weight,
    });
  }

  CheckOffEventsCompanion copyWith(
      {Value<int>? id,
      Value<int>? listId,
      Value<int>? listItemId,
      Value<String>? categoryId,
      Value<int?>? catalogItemId,
      Value<DateTime>? checkedAt,
      Value<int>? sequenceIndex,
      Value<int>? tripId,
      Value<double>? weight}) {
    return CheckOffEventsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      listItemId: listItemId ?? this.listItemId,
      categoryId: categoryId ?? this.categoryId,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      checkedAt: checkedAt ?? this.checkedAt,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      tripId: tripId ?? this.tripId,
      weight: weight ?? this.weight,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (listItemId.present) {
      map['list_item_id'] = Variable<int>(listItemId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (catalogItemId.present) {
      map['catalog_item_id'] = Variable<int>(catalogItemId.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    if (sequenceIndex.present) {
      map['sequence_index'] = Variable<int>(sequenceIndex.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckOffEventsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('listItemId: $listItemId, ')
          ..write('categoryId: $categoryId, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('tripId: $tripId, ')
          ..write('weight: $weight')
          ..write(')'))
        .toString();
  }
}

class $CategoryRankStatsTable extends CategoryRankStats
    with TableInfo<$CategoryRankStatsTable, CategoryRankStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRankStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
      'list_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _medianRankMeta =
      const VerificationMeta('medianRank');
  @override
  late final GeneratedColumn<double> medianRank = GeneratedColumn<double>(
      'median_rank', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sampleCountMeta =
      const VerificationMeta('sampleCount');
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
      'sample_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [listId, categoryId, medianRank, sampleCount, lastUpdated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_rank_stats';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryRankStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('median_rank')) {
      context.handle(
          _medianRankMeta,
          medianRank.isAcceptableOrUnknown(
              data['median_rank']!, _medianRankMeta));
    } else if (isInserting) {
      context.missing(_medianRankMeta);
    }
    if (data.containsKey('sample_count')) {
      context.handle(
          _sampleCountMeta,
          sampleCount.isAcceptableOrUnknown(
              data['sample_count']!, _sampleCountMeta));
    } else if (isInserting) {
      context.missing(_sampleCountMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {listId, categoryId};
  @override
  CategoryRankStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRankStat(
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      medianRank: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}median_rank'])!,
      sampleCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sample_count'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
    );
  }

  @override
  $CategoryRankStatsTable createAlias(String alias) {
    return $CategoryRankStatsTable(attachedDatabase, alias);
  }
}

class CategoryRankStat extends DataClass
    implements Insertable<CategoryRankStat> {
  final int listId;
  final String categoryId;
  final double medianRank;
  final int sampleCount;
  final DateTime lastUpdated;
  const CategoryRankStat(
      {required this.listId,
      required this.categoryId,
      required this.medianRank,
      required this.sampleCount,
      required this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['list_id'] = Variable<int>(listId);
    map['category_id'] = Variable<String>(categoryId);
    map['median_rank'] = Variable<double>(medianRank);
    map['sample_count'] = Variable<int>(sampleCount);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  CategoryRankStatsCompanion toCompanion(bool nullToAbsent) {
    return CategoryRankStatsCompanion(
      listId: Value(listId),
      categoryId: Value(categoryId),
      medianRank: Value(medianRank),
      sampleCount: Value(sampleCount),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory CategoryRankStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRankStat(
      listId: serializer.fromJson<int>(json['listId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      medianRank: serializer.fromJson<double>(json['medianRank']),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'listId': serializer.toJson<int>(listId),
      'categoryId': serializer.toJson<String>(categoryId),
      'medianRank': serializer.toJson<double>(medianRank),
      'sampleCount': serializer.toJson<int>(sampleCount),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  CategoryRankStat copyWith(
          {int? listId,
          String? categoryId,
          double? medianRank,
          int? sampleCount,
          DateTime? lastUpdated}) =>
      CategoryRankStat(
        listId: listId ?? this.listId,
        categoryId: categoryId ?? this.categoryId,
        medianRank: medianRank ?? this.medianRank,
        sampleCount: sampleCount ?? this.sampleCount,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
  CategoryRankStat copyWithCompanion(CategoryRankStatsCompanion data) {
    return CategoryRankStat(
      listId: data.listId.present ? data.listId.value : this.listId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      medianRank:
          data.medianRank.present ? data.medianRank.value : this.medianRank,
      sampleCount:
          data.sampleCount.present ? data.sampleCount.value : this.sampleCount,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRankStat(')
          ..write('listId: $listId, ')
          ..write('categoryId: $categoryId, ')
          ..write('medianRank: $medianRank, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(listId, categoryId, medianRank, sampleCount, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRankStat &&
          other.listId == this.listId &&
          other.categoryId == this.categoryId &&
          other.medianRank == this.medianRank &&
          other.sampleCount == this.sampleCount &&
          other.lastUpdated == this.lastUpdated);
}

class CategoryRankStatsCompanion extends UpdateCompanion<CategoryRankStat> {
  final Value<int> listId;
  final Value<String> categoryId;
  final Value<double> medianRank;
  final Value<int> sampleCount;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const CategoryRankStatsCompanion({
    this.listId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.medianRank = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryRankStatsCompanion.insert({
    required int listId,
    required String categoryId,
    required double medianRank,
    required int sampleCount,
    required DateTime lastUpdated,
    this.rowid = const Value.absent(),
  })  : listId = Value(listId),
        categoryId = Value(categoryId),
        medianRank = Value(medianRank),
        sampleCount = Value(sampleCount),
        lastUpdated = Value(lastUpdated);
  static Insertable<CategoryRankStat> custom({
    Expression<int>? listId,
    Expression<String>? categoryId,
    Expression<double>? medianRank,
    Expression<int>? sampleCount,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (listId != null) 'list_id': listId,
      if (categoryId != null) 'category_id': categoryId,
      if (medianRank != null) 'median_rank': medianRank,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryRankStatsCompanion copyWith(
      {Value<int>? listId,
      Value<String>? categoryId,
      Value<double>? medianRank,
      Value<int>? sampleCount,
      Value<DateTime>? lastUpdated,
      Value<int>? rowid}) {
    return CategoryRankStatsCompanion(
      listId: listId ?? this.listId,
      categoryId: categoryId ?? this.categoryId,
      medianRank: medianRank ?? this.medianRank,
      sampleCount: sampleCount ?? this.sampleCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (medianRank.present) {
      map['median_rank'] = Variable<double>(medianRank.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRankStatsCompanion(')
          ..write('listId: $listId, ')
          ..write('categoryId: $categoryId, ')
          ..write('medianRank: $medianRank, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemRankStatsTable extends ItemRankStats
    with TableInfo<$ItemRankStatsTable, ItemRankStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemRankStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
      'list_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _catalogItemIdMeta =
      const VerificationMeta('catalogItemId');
  @override
  late final GeneratedColumn<int> catalogItemId = GeneratedColumn<int>(
      'catalog_item_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _medianRankMeta =
      const VerificationMeta('medianRank');
  @override
  late final GeneratedColumn<double> medianRank = GeneratedColumn<double>(
      'median_rank', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sampleCountMeta =
      const VerificationMeta('sampleCount');
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
      'sample_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [listId, catalogItemId, categoryId, medianRank, sampleCount, lastUpdated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_rank_stats';
  @override
  VerificationContext validateIntegrity(Insertable<ItemRankStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('catalog_item_id')) {
      context.handle(
          _catalogItemIdMeta,
          catalogItemId.isAcceptableOrUnknown(
              data['catalog_item_id']!, _catalogItemIdMeta));
    } else if (isInserting) {
      context.missing(_catalogItemIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('median_rank')) {
      context.handle(
          _medianRankMeta,
          medianRank.isAcceptableOrUnknown(
              data['median_rank']!, _medianRankMeta));
    } else if (isInserting) {
      context.missing(_medianRankMeta);
    }
    if (data.containsKey('sample_count')) {
      context.handle(
          _sampleCountMeta,
          sampleCount.isAcceptableOrUnknown(
              data['sample_count']!, _sampleCountMeta));
    } else if (isInserting) {
      context.missing(_sampleCountMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {listId, catalogItemId};
  @override
  ItemRankStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRankStat(
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_id'])!,
      catalogItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}catalog_item_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      medianRank: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}median_rank'])!,
      sampleCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sample_count'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
    );
  }

  @override
  $ItemRankStatsTable createAlias(String alias) {
    return $ItemRankStatsTable(attachedDatabase, alias);
  }
}

class ItemRankStat extends DataClass implements Insertable<ItemRankStat> {
  final int listId;
  final int catalogItemId;
  final String categoryId;
  final double medianRank;
  final int sampleCount;
  final DateTime lastUpdated;
  const ItemRankStat(
      {required this.listId,
      required this.catalogItemId,
      required this.categoryId,
      required this.medianRank,
      required this.sampleCount,
      required this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['list_id'] = Variable<int>(listId);
    map['catalog_item_id'] = Variable<int>(catalogItemId);
    map['category_id'] = Variable<String>(categoryId);
    map['median_rank'] = Variable<double>(medianRank);
    map['sample_count'] = Variable<int>(sampleCount);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  ItemRankStatsCompanion toCompanion(bool nullToAbsent) {
    return ItemRankStatsCompanion(
      listId: Value(listId),
      catalogItemId: Value(catalogItemId),
      categoryId: Value(categoryId),
      medianRank: Value(medianRank),
      sampleCount: Value(sampleCount),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory ItemRankStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRankStat(
      listId: serializer.fromJson<int>(json['listId']),
      catalogItemId: serializer.fromJson<int>(json['catalogItemId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      medianRank: serializer.fromJson<double>(json['medianRank']),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'listId': serializer.toJson<int>(listId),
      'catalogItemId': serializer.toJson<int>(catalogItemId),
      'categoryId': serializer.toJson<String>(categoryId),
      'medianRank': serializer.toJson<double>(medianRank),
      'sampleCount': serializer.toJson<int>(sampleCount),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  ItemRankStat copyWith(
          {int? listId,
          int? catalogItemId,
          String? categoryId,
          double? medianRank,
          int? sampleCount,
          DateTime? lastUpdated}) =>
      ItemRankStat(
        listId: listId ?? this.listId,
        catalogItemId: catalogItemId ?? this.catalogItemId,
        categoryId: categoryId ?? this.categoryId,
        medianRank: medianRank ?? this.medianRank,
        sampleCount: sampleCount ?? this.sampleCount,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
  ItemRankStat copyWithCompanion(ItemRankStatsCompanion data) {
    return ItemRankStat(
      listId: data.listId.present ? data.listId.value : this.listId,
      catalogItemId: data.catalogItemId.present
          ? data.catalogItemId.value
          : this.catalogItemId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      medianRank:
          data.medianRank.present ? data.medianRank.value : this.medianRank,
      sampleCount:
          data.sampleCount.present ? data.sampleCount.value : this.sampleCount,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRankStat(')
          ..write('listId: $listId, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('categoryId: $categoryId, ')
          ..write('medianRank: $medianRank, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      listId, catalogItemId, categoryId, medianRank, sampleCount, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRankStat &&
          other.listId == this.listId &&
          other.catalogItemId == this.catalogItemId &&
          other.categoryId == this.categoryId &&
          other.medianRank == this.medianRank &&
          other.sampleCount == this.sampleCount &&
          other.lastUpdated == this.lastUpdated);
}

class ItemRankStatsCompanion extends UpdateCompanion<ItemRankStat> {
  final Value<int> listId;
  final Value<int> catalogItemId;
  final Value<String> categoryId;
  final Value<double> medianRank;
  final Value<int> sampleCount;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const ItemRankStatsCompanion({
    this.listId = const Value.absent(),
    this.catalogItemId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.medianRank = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemRankStatsCompanion.insert({
    required int listId,
    required int catalogItemId,
    required String categoryId,
    required double medianRank,
    required int sampleCount,
    required DateTime lastUpdated,
    this.rowid = const Value.absent(),
  })  : listId = Value(listId),
        catalogItemId = Value(catalogItemId),
        categoryId = Value(categoryId),
        medianRank = Value(medianRank),
        sampleCount = Value(sampleCount),
        lastUpdated = Value(lastUpdated);
  static Insertable<ItemRankStat> custom({
    Expression<int>? listId,
    Expression<int>? catalogItemId,
    Expression<String>? categoryId,
    Expression<double>? medianRank,
    Expression<int>? sampleCount,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (listId != null) 'list_id': listId,
      if (catalogItemId != null) 'catalog_item_id': catalogItemId,
      if (categoryId != null) 'category_id': categoryId,
      if (medianRank != null) 'median_rank': medianRank,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemRankStatsCompanion copyWith(
      {Value<int>? listId,
      Value<int>? catalogItemId,
      Value<String>? categoryId,
      Value<double>? medianRank,
      Value<int>? sampleCount,
      Value<DateTime>? lastUpdated,
      Value<int>? rowid}) {
    return ItemRankStatsCompanion(
      listId: listId ?? this.listId,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      categoryId: categoryId ?? this.categoryId,
      medianRank: medianRank ?? this.medianRank,
      sampleCount: sampleCount ?? this.sampleCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (catalogItemId.present) {
      map['catalog_item_id'] = Variable<int>(catalogItemId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (medianRank.present) {
      map['median_rank'] = Variable<double>(medianRank.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemRankStatsCompanion(')
          ..write('listId: $listId, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('categoryId: $categoryId, ')
          ..write('medianRank: $medianRank, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShopStatsRecordsTable extends ShopStatsRecords
    with TableInfo<$ShopStatsRecordsTable, ShopStatsRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopStatsRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
      'list_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _itemCountMeta =
      const VerificationMeta('itemCount');
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
      'item_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, listId, startedAt, completedAt, itemCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shop_stats_records';
  @override
  VerificationContext validateIntegrity(Insertable<ShopStatsRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('item_count')) {
      context.handle(_itemCountMeta,
          itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta));
    } else if (isInserting) {
      context.missing(_itemCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShopStatsRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopStatsRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      itemCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_count'])!,
    );
  }

  @override
  $ShopStatsRecordsTable createAlias(String alias) {
    return $ShopStatsRecordsTable(attachedDatabase, alias);
  }
}

class ShopStatsRecord extends DataClass implements Insertable<ShopStatsRecord> {
  final int id;
  final int listId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int itemCount;
  const ShopStatsRecord(
      {required this.id,
      required this.listId,
      required this.startedAt,
      required this.completedAt,
      required this.itemCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['item_count'] = Variable<int>(itemCount);
    return map;
  }

  ShopStatsRecordsCompanion toCompanion(bool nullToAbsent) {
    return ShopStatsRecordsCompanion(
      id: Value(id),
      listId: Value(listId),
      startedAt: Value(startedAt),
      completedAt: Value(completedAt),
      itemCount: Value(itemCount),
    );
  }

  factory ShopStatsRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopStatsRecord(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'itemCount': serializer.toJson<int>(itemCount),
    };
  }

  ShopStatsRecord copyWith(
          {int? id,
          int? listId,
          DateTime? startedAt,
          DateTime? completedAt,
          int? itemCount}) =>
      ShopStatsRecord(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        itemCount: itemCount ?? this.itemCount,
      );
  ShopStatsRecord copyWithCompanion(ShopStatsRecordsCompanion data) {
    return ShopStatsRecord(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopStatsRecord(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('itemCount: $itemCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, listId, startedAt, completedAt, itemCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopStatsRecord &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.itemCount == this.itemCount);
}

class ShopStatsRecordsCompanion extends UpdateCompanion<ShopStatsRecord> {
  final Value<int> id;
  final Value<int> listId;
  final Value<DateTime> startedAt;
  final Value<DateTime> completedAt;
  final Value<int> itemCount;
  const ShopStatsRecordsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.itemCount = const Value.absent(),
  });
  ShopStatsRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required DateTime startedAt,
    required DateTime completedAt,
    required int itemCount,
  })  : listId = Value(listId),
        startedAt = Value(startedAt),
        completedAt = Value(completedAt),
        itemCount = Value(itemCount);
  static Insertable<ShopStatsRecord> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? itemCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (itemCount != null) 'item_count': itemCount,
    });
  }

  ShopStatsRecordsCompanion copyWith(
      {Value<int>? id,
      Value<int>? listId,
      Value<DateTime>? startedAt,
      Value<DateTime>? completedAt,
      Value<int>? itemCount}) {
    return ShopStatsRecordsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopStatsRecordsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('itemCount: $itemCount')
          ..write(')'))
        .toString();
  }
}

class $MealsTable extends Meals with TableInfo<$MealsTable, Meal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _portionsMeta =
      const VerificationMeta('portions');
  @override
  late final GeneratedColumn<int> portions = GeneratedColumn<int>(
      'portions', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(4));
  static const VerificationMeta _recipeLinkMeta =
      const VerificationMeta('recipeLink');
  @override
  late final GeneratedColumn<String> recipeLink = GeneratedColumn<String>(
      'recipe_link', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isUserAddedMeta =
      const VerificationMeta('isUserAdded');
  @override
  late final GeneratedColumn<bool> isUserAdded = GeneratedColumn<bool>(
      'is_user_added', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_user_added" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        displayName,
        photoPath,
        notes,
        portions,
        recipeLink,
        isUserAdded,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meals';
  @override
  VerificationContext validateIntegrity(Insertable<Meal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('portions')) {
      context.handle(_portionsMeta,
          portions.isAcceptableOrUnknown(data['portions']!, _portionsMeta));
    }
    if (data.containsKey('recipe_link')) {
      context.handle(
          _recipeLinkMeta,
          recipeLink.isAcceptableOrUnknown(
              data['recipe_link']!, _recipeLinkMeta));
    }
    if (data.containsKey('is_user_added')) {
      context.handle(
          _isUserAddedMeta,
          isUserAdded.isAcceptableOrUnknown(
              data['is_user_added']!, _isUserAddedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      portions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}portions'])!,
      recipeLink: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_link']),
      isUserAdded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_user_added'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MealsTable createAlias(String alias) {
    return $MealsTable(attachedDatabase, alias);
  }
}

class Meal extends DataClass implements Insertable<Meal> {
  final int id;
  final String name;
  final String displayName;
  final String? photoPath;
  final String? notes;
  final int portions;
  final String? recipeLink;
  final bool isUserAdded;
  final DateTime createdAt;
  const Meal(
      {required this.id,
      required this.name,
      required this.displayName,
      this.photoPath,
      this.notes,
      required this.portions,
      this.recipeLink,
      required this.isUserAdded,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['portions'] = Variable<int>(portions);
    if (!nullToAbsent || recipeLink != null) {
      map['recipe_link'] = Variable<String>(recipeLink);
    }
    map['is_user_added'] = Variable<bool>(isUserAdded);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MealsCompanion toCompanion(bool nullToAbsent) {
    return MealsCompanion(
      id: Value(id),
      name: Value(name),
      displayName: Value(displayName),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      portions: Value(portions),
      recipeLink: recipeLink == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeLink),
      isUserAdded: Value(isUserAdded),
      createdAt: Value(createdAt),
    );
  }

  factory Meal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meal(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      displayName: serializer.fromJson<String>(json['displayName']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      notes: serializer.fromJson<String?>(json['notes']),
      portions: serializer.fromJson<int>(json['portions']),
      recipeLink: serializer.fromJson<String?>(json['recipeLink']),
      isUserAdded: serializer.fromJson<bool>(json['isUserAdded']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'displayName': serializer.toJson<String>(displayName),
      'photoPath': serializer.toJson<String?>(photoPath),
      'notes': serializer.toJson<String?>(notes),
      'portions': serializer.toJson<int>(portions),
      'recipeLink': serializer.toJson<String?>(recipeLink),
      'isUserAdded': serializer.toJson<bool>(isUserAdded),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Meal copyWith(
          {int? id,
          String? name,
          String? displayName,
          Value<String?> photoPath = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          int? portions,
          Value<String?> recipeLink = const Value.absent(),
          bool? isUserAdded,
          DateTime? createdAt}) =>
      Meal(
        id: id ?? this.id,
        name: name ?? this.name,
        displayName: displayName ?? this.displayName,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        notes: notes.present ? notes.value : this.notes,
        portions: portions ?? this.portions,
        recipeLink: recipeLink.present ? recipeLink.value : this.recipeLink,
        isUserAdded: isUserAdded ?? this.isUserAdded,
        createdAt: createdAt ?? this.createdAt,
      );
  Meal copyWithCompanion(MealsCompanion data) {
    return Meal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      portions: data.portions.present ? data.portions.value : this.portions,
      recipeLink:
          data.recipeLink.present ? data.recipeLink.value : this.recipeLink,
      isUserAdded:
          data.isUserAdded.present ? data.isUserAdded.value : this.isUserAdded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('photoPath: $photoPath, ')
          ..write('notes: $notes, ')
          ..write('portions: $portions, ')
          ..write('recipeLink: $recipeLink, ')
          ..write('isUserAdded: $isUserAdded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, displayName, photoPath, notes,
      portions, recipeLink, isUserAdded, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meal &&
          other.id == this.id &&
          other.name == this.name &&
          other.displayName == this.displayName &&
          other.photoPath == this.photoPath &&
          other.notes == this.notes &&
          other.portions == this.portions &&
          other.recipeLink == this.recipeLink &&
          other.isUserAdded == this.isUserAdded &&
          other.createdAt == this.createdAt);
}

class MealsCompanion extends UpdateCompanion<Meal> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> displayName;
  final Value<String?> photoPath;
  final Value<String?> notes;
  final Value<int> portions;
  final Value<String?> recipeLink;
  final Value<bool> isUserAdded;
  final Value<DateTime> createdAt;
  const MealsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.displayName = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.portions = const Value.absent(),
    this.recipeLink = const Value.absent(),
    this.isUserAdded = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MealsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String displayName,
    this.photoPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.portions = const Value.absent(),
    this.recipeLink = const Value.absent(),
    this.isUserAdded = const Value.absent(),
    required DateTime createdAt,
  })  : name = Value(name),
        displayName = Value(displayName),
        createdAt = Value(createdAt);
  static Insertable<Meal> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? displayName,
    Expression<String>? photoPath,
    Expression<String>? notes,
    Expression<int>? portions,
    Expression<String>? recipeLink,
    Expression<bool>? isUserAdded,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
      if (photoPath != null) 'photo_path': photoPath,
      if (notes != null) 'notes': notes,
      if (portions != null) 'portions': portions,
      if (recipeLink != null) 'recipe_link': recipeLink,
      if (isUserAdded != null) 'is_user_added': isUserAdded,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MealsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? displayName,
      Value<String?>? photoPath,
      Value<String?>? notes,
      Value<int>? portions,
      Value<String?>? recipeLink,
      Value<bool>? isUserAdded,
      Value<DateTime>? createdAt}) {
    return MealsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      portions: portions ?? this.portions,
      recipeLink: recipeLink ?? this.recipeLink,
      isUserAdded: isUserAdded ?? this.isUserAdded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (portions.present) {
      map['portions'] = Variable<int>(portions.value);
    }
    if (recipeLink.present) {
      map['recipe_link'] = Variable<String>(recipeLink.value);
    }
    if (isUserAdded.present) {
      map['is_user_added'] = Variable<bool>(isUserAdded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('photoPath: $photoPath, ')
          ..write('notes: $notes, ')
          ..write('portions: $portions, ')
          ..write('recipeLink: $recipeLink, ')
          ..write('isUserAdded: $isUserAdded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MealPlanItemsTable extends MealPlanItems
    with TableInfo<$MealPlanItemsTable, MealPlanItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealPlanItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<int> mealId = GeneratedColumn<int>(
      'meal_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, mealId, isCompleted, completedAt, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_plan_items';
  @override
  VerificationContext validateIntegrity(Insertable<MealPlanItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meal_id')) {
      context.handle(_mealIdMeta,
          mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta));
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealPlanItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealPlanItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mealId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meal_id'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $MealPlanItemsTable createAlias(String alias) {
    return $MealPlanItemsTable(attachedDatabase, alias);
  }
}

class MealPlanItem extends DataClass implements Insertable<MealPlanItem> {
  final int id;
  final int mealId;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime addedAt;
  const MealPlanItem(
      {required this.id,
      required this.mealId,
      required this.isCompleted,
      this.completedAt,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meal_id'] = Variable<int>(mealId);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  MealPlanItemsCompanion toCompanion(bool nullToAbsent) {
    return MealPlanItemsCompanion(
      id: Value(id),
      mealId: Value(mealId),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      addedAt: Value(addedAt),
    );
  }

  factory MealPlanItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealPlanItem(
      id: serializer.fromJson<int>(json['id']),
      mealId: serializer.fromJson<int>(json['mealId']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealId': serializer.toJson<int>(mealId),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  MealPlanItem copyWith(
          {int? id,
          int? mealId,
          bool? isCompleted,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? addedAt}) =>
      MealPlanItem(
        id: id ?? this.id,
        mealId: mealId ?? this.mealId,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        addedAt: addedAt ?? this.addedAt,
      );
  MealPlanItem copyWithCompanion(MealPlanItemsCompanion data) {
    return MealPlanItem(
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealPlanItem(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mealId, isCompleted, completedAt, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealPlanItem &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.addedAt == this.addedAt);
}

class MealPlanItemsCompanion extends UpdateCompanion<MealPlanItem> {
  final Value<int> id;
  final Value<int> mealId;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<DateTime> addedAt;
  const MealPlanItemsCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  MealPlanItemsCompanion.insert({
    this.id = const Value.absent(),
    required int mealId,
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime addedAt,
  })  : mealId = Value(mealId),
        addedAt = Value(addedAt);
  static Insertable<MealPlanItem> custom({
    Expression<int>? id,
    Expression<int>? mealId,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  MealPlanItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? mealId,
      Value<bool>? isCompleted,
      Value<DateTime?>? completedAt,
      Value<DateTime>? addedAt}) {
    return MealPlanItemsCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<int>(mealId.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealPlanItemsCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $MealIngredientsTable extends MealIngredients
    with TableInfo<$MealIngredientsTable, MealIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<int> mealId = GeneratedColumn<int>(
      'meal_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _catalogItemIdMeta =
      const VerificationMeta('catalogItemId');
  @override
  late final GeneratedColumn<int> catalogItemId = GeneratedColumn<int>(
      'catalog_item_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addToShoppingListMeta =
      const VerificationMeta('addToShoppingList');
  @override
  late final GeneratedColumn<bool> addToShoppingList = GeneratedColumn<bool>(
      'add_to_shopping_list', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("add_to_shopping_list" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, mealId, catalogItemId, displayName, addToShoppingList];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<MealIngredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meal_id')) {
      context.handle(_mealIdMeta,
          mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta));
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('catalog_item_id')) {
      context.handle(
          _catalogItemIdMeta,
          catalogItemId.isAcceptableOrUnknown(
              data['catalog_item_id']!, _catalogItemIdMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('add_to_shopping_list')) {
      context.handle(
          _addToShoppingListMeta,
          addToShoppingList.isAcceptableOrUnknown(
              data['add_to_shopping_list']!, _addToShoppingListMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealIngredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mealId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meal_id'])!,
      catalogItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}catalog_item_id']),
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      addToShoppingList: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}add_to_shopping_list'])!,
    );
  }

  @override
  $MealIngredientsTable createAlias(String alias) {
    return $MealIngredientsTable(attachedDatabase, alias);
  }
}

class MealIngredient extends DataClass implements Insertable<MealIngredient> {
  final int id;
  final int mealId;
  final int? catalogItemId;
  final String displayName;
  final bool addToShoppingList;
  const MealIngredient(
      {required this.id,
      required this.mealId,
      this.catalogItemId,
      required this.displayName,
      required this.addToShoppingList});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meal_id'] = Variable<int>(mealId);
    if (!nullToAbsent || catalogItemId != null) {
      map['catalog_item_id'] = Variable<int>(catalogItemId);
    }
    map['display_name'] = Variable<String>(displayName);
    map['add_to_shopping_list'] = Variable<bool>(addToShoppingList);
    return map;
  }

  MealIngredientsCompanion toCompanion(bool nullToAbsent) {
    return MealIngredientsCompanion(
      id: Value(id),
      mealId: Value(mealId),
      catalogItemId: catalogItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogItemId),
      displayName: Value(displayName),
      addToShoppingList: Value(addToShoppingList),
    );
  }

  factory MealIngredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealIngredient(
      id: serializer.fromJson<int>(json['id']),
      mealId: serializer.fromJson<int>(json['mealId']),
      catalogItemId: serializer.fromJson<int?>(json['catalogItemId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      addToShoppingList: serializer.fromJson<bool>(json['addToShoppingList']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealId': serializer.toJson<int>(mealId),
      'catalogItemId': serializer.toJson<int?>(catalogItemId),
      'displayName': serializer.toJson<String>(displayName),
      'addToShoppingList': serializer.toJson<bool>(addToShoppingList),
    };
  }

  MealIngredient copyWith(
          {int? id,
          int? mealId,
          Value<int?> catalogItemId = const Value.absent(),
          String? displayName,
          bool? addToShoppingList}) =>
      MealIngredient(
        id: id ?? this.id,
        mealId: mealId ?? this.mealId,
        catalogItemId:
            catalogItemId.present ? catalogItemId.value : this.catalogItemId,
        displayName: displayName ?? this.displayName,
        addToShoppingList: addToShoppingList ?? this.addToShoppingList,
      );
  MealIngredient copyWithCompanion(MealIngredientsCompanion data) {
    return MealIngredient(
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      catalogItemId: data.catalogItemId.present
          ? data.catalogItemId.value
          : this.catalogItemId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      addToShoppingList: data.addToShoppingList.present
          ? data.addToShoppingList.value
          : this.addToShoppingList,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealIngredient(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('displayName: $displayName, ')
          ..write('addToShoppingList: $addToShoppingList')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mealId, catalogItemId, displayName, addToShoppingList);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealIngredient &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.catalogItemId == this.catalogItemId &&
          other.displayName == this.displayName &&
          other.addToShoppingList == this.addToShoppingList);
}

class MealIngredientsCompanion extends UpdateCompanion<MealIngredient> {
  final Value<int> id;
  final Value<int> mealId;
  final Value<int?> catalogItemId;
  final Value<String> displayName;
  final Value<bool> addToShoppingList;
  const MealIngredientsCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.catalogItemId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.addToShoppingList = const Value.absent(),
  });
  MealIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int mealId,
    this.catalogItemId = const Value.absent(),
    required String displayName,
    this.addToShoppingList = const Value.absent(),
  })  : mealId = Value(mealId),
        displayName = Value(displayName);
  static Insertable<MealIngredient> custom({
    Expression<int>? id,
    Expression<int>? mealId,
    Expression<int>? catalogItemId,
    Expression<String>? displayName,
    Expression<bool>? addToShoppingList,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (catalogItemId != null) 'catalog_item_id': catalogItemId,
      if (displayName != null) 'display_name': displayName,
      if (addToShoppingList != null) 'add_to_shopping_list': addToShoppingList,
    });
  }

  MealIngredientsCompanion copyWith(
      {Value<int>? id,
      Value<int>? mealId,
      Value<int?>? catalogItemId,
      Value<String>? displayName,
      Value<bool>? addToShoppingList}) {
    return MealIngredientsCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      catalogItemId: catalogItemId ?? this.catalogItemId,
      displayName: displayName ?? this.displayName,
      addToShoppingList: addToShoppingList ?? this.addToShoppingList,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<int>(mealId.value);
    }
    if (catalogItemId.present) {
      map['catalog_item_id'] = Variable<int>(catalogItemId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (addToShoppingList.present) {
      map['add_to_shopping_list'] = Variable<bool>(addToShoppingList.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('catalogItemId: $catalogItemId, ')
          ..write('displayName: $displayName, ')
          ..write('addToShoppingList: $addToShoppingList')
          ..write(')'))
        .toString();
  }
}

class $MealCheckOffEventsTable extends MealCheckOffEvents
    with TableInfo<$MealCheckOffEventsTable, MealCheckOffEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealCheckOffEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<int> mealId = GeneratedColumn<int>(
      'meal_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mealPlanItemIdMeta =
      const VerificationMeta('mealPlanItemId');
  @override
  late final GeneratedColumn<int> mealPlanItemId = GeneratedColumn<int>(
      'meal_plan_item_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _checkedAtMeta =
      const VerificationMeta('checkedAt');
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
      'checked_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, mealId, mealPlanItemId, checkedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_check_off_events';
  @override
  VerificationContext validateIntegrity(Insertable<MealCheckOffEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meal_id')) {
      context.handle(_mealIdMeta,
          mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta));
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('meal_plan_item_id')) {
      context.handle(
          _mealPlanItemIdMeta,
          mealPlanItemId.isAcceptableOrUnknown(
              data['meal_plan_item_id']!, _mealPlanItemIdMeta));
    }
    if (data.containsKey('checked_at')) {
      context.handle(_checkedAtMeta,
          checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta));
    } else if (isInserting) {
      context.missing(_checkedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealCheckOffEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealCheckOffEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mealId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meal_id'])!,
      mealPlanItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meal_plan_item_id']),
      checkedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}checked_at'])!,
    );
  }

  @override
  $MealCheckOffEventsTable createAlias(String alias) {
    return $MealCheckOffEventsTable(attachedDatabase, alias);
  }
}

class MealCheckOffEvent extends DataClass
    implements Insertable<MealCheckOffEvent> {
  final int id;
  final int mealId;
  final int? mealPlanItemId;
  final DateTime checkedAt;
  const MealCheckOffEvent(
      {required this.id,
      required this.mealId,
      this.mealPlanItemId,
      required this.checkedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meal_id'] = Variable<int>(mealId);
    if (!nullToAbsent || mealPlanItemId != null) {
      map['meal_plan_item_id'] = Variable<int>(mealPlanItemId);
    }
    map['checked_at'] = Variable<DateTime>(checkedAt);
    return map;
  }

  MealCheckOffEventsCompanion toCompanion(bool nullToAbsent) {
    return MealCheckOffEventsCompanion(
      id: Value(id),
      mealId: Value(mealId),
      mealPlanItemId: mealPlanItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(mealPlanItemId),
      checkedAt: Value(checkedAt),
    );
  }

  factory MealCheckOffEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealCheckOffEvent(
      id: serializer.fromJson<int>(json['id']),
      mealId: serializer.fromJson<int>(json['mealId']),
      mealPlanItemId: serializer.fromJson<int?>(json['mealPlanItemId']),
      checkedAt: serializer.fromJson<DateTime>(json['checkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealId': serializer.toJson<int>(mealId),
      'mealPlanItemId': serializer.toJson<int?>(mealPlanItemId),
      'checkedAt': serializer.toJson<DateTime>(checkedAt),
    };
  }

  MealCheckOffEvent copyWith(
          {int? id,
          int? mealId,
          Value<int?> mealPlanItemId = const Value.absent(),
          DateTime? checkedAt}) =>
      MealCheckOffEvent(
        id: id ?? this.id,
        mealId: mealId ?? this.mealId,
        mealPlanItemId:
            mealPlanItemId.present ? mealPlanItemId.value : this.mealPlanItemId,
        checkedAt: checkedAt ?? this.checkedAt,
      );
  MealCheckOffEvent copyWithCompanion(MealCheckOffEventsCompanion data) {
    return MealCheckOffEvent(
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      mealPlanItemId: data.mealPlanItemId.present
          ? data.mealPlanItemId.value
          : this.mealPlanItemId,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealCheckOffEvent(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('mealPlanItemId: $mealPlanItemId, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mealId, mealPlanItemId, checkedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealCheckOffEvent &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.mealPlanItemId == this.mealPlanItemId &&
          other.checkedAt == this.checkedAt);
}

class MealCheckOffEventsCompanion extends UpdateCompanion<MealCheckOffEvent> {
  final Value<int> id;
  final Value<int> mealId;
  final Value<int?> mealPlanItemId;
  final Value<DateTime> checkedAt;
  const MealCheckOffEventsCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.mealPlanItemId = const Value.absent(),
    this.checkedAt = const Value.absent(),
  });
  MealCheckOffEventsCompanion.insert({
    this.id = const Value.absent(),
    required int mealId,
    this.mealPlanItemId = const Value.absent(),
    required DateTime checkedAt,
  })  : mealId = Value(mealId),
        checkedAt = Value(checkedAt);
  static Insertable<MealCheckOffEvent> custom({
    Expression<int>? id,
    Expression<int>? mealId,
    Expression<int>? mealPlanItemId,
    Expression<DateTime>? checkedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (mealPlanItemId != null) 'meal_plan_item_id': mealPlanItemId,
      if (checkedAt != null) 'checked_at': checkedAt,
    });
  }

  MealCheckOffEventsCompanion copyWith(
      {Value<int>? id,
      Value<int>? mealId,
      Value<int?>? mealPlanItemId,
      Value<DateTime>? checkedAt}) {
    return MealCheckOffEventsCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      mealPlanItemId: mealPlanItemId ?? this.mealPlanItemId,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<int>(mealId.value);
    }
    if (mealPlanItemId.present) {
      map['meal_plan_item_id'] = Variable<int>(mealPlanItemId.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealCheckOffEventsCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('mealPlanItemId: $mealPlanItemId, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }
}

class $MealStepsTable extends MealSteps
    with TableInfo<$MealStepsTable, MealStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<int> mealId = GeneratedColumn<int>(
      'meal_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stepOrderMeta =
      const VerificationMeta('stepOrder');
  @override
  late final GeneratedColumn<int> stepOrder = GeneratedColumn<int>(
      'step_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _instructionMeta =
      const VerificationMeta('instruction');
  @override
  late final GeneratedColumn<String> instruction = GeneratedColumn<String>(
      'instruction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, mealId, stepOrder, instruction];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_steps';
  @override
  VerificationContext validateIntegrity(Insertable<MealStep> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meal_id')) {
      context.handle(_mealIdMeta,
          mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta));
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('step_order')) {
      context.handle(_stepOrderMeta,
          stepOrder.isAcceptableOrUnknown(data['step_order']!, _stepOrderMeta));
    } else if (isInserting) {
      context.missing(_stepOrderMeta);
    }
    if (data.containsKey('instruction')) {
      context.handle(
          _instructionMeta,
          instruction.isAcceptableOrUnknown(
              data['instruction']!, _instructionMeta));
    } else if (isInserting) {
      context.missing(_instructionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealStep(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mealId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meal_id'])!,
      stepOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}step_order'])!,
      instruction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instruction'])!,
    );
  }

  @override
  $MealStepsTable createAlias(String alias) {
    return $MealStepsTable(attachedDatabase, alias);
  }
}

class MealStep extends DataClass implements Insertable<MealStep> {
  final int id;
  final int mealId;
  final int stepOrder;
  final String instruction;
  const MealStep(
      {required this.id,
      required this.mealId,
      required this.stepOrder,
      required this.instruction});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meal_id'] = Variable<int>(mealId);
    map['step_order'] = Variable<int>(stepOrder);
    map['instruction'] = Variable<String>(instruction);
    return map;
  }

  MealStepsCompanion toCompanion(bool nullToAbsent) {
    return MealStepsCompanion(
      id: Value(id),
      mealId: Value(mealId),
      stepOrder: Value(stepOrder),
      instruction: Value(instruction),
    );
  }

  factory MealStep.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealStep(
      id: serializer.fromJson<int>(json['id']),
      mealId: serializer.fromJson<int>(json['mealId']),
      stepOrder: serializer.fromJson<int>(json['stepOrder']),
      instruction: serializer.fromJson<String>(json['instruction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealId': serializer.toJson<int>(mealId),
      'stepOrder': serializer.toJson<int>(stepOrder),
      'instruction': serializer.toJson<String>(instruction),
    };
  }

  MealStep copyWith(
          {int? id, int? mealId, int? stepOrder, String? instruction}) =>
      MealStep(
        id: id ?? this.id,
        mealId: mealId ?? this.mealId,
        stepOrder: stepOrder ?? this.stepOrder,
        instruction: instruction ?? this.instruction,
      );
  MealStep copyWithCompanion(MealStepsCompanion data) {
    return MealStep(
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      stepOrder: data.stepOrder.present ? data.stepOrder.value : this.stepOrder,
      instruction:
          data.instruction.present ? data.instruction.value : this.instruction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealStep(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('stepOrder: $stepOrder, ')
          ..write('instruction: $instruction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mealId, stepOrder, instruction);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealStep &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.stepOrder == this.stepOrder &&
          other.instruction == this.instruction);
}

class MealStepsCompanion extends UpdateCompanion<MealStep> {
  final Value<int> id;
  final Value<int> mealId;
  final Value<int> stepOrder;
  final Value<String> instruction;
  const MealStepsCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.stepOrder = const Value.absent(),
    this.instruction = const Value.absent(),
  });
  MealStepsCompanion.insert({
    this.id = const Value.absent(),
    required int mealId,
    required int stepOrder,
    required String instruction,
  })  : mealId = Value(mealId),
        stepOrder = Value(stepOrder),
        instruction = Value(instruction);
  static Insertable<MealStep> custom({
    Expression<int>? id,
    Expression<int>? mealId,
    Expression<int>? stepOrder,
    Expression<String>? instruction,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (stepOrder != null) 'step_order': stepOrder,
      if (instruction != null) 'instruction': instruction,
    });
  }

  MealStepsCompanion copyWith(
      {Value<int>? id,
      Value<int>? mealId,
      Value<int>? stepOrder,
      Value<String>? instruction}) {
    return MealStepsCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      stepOrder: stepOrder ?? this.stepOrder,
      instruction: instruction ?? this.instruction,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<int>(mealId.value);
    }
    if (stepOrder.present) {
      map['step_order'] = Variable<int>(stepOrder.value);
    }
    if (instruction.present) {
      map['instruction'] = Variable<String>(instruction.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealStepsCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('stepOrder: $stepOrder, ')
          ..write('instruction: $instruction')
          ..write(')'))
        .toString();
  }
}

class $MealTagsTable extends MealTags with TableInfo<$MealTagsTable, MealTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, displayName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_tags';
  @override
  VerificationContext validateIntegrity(Insertable<MealTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealTag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
    );
  }

  @override
  $MealTagsTable createAlias(String alias) {
    return $MealTagsTable(attachedDatabase, alias);
  }
}

class MealTag extends DataClass implements Insertable<MealTag> {
  final int id;
  final String name;
  final String displayName;
  const MealTag(
      {required this.id, required this.name, required this.displayName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['display_name'] = Variable<String>(displayName);
    return map;
  }

  MealTagsCompanion toCompanion(bool nullToAbsent) {
    return MealTagsCompanion(
      id: Value(id),
      name: Value(name),
      displayName: Value(displayName),
    );
  }

  factory MealTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealTag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      displayName: serializer.fromJson<String>(json['displayName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'displayName': serializer.toJson<String>(displayName),
    };
  }

  MealTag copyWith({int? id, String? name, String? displayName}) => MealTag(
        id: id ?? this.id,
        name: name ?? this.name,
        displayName: displayName ?? this.displayName,
      );
  MealTag copyWithCompanion(MealTagsCompanion data) {
    return MealTag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealTag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, displayName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealTag &&
          other.id == this.id &&
          other.name == this.name &&
          other.displayName == this.displayName);
}

class MealTagsCompanion extends UpdateCompanion<MealTag> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> displayName;
  const MealTagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.displayName = const Value.absent(),
  });
  MealTagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String displayName,
  })  : name = Value(name),
        displayName = Value(displayName);
  static Insertable<MealTag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? displayName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
    });
  }

  MealTagsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? displayName}) {
    return MealTagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealTagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }
}

class $MealTagAssignmentsTable extends MealTagAssignments
    with TableInfo<$MealTagAssignmentsTable, MealTagAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealTagAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<int> mealId = GeneratedColumn<int>(
      'meal_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [mealId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_tag_assignments';
  @override
  VerificationContext validateIntegrity(Insertable<MealTagAssignment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meal_id')) {
      context.handle(_mealIdMeta,
          mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta));
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mealId, tagId};
  @override
  MealTagAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealTagAssignment(
      mealId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}meal_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $MealTagAssignmentsTable createAlias(String alias) {
    return $MealTagAssignmentsTable(attachedDatabase, alias);
  }
}

class MealTagAssignment extends DataClass
    implements Insertable<MealTagAssignment> {
  final int mealId;
  final int tagId;
  const MealTagAssignment({required this.mealId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meal_id'] = Variable<int>(mealId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  MealTagAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return MealTagAssignmentsCompanion(
      mealId: Value(mealId),
      tagId: Value(tagId),
    );
  }

  factory MealTagAssignment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealTagAssignment(
      mealId: serializer.fromJson<int>(json['mealId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mealId': serializer.toJson<int>(mealId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  MealTagAssignment copyWith({int? mealId, int? tagId}) => MealTagAssignment(
        mealId: mealId ?? this.mealId,
        tagId: tagId ?? this.tagId,
      );
  MealTagAssignment copyWithCompanion(MealTagAssignmentsCompanion data) {
    return MealTagAssignment(
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealTagAssignment(')
          ..write('mealId: $mealId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mealId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealTagAssignment &&
          other.mealId == this.mealId &&
          other.tagId == this.tagId);
}

class MealTagAssignmentsCompanion extends UpdateCompanion<MealTagAssignment> {
  final Value<int> mealId;
  final Value<int> tagId;
  final Value<int> rowid;
  const MealTagAssignmentsCompanion({
    this.mealId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealTagAssignmentsCompanion.insert({
    required int mealId,
    required int tagId,
    this.rowid = const Value.absent(),
  })  : mealId = Value(mealId),
        tagId = Value(tagId);
  static Insertable<MealTagAssignment> custom({
    Expression<int>? mealId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mealId != null) 'meal_id': mealId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealTagAssignmentsCompanion copyWith(
      {Value<int>? mealId, Value<int>? tagId, Value<int>? rowid}) {
    return MealTagAssignmentsCompanion(
      mealId: mealId ?? this.mealId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mealId.present) {
      map['meal_id'] = Variable<int>(mealId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealTagAssignmentsCompanion(')
          ..write('mealId: $mealId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodoListsTable extends TodoLists
    with TableInfo<$TodoListsTable, TodoList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_lists';
  @override
  VerificationContext validateIntegrity(Insertable<TodoList> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoList(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TodoListsTable createAlias(String alias) {
    return $TodoListsTable(attachedDatabase, alias);
  }
}

class TodoList extends DataClass implements Insertable<TodoList> {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TodoList(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TodoListsCompanion toCompanion(bool nullToAbsent) {
    return TodoListsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TodoList.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TodoList copyWith(
          {int? id, String? name, DateTime? createdAt, DateTime? updatedAt}) =>
      TodoList(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TodoList copyWithCompanion(TodoListsCompanion data) {
    return TodoList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoList &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TodoListsCompanion extends UpdateCompanion<TodoList> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TodoListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TodoListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TodoList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TodoListsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return TodoListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TodoItemsTable extends TodoItems
    with TableInfo<$TodoItemsTable, TodoItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
      'list_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledDateMeta =
      const VerificationMeta('scheduledDate');
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>('scheduled_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _reminderAtMeta =
      const VerificationMeta('reminderAt');
  @override
  late final GeneratedColumn<DateTime> reminderAt = GeneratedColumn<DateTime>(
      'reminder_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        listId,
        displayName,
        notes,
        scheduledDate,
        sortOrder,
        isCompleted,
        completedAt,
        addedAt,
        reminderAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_items';
  @override
  VerificationContext validateIntegrity(Insertable<TodoItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
          _scheduledDateMeta,
          scheduledDate.isAcceptableOrUnknown(
              data['scheduled_date']!, _scheduledDateMeta));
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('reminder_at')) {
      context.handle(
          _reminderAtMeta,
          reminderAt.isAcceptableOrUnknown(
              data['reminder_at']!, _reminderAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      scheduledDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}scheduled_date'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
      reminderAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reminder_at']),
    );
  }

  @override
  $TodoItemsTable createAlias(String alias) {
    return $TodoItemsTable(attachedDatabase, alias);
  }
}

class TodoItem extends DataClass implements Insertable<TodoItem> {
  final int id;
  final int listId;
  final String displayName;
  final String? notes;
  final DateTime scheduledDate;
  final int sortOrder;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime addedAt;
  final DateTime? reminderAt;
  const TodoItem(
      {required this.id,
      required this.listId,
      required this.displayName,
      this.notes,
      required this.scheduledDate,
      required this.sortOrder,
      required this.isCompleted,
      this.completedAt,
      required this.addedAt,
      this.reminderAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || reminderAt != null) {
      map['reminder_at'] = Variable<DateTime>(reminderAt);
    }
    return map;
  }

  TodoItemsCompanion toCompanion(bool nullToAbsent) {
    return TodoItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      displayName: Value(displayName),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      scheduledDate: Value(scheduledDate),
      sortOrder: Value(sortOrder),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      addedAt: Value(addedAt),
      reminderAt: reminderAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderAt),
    );
  }

  factory TodoItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoItem(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      notes: serializer.fromJson<String?>(json['notes']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      reminderAt: serializer.fromJson<DateTime?>(json['reminderAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'displayName': serializer.toJson<String>(displayName),
      'notes': serializer.toJson<String?>(notes),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'reminderAt': serializer.toJson<DateTime?>(reminderAt),
    };
  }

  TodoItem copyWith(
          {int? id,
          int? listId,
          String? displayName,
          Value<String?> notes = const Value.absent(),
          DateTime? scheduledDate,
          int? sortOrder,
          bool? isCompleted,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? addedAt,
          Value<DateTime?> reminderAt = const Value.absent()}) =>
      TodoItem(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        displayName: displayName ?? this.displayName,
        notes: notes.present ? notes.value : this.notes,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        sortOrder: sortOrder ?? this.sortOrder,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        addedAt: addedAt ?? this.addedAt,
        reminderAt: reminderAt.present ? reminderAt.value : this.reminderAt,
      );
  TodoItem copyWithCompanion(TodoItemsCompanion data) {
    return TodoItem(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      notes: data.notes.present ? data.notes.value : this.notes,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      reminderAt:
          data.reminderAt.present ? data.reminderAt.value : this.reminderAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoItem(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('displayName: $displayName, ')
          ..write('notes: $notes, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('addedAt: $addedAt, ')
          ..write('reminderAt: $reminderAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listId, displayName, notes, scheduledDate,
      sortOrder, isCompleted, completedAt, addedAt, reminderAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoItem &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.displayName == this.displayName &&
          other.notes == this.notes &&
          other.scheduledDate == this.scheduledDate &&
          other.sortOrder == this.sortOrder &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.addedAt == this.addedAt &&
          other.reminderAt == this.reminderAt);
}

class TodoItemsCompanion extends UpdateCompanion<TodoItem> {
  final Value<int> id;
  final Value<int> listId;
  final Value<String> displayName;
  final Value<String?> notes;
  final Value<DateTime> scheduledDate;
  final Value<int> sortOrder;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<DateTime> addedAt;
  final Value<DateTime?> reminderAt;
  const TodoItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.notes = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.reminderAt = const Value.absent(),
  });
  TodoItemsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required String displayName,
    this.notes = const Value.absent(),
    required DateTime scheduledDate,
    this.sortOrder = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime addedAt,
    this.reminderAt = const Value.absent(),
  })  : listId = Value(listId),
        displayName = Value(displayName),
        scheduledDate = Value(scheduledDate),
        addedAt = Value(addedAt);
  static Insertable<TodoItem> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<String>? displayName,
    Expression<String>? notes,
    Expression<DateTime>? scheduledDate,
    Expression<int>? sortOrder,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? reminderAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (displayName != null) 'display_name': displayName,
      if (notes != null) 'notes': notes,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (addedAt != null) 'added_at': addedAt,
      if (reminderAt != null) 'reminder_at': reminderAt,
    });
  }

  TodoItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? listId,
      Value<String>? displayName,
      Value<String?>? notes,
      Value<DateTime>? scheduledDate,
      Value<int>? sortOrder,
      Value<bool>? isCompleted,
      Value<DateTime?>? completedAt,
      Value<DateTime>? addedAt,
      Value<DateTime?>? reminderAt}) {
    return TodoItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      displayName: displayName ?? this.displayName,
      notes: notes ?? this.notes,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      sortOrder: sortOrder ?? this.sortOrder,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      addedAt: addedAt ?? this.addedAt,
      reminderAt: reminderAt ?? this.reminderAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (reminderAt.present) {
      map['reminder_at'] = Variable<DateTime>(reminderAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('displayName: $displayName, ')
          ..write('notes: $notes, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('addedAt: $addedAt, ')
          ..write('reminderAt: $reminderAt')
          ..write(')'))
        .toString();
  }
}

class $TodoCompletedArchiveTable extends TodoCompletedArchive
    with TableInfo<$TodoCompletedArchiveTable, TodoCompletedArchiveData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoCompletedArchiveTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
      'list_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledDateMeta =
      const VerificationMeta('scheduledDate');
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>('scheduled_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, listId, displayName, notes, scheduledDate, completedAt, archivedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_completed_archive';
  @override
  VerificationContext validateIntegrity(
      Insertable<TodoCompletedArchiveData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
          _scheduledDateMeta,
          scheduledDate.isAcceptableOrUnknown(
              data['scheduled_date']!, _scheduledDateMeta));
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    } else if (isInserting) {
      context.missing(_archivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoCompletedArchiveData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoCompletedArchiveData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      scheduledDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}scheduled_date'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at'])!,
    );
  }

  @override
  $TodoCompletedArchiveTable createAlias(String alias) {
    return $TodoCompletedArchiveTable(attachedDatabase, alias);
  }
}

class TodoCompletedArchiveData extends DataClass
    implements Insertable<TodoCompletedArchiveData> {
  final int id;
  final int listId;
  final String displayName;
  final String? notes;
  final DateTime scheduledDate;
  final DateTime completedAt;
  final DateTime archivedAt;
  const TodoCompletedArchiveData(
      {required this.id,
      required this.listId,
      required this.displayName,
      this.notes,
      required this.scheduledDate,
      required this.completedAt,
      required this.archivedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['archived_at'] = Variable<DateTime>(archivedAt);
    return map;
  }

  TodoCompletedArchiveCompanion toCompanion(bool nullToAbsent) {
    return TodoCompletedArchiveCompanion(
      id: Value(id),
      listId: Value(listId),
      displayName: Value(displayName),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      scheduledDate: Value(scheduledDate),
      completedAt: Value(completedAt),
      archivedAt: Value(archivedAt),
    );
  }

  factory TodoCompletedArchiveData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoCompletedArchiveData(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      notes: serializer.fromJson<String?>(json['notes']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      archivedAt: serializer.fromJson<DateTime>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'displayName': serializer.toJson<String>(displayName),
      'notes': serializer.toJson<String?>(notes),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'archivedAt': serializer.toJson<DateTime>(archivedAt),
    };
  }

  TodoCompletedArchiveData copyWith(
          {int? id,
          int? listId,
          String? displayName,
          Value<String?> notes = const Value.absent(),
          DateTime? scheduledDate,
          DateTime? completedAt,
          DateTime? archivedAt}) =>
      TodoCompletedArchiveData(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        displayName: displayName ?? this.displayName,
        notes: notes.present ? notes.value : this.notes,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        completedAt: completedAt ?? this.completedAt,
        archivedAt: archivedAt ?? this.archivedAt,
      );
  TodoCompletedArchiveData copyWithCompanion(
      TodoCompletedArchiveCompanion data) {
    return TodoCompletedArchiveData(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      notes: data.notes.present ? data.notes.value : this.notes,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoCompletedArchiveData(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('displayName: $displayName, ')
          ..write('notes: $notes, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, listId, displayName, notes, scheduledDate, completedAt, archivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoCompletedArchiveData &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.displayName == this.displayName &&
          other.notes == this.notes &&
          other.scheduledDate == this.scheduledDate &&
          other.completedAt == this.completedAt &&
          other.archivedAt == this.archivedAt);
}

class TodoCompletedArchiveCompanion
    extends UpdateCompanion<TodoCompletedArchiveData> {
  final Value<int> id;
  final Value<int> listId;
  final Value<String> displayName;
  final Value<String?> notes;
  final Value<DateTime> scheduledDate;
  final Value<DateTime> completedAt;
  final Value<DateTime> archivedAt;
  const TodoCompletedArchiveCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.notes = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  TodoCompletedArchiveCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required String displayName,
    this.notes = const Value.absent(),
    required DateTime scheduledDate,
    required DateTime completedAt,
    required DateTime archivedAt,
  })  : listId = Value(listId),
        displayName = Value(displayName),
        scheduledDate = Value(scheduledDate),
        completedAt = Value(completedAt),
        archivedAt = Value(archivedAt);
  static Insertable<TodoCompletedArchiveData> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<String>? displayName,
    Expression<String>? notes,
    Expression<DateTime>? scheduledDate,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (displayName != null) 'display_name': displayName,
      if (notes != null) 'notes': notes,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  TodoCompletedArchiveCompanion copyWith(
      {Value<int>? id,
      Value<int>? listId,
      Value<String>? displayName,
      Value<String?>? notes,
      Value<DateTime>? scheduledDate,
      Value<DateTime>? completedAt,
      Value<DateTime>? archivedAt}) {
    return TodoCompletedArchiveCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      displayName: displayName ?? this.displayName,
      notes: notes ?? this.notes,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedAt: completedAt ?? this.completedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoCompletedArchiveCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('displayName: $displayName, ')
          ..write('notes: $notes, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class $TakeAwayListsTable extends TakeAwayLists
    with TableInfo<$TakeAwayListsTable, TakeAwayList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TakeAwayListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'take_away_lists';
  @override
  VerificationContext validateIntegrity(Insertable<TakeAwayList> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TakeAwayList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TakeAwayList(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TakeAwayListsTable createAlias(String alias) {
    return $TakeAwayListsTable(attachedDatabase, alias);
  }
}

class TakeAwayList extends DataClass implements Insertable<TakeAwayList> {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TakeAwayList(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TakeAwayListsCompanion toCompanion(bool nullToAbsent) {
    return TakeAwayListsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TakeAwayList.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TakeAwayList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TakeAwayList copyWith(
          {int? id, String? name, DateTime? createdAt, DateTime? updatedAt}) =>
      TakeAwayList(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TakeAwayList copyWithCompanion(TakeAwayListsCompanion data) {
    return TakeAwayList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TakeAwayList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TakeAwayList &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TakeAwayListsCompanion extends UpdateCompanion<TakeAwayList> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TakeAwayListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TakeAwayListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TakeAwayList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TakeAwayListsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return TakeAwayListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TakeAwayListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TakeAwayMenusTable extends TakeAwayMenus
    with TableInfo<$TakeAwayMenusTable, TakeAwayMenu> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TakeAwayMenusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
      'list_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _restaurantNameMeta =
      const VerificationMeta('restaurantName');
  @override
  late final GeneratedColumn<String> restaurantName = GeneratedColumn<String>(
      'restaurant_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mapsUrlMeta =
      const VerificationMeta('mapsUrl');
  @override
  late final GeneratedColumn<String> mapsUrl = GeneratedColumn<String>(
      'maps_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _websiteMeta =
      const VerificationMeta('website');
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
      'website', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _menuUrlMeta =
      const VerificationMeta('menuUrl');
  @override
  late final GeneratedColumn<String> menuUrl = GeneratedColumn<String>(
      'menu_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFinalizedMeta =
      const VerificationMeta('isFinalized');
  @override
  late final GeneratedColumn<bool> isFinalized = GeneratedColumn<bool>(
      'is_finalized', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_finalized" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        listId,
        restaurantName,
        location,
        mapsUrl,
        website,
        phone,
        menuUrl,
        currency,
        isFinalized,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'take_away_menus';
  @override
  VerificationContext validateIntegrity(Insertable<TakeAwayMenu> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('restaurant_name')) {
      context.handle(
          _restaurantNameMeta,
          restaurantName.isAcceptableOrUnknown(
              data['restaurant_name']!, _restaurantNameMeta));
    } else if (isInserting) {
      context.missing(_restaurantNameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('maps_url')) {
      context.handle(_mapsUrlMeta,
          mapsUrl.isAcceptableOrUnknown(data['maps_url']!, _mapsUrlMeta));
    }
    if (data.containsKey('website')) {
      context.handle(_websiteMeta,
          website.isAcceptableOrUnknown(data['website']!, _websiteMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('menu_url')) {
      context.handle(_menuUrlMeta,
          menuUrl.isAcceptableOrUnknown(data['menu_url']!, _menuUrlMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('is_finalized')) {
      context.handle(
          _isFinalizedMeta,
          isFinalized.isAcceptableOrUnknown(
              data['is_finalized']!, _isFinalizedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TakeAwayMenu map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TakeAwayMenu(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_id'])!,
      restaurantName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}restaurant_name'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      mapsUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}maps_url']),
      website: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      menuUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}menu_url']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency']),
      isFinalized: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_finalized'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TakeAwayMenusTable createAlias(String alias) {
    return $TakeAwayMenusTable(attachedDatabase, alias);
  }
}

class TakeAwayMenu extends DataClass implements Insertable<TakeAwayMenu> {
  final int id;
  final int listId;
  final String restaurantName;
  final String? location;
  final String? mapsUrl;
  final String? website;
  final String? phone;
  final String? menuUrl;
  final String? currency;
  final bool isFinalized;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TakeAwayMenu(
      {required this.id,
      required this.listId,
      required this.restaurantName,
      this.location,
      this.mapsUrl,
      this.website,
      this.phone,
      this.menuUrl,
      this.currency,
      required this.isFinalized,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['restaurant_name'] = Variable<String>(restaurantName);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || mapsUrl != null) {
      map['maps_url'] = Variable<String>(mapsUrl);
    }
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || menuUrl != null) {
      map['menu_url'] = Variable<String>(menuUrl);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    map['is_finalized'] = Variable<bool>(isFinalized);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TakeAwayMenusCompanion toCompanion(bool nullToAbsent) {
    return TakeAwayMenusCompanion(
      id: Value(id),
      listId: Value(listId),
      restaurantName: Value(restaurantName),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      mapsUrl: mapsUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mapsUrl),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      menuUrl: menuUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(menuUrl),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      isFinalized: Value(isFinalized),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TakeAwayMenu.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TakeAwayMenu(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      restaurantName: serializer.fromJson<String>(json['restaurantName']),
      location: serializer.fromJson<String?>(json['location']),
      mapsUrl: serializer.fromJson<String?>(json['mapsUrl']),
      website: serializer.fromJson<String?>(json['website']),
      phone: serializer.fromJson<String?>(json['phone']),
      menuUrl: serializer.fromJson<String?>(json['menuUrl']),
      currency: serializer.fromJson<String?>(json['currency']),
      isFinalized: serializer.fromJson<bool>(json['isFinalized']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'restaurantName': serializer.toJson<String>(restaurantName),
      'location': serializer.toJson<String?>(location),
      'mapsUrl': serializer.toJson<String?>(mapsUrl),
      'website': serializer.toJson<String?>(website),
      'phone': serializer.toJson<String?>(phone),
      'menuUrl': serializer.toJson<String?>(menuUrl),
      'currency': serializer.toJson<String?>(currency),
      'isFinalized': serializer.toJson<bool>(isFinalized),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TakeAwayMenu copyWith(
          {int? id,
          int? listId,
          String? restaurantName,
          Value<String?> location = const Value.absent(),
          Value<String?> mapsUrl = const Value.absent(),
          Value<String?> website = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> menuUrl = const Value.absent(),
          Value<String?> currency = const Value.absent(),
          bool? isFinalized,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TakeAwayMenu(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        restaurantName: restaurantName ?? this.restaurantName,
        location: location.present ? location.value : this.location,
        mapsUrl: mapsUrl.present ? mapsUrl.value : this.mapsUrl,
        website: website.present ? website.value : this.website,
        phone: phone.present ? phone.value : this.phone,
        menuUrl: menuUrl.present ? menuUrl.value : this.menuUrl,
        currency: currency.present ? currency.value : this.currency,
        isFinalized: isFinalized ?? this.isFinalized,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TakeAwayMenu copyWithCompanion(TakeAwayMenusCompanion data) {
    return TakeAwayMenu(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      restaurantName: data.restaurantName.present
          ? data.restaurantName.value
          : this.restaurantName,
      location: data.location.present ? data.location.value : this.location,
      mapsUrl: data.mapsUrl.present ? data.mapsUrl.value : this.mapsUrl,
      website: data.website.present ? data.website.value : this.website,
      phone: data.phone.present ? data.phone.value : this.phone,
      menuUrl: data.menuUrl.present ? data.menuUrl.value : this.menuUrl,
      currency: data.currency.present ? data.currency.value : this.currency,
      isFinalized:
          data.isFinalized.present ? data.isFinalized.value : this.isFinalized,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TakeAwayMenu(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('restaurantName: $restaurantName, ')
          ..write('location: $location, ')
          ..write('mapsUrl: $mapsUrl, ')
          ..write('website: $website, ')
          ..write('phone: $phone, ')
          ..write('menuUrl: $menuUrl, ')
          ..write('currency: $currency, ')
          ..write('isFinalized: $isFinalized, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listId, restaurantName, location, mapsUrl,
      website, phone, menuUrl, currency, isFinalized, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TakeAwayMenu &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.restaurantName == this.restaurantName &&
          other.location == this.location &&
          other.mapsUrl == this.mapsUrl &&
          other.website == this.website &&
          other.phone == this.phone &&
          other.menuUrl == this.menuUrl &&
          other.currency == this.currency &&
          other.isFinalized == this.isFinalized &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TakeAwayMenusCompanion extends UpdateCompanion<TakeAwayMenu> {
  final Value<int> id;
  final Value<int> listId;
  final Value<String> restaurantName;
  final Value<String?> location;
  final Value<String?> mapsUrl;
  final Value<String?> website;
  final Value<String?> phone;
  final Value<String?> menuUrl;
  final Value<String?> currency;
  final Value<bool> isFinalized;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TakeAwayMenusCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.restaurantName = const Value.absent(),
    this.location = const Value.absent(),
    this.mapsUrl = const Value.absent(),
    this.website = const Value.absent(),
    this.phone = const Value.absent(),
    this.menuUrl = const Value.absent(),
    this.currency = const Value.absent(),
    this.isFinalized = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TakeAwayMenusCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required String restaurantName,
    this.location = const Value.absent(),
    this.mapsUrl = const Value.absent(),
    this.website = const Value.absent(),
    this.phone = const Value.absent(),
    this.menuUrl = const Value.absent(),
    this.currency = const Value.absent(),
    this.isFinalized = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : listId = Value(listId),
        restaurantName = Value(restaurantName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TakeAwayMenu> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<String>? restaurantName,
    Expression<String>? location,
    Expression<String>? mapsUrl,
    Expression<String>? website,
    Expression<String>? phone,
    Expression<String>? menuUrl,
    Expression<String>? currency,
    Expression<bool>? isFinalized,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (restaurantName != null) 'restaurant_name': restaurantName,
      if (location != null) 'location': location,
      if (mapsUrl != null) 'maps_url': mapsUrl,
      if (website != null) 'website': website,
      if (phone != null) 'phone': phone,
      if (menuUrl != null) 'menu_url': menuUrl,
      if (currency != null) 'currency': currency,
      if (isFinalized != null) 'is_finalized': isFinalized,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TakeAwayMenusCompanion copyWith(
      {Value<int>? id,
      Value<int>? listId,
      Value<String>? restaurantName,
      Value<String?>? location,
      Value<String?>? mapsUrl,
      Value<String?>? website,
      Value<String?>? phone,
      Value<String?>? menuUrl,
      Value<String?>? currency,
      Value<bool>? isFinalized,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return TakeAwayMenusCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      restaurantName: restaurantName ?? this.restaurantName,
      location: location ?? this.location,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      menuUrl: menuUrl ?? this.menuUrl,
      currency: currency ?? this.currency,
      isFinalized: isFinalized ?? this.isFinalized,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (restaurantName.present) {
      map['restaurant_name'] = Variable<String>(restaurantName.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (mapsUrl.present) {
      map['maps_url'] = Variable<String>(mapsUrl.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (menuUrl.present) {
      map['menu_url'] = Variable<String>(menuUrl.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (isFinalized.present) {
      map['is_finalized'] = Variable<bool>(isFinalized.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TakeAwayMenusCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('restaurantName: $restaurantName, ')
          ..write('location: $location, ')
          ..write('mapsUrl: $mapsUrl, ')
          ..write('website: $website, ')
          ..write('phone: $phone, ')
          ..write('menuUrl: $menuUrl, ')
          ..write('currency: $currency, ')
          ..write('isFinalized: $isFinalized, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TakeAwayMenuItemsTable extends TakeAwayMenuItems
    with TableInfo<$TakeAwayMenuItemsTable, TakeAwayMenuItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TakeAwayMenuItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _menuIdMeta = const VerificationMeta('menuId');
  @override
  late final GeneratedColumn<int> menuId = GeneratedColumn<int>(
      'menu_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _itemNumberMeta =
      const VerificationMeta('itemNumber');
  @override
  late final GeneratedColumn<String> itemNumber = GeneratedColumn<String>(
      'item_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceDisplayMeta =
      const VerificationMeta('priceDisplay');
  @override
  late final GeneratedColumn<String> priceDisplay = GeneratedColumn<String>(
      'price_display', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceAmountMeta =
      const VerificationMeta('priceAmount');
  @override
  late final GeneratedColumn<double> priceAmount = GeneratedColumn<double>(
      'price_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, menuId, itemNumber, name, priceDisplay, priceAmount, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'take_away_menu_items';
  @override
  VerificationContext validateIntegrity(Insertable<TakeAwayMenuItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('menu_id')) {
      context.handle(_menuIdMeta,
          menuId.isAcceptableOrUnknown(data['menu_id']!, _menuIdMeta));
    } else if (isInserting) {
      context.missing(_menuIdMeta);
    }
    if (data.containsKey('item_number')) {
      context.handle(
          _itemNumberMeta,
          itemNumber.isAcceptableOrUnknown(
              data['item_number']!, _itemNumberMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price_display')) {
      context.handle(
          _priceDisplayMeta,
          priceDisplay.isAcceptableOrUnknown(
              data['price_display']!, _priceDisplayMeta));
    } else if (isInserting) {
      context.missing(_priceDisplayMeta);
    }
    if (data.containsKey('price_amount')) {
      context.handle(
          _priceAmountMeta,
          priceAmount.isAcceptableOrUnknown(
              data['price_amount']!, _priceAmountMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TakeAwayMenuItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TakeAwayMenuItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      menuId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}menu_id'])!,
      itemNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_number']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      priceDisplay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}price_display'])!,
      priceAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_amount']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $TakeAwayMenuItemsTable createAlias(String alias) {
    return $TakeAwayMenuItemsTable(attachedDatabase, alias);
  }
}

class TakeAwayMenuItem extends DataClass
    implements Insertable<TakeAwayMenuItem> {
  final int id;
  final int menuId;
  final String? itemNumber;
  final String name;
  final String priceDisplay;
  final double? priceAmount;
  final int sortOrder;
  const TakeAwayMenuItem(
      {required this.id,
      required this.menuId,
      this.itemNumber,
      required this.name,
      required this.priceDisplay,
      this.priceAmount,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['menu_id'] = Variable<int>(menuId);
    if (!nullToAbsent || itemNumber != null) {
      map['item_number'] = Variable<String>(itemNumber);
    }
    map['name'] = Variable<String>(name);
    map['price_display'] = Variable<String>(priceDisplay);
    if (!nullToAbsent || priceAmount != null) {
      map['price_amount'] = Variable<double>(priceAmount);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TakeAwayMenuItemsCompanion toCompanion(bool nullToAbsent) {
    return TakeAwayMenuItemsCompanion(
      id: Value(id),
      menuId: Value(menuId),
      itemNumber: itemNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(itemNumber),
      name: Value(name),
      priceDisplay: Value(priceDisplay),
      priceAmount: priceAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(priceAmount),
      sortOrder: Value(sortOrder),
    );
  }

  factory TakeAwayMenuItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TakeAwayMenuItem(
      id: serializer.fromJson<int>(json['id']),
      menuId: serializer.fromJson<int>(json['menuId']),
      itemNumber: serializer.fromJson<String?>(json['itemNumber']),
      name: serializer.fromJson<String>(json['name']),
      priceDisplay: serializer.fromJson<String>(json['priceDisplay']),
      priceAmount: serializer.fromJson<double?>(json['priceAmount']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'menuId': serializer.toJson<int>(menuId),
      'itemNumber': serializer.toJson<String?>(itemNumber),
      'name': serializer.toJson<String>(name),
      'priceDisplay': serializer.toJson<String>(priceDisplay),
      'priceAmount': serializer.toJson<double?>(priceAmount),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TakeAwayMenuItem copyWith(
          {int? id,
          int? menuId,
          Value<String?> itemNumber = const Value.absent(),
          String? name,
          String? priceDisplay,
          Value<double?> priceAmount = const Value.absent(),
          int? sortOrder}) =>
      TakeAwayMenuItem(
        id: id ?? this.id,
        menuId: menuId ?? this.menuId,
        itemNumber: itemNumber.present ? itemNumber.value : this.itemNumber,
        name: name ?? this.name,
        priceDisplay: priceDisplay ?? this.priceDisplay,
        priceAmount: priceAmount.present ? priceAmount.value : this.priceAmount,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  TakeAwayMenuItem copyWithCompanion(TakeAwayMenuItemsCompanion data) {
    return TakeAwayMenuItem(
      id: data.id.present ? data.id.value : this.id,
      menuId: data.menuId.present ? data.menuId.value : this.menuId,
      itemNumber:
          data.itemNumber.present ? data.itemNumber.value : this.itemNumber,
      name: data.name.present ? data.name.value : this.name,
      priceDisplay: data.priceDisplay.present
          ? data.priceDisplay.value
          : this.priceDisplay,
      priceAmount:
          data.priceAmount.present ? data.priceAmount.value : this.priceAmount,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TakeAwayMenuItem(')
          ..write('id: $id, ')
          ..write('menuId: $menuId, ')
          ..write('itemNumber: $itemNumber, ')
          ..write('name: $name, ')
          ..write('priceDisplay: $priceDisplay, ')
          ..write('priceAmount: $priceAmount, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, menuId, itemNumber, name, priceDisplay, priceAmount, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TakeAwayMenuItem &&
          other.id == this.id &&
          other.menuId == this.menuId &&
          other.itemNumber == this.itemNumber &&
          other.name == this.name &&
          other.priceDisplay == this.priceDisplay &&
          other.priceAmount == this.priceAmount &&
          other.sortOrder == this.sortOrder);
}

class TakeAwayMenuItemsCompanion extends UpdateCompanion<TakeAwayMenuItem> {
  final Value<int> id;
  final Value<int> menuId;
  final Value<String?> itemNumber;
  final Value<String> name;
  final Value<String> priceDisplay;
  final Value<double?> priceAmount;
  final Value<int> sortOrder;
  const TakeAwayMenuItemsCompanion({
    this.id = const Value.absent(),
    this.menuId = const Value.absent(),
    this.itemNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.priceDisplay = const Value.absent(),
    this.priceAmount = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  TakeAwayMenuItemsCompanion.insert({
    this.id = const Value.absent(),
    required int menuId,
    this.itemNumber = const Value.absent(),
    required String name,
    required String priceDisplay,
    this.priceAmount = const Value.absent(),
    this.sortOrder = const Value.absent(),
  })  : menuId = Value(menuId),
        name = Value(name),
        priceDisplay = Value(priceDisplay);
  static Insertable<TakeAwayMenuItem> custom({
    Expression<int>? id,
    Expression<int>? menuId,
    Expression<String>? itemNumber,
    Expression<String>? name,
    Expression<String>? priceDisplay,
    Expression<double>? priceAmount,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (menuId != null) 'menu_id': menuId,
      if (itemNumber != null) 'item_number': itemNumber,
      if (name != null) 'name': name,
      if (priceDisplay != null) 'price_display': priceDisplay,
      if (priceAmount != null) 'price_amount': priceAmount,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  TakeAwayMenuItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? menuId,
      Value<String?>? itemNumber,
      Value<String>? name,
      Value<String>? priceDisplay,
      Value<double?>? priceAmount,
      Value<int>? sortOrder}) {
    return TakeAwayMenuItemsCompanion(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      itemNumber: itemNumber ?? this.itemNumber,
      name: name ?? this.name,
      priceDisplay: priceDisplay ?? this.priceDisplay,
      priceAmount: priceAmount ?? this.priceAmount,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (menuId.present) {
      map['menu_id'] = Variable<int>(menuId.value);
    }
    if (itemNumber.present) {
      map['item_number'] = Variable<String>(itemNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (priceDisplay.present) {
      map['price_display'] = Variable<String>(priceDisplay.value);
    }
    if (priceAmount.present) {
      map['price_amount'] = Variable<double>(priceAmount.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TakeAwayMenuItemsCompanion(')
          ..write('id: $id, ')
          ..write('menuId: $menuId, ')
          ..write('itemNumber: $itemNumber, ')
          ..write('name: $name, ')
          ..write('priceDisplay: $priceDisplay, ')
          ..write('priceAmount: $priceAmount, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TakeAwayOrdersTable extends TakeAwayOrders
    with TableInfo<$TakeAwayOrdersTable, TakeAwayOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TakeAwayOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _menuIdMeta = const VerificationMeta('menuId');
  @override
  late final GeneratedColumn<int> menuId = GeneratedColumn<int>(
      'menu_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, menuId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'take_away_orders';
  @override
  VerificationContext validateIntegrity(Insertable<TakeAwayOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('menu_id')) {
      context.handle(_menuIdMeta,
          menuId.isAcceptableOrUnknown(data['menu_id']!, _menuIdMeta));
    } else if (isInserting) {
      context.missing(_menuIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TakeAwayOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TakeAwayOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      menuId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}menu_id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TakeAwayOrdersTable createAlias(String alias) {
    return $TakeAwayOrdersTable(attachedDatabase, alias);
  }
}

class TakeAwayOrder extends DataClass implements Insertable<TakeAwayOrder> {
  final int id;
  final int menuId;
  final DateTime updatedAt;
  const TakeAwayOrder(
      {required this.id, required this.menuId, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['menu_id'] = Variable<int>(menuId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TakeAwayOrdersCompanion toCompanion(bool nullToAbsent) {
    return TakeAwayOrdersCompanion(
      id: Value(id),
      menuId: Value(menuId),
      updatedAt: Value(updatedAt),
    );
  }

  factory TakeAwayOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TakeAwayOrder(
      id: serializer.fromJson<int>(json['id']),
      menuId: serializer.fromJson<int>(json['menuId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'menuId': serializer.toJson<int>(menuId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TakeAwayOrder copyWith({int? id, int? menuId, DateTime? updatedAt}) =>
      TakeAwayOrder(
        id: id ?? this.id,
        menuId: menuId ?? this.menuId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TakeAwayOrder copyWithCompanion(TakeAwayOrdersCompanion data) {
    return TakeAwayOrder(
      id: data.id.present ? data.id.value : this.id,
      menuId: data.menuId.present ? data.menuId.value : this.menuId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TakeAwayOrder(')
          ..write('id: $id, ')
          ..write('menuId: $menuId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, menuId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TakeAwayOrder &&
          other.id == this.id &&
          other.menuId == this.menuId &&
          other.updatedAt == this.updatedAt);
}

class TakeAwayOrdersCompanion extends UpdateCompanion<TakeAwayOrder> {
  final Value<int> id;
  final Value<int> menuId;
  final Value<DateTime> updatedAt;
  const TakeAwayOrdersCompanion({
    this.id = const Value.absent(),
    this.menuId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TakeAwayOrdersCompanion.insert({
    this.id = const Value.absent(),
    required int menuId,
    required DateTime updatedAt,
  })  : menuId = Value(menuId),
        updatedAt = Value(updatedAt);
  static Insertable<TakeAwayOrder> custom({
    Expression<int>? id,
    Expression<int>? menuId,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (menuId != null) 'menu_id': menuId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TakeAwayOrdersCompanion copyWith(
      {Value<int>? id, Value<int>? menuId, Value<DateTime>? updatedAt}) {
    return TakeAwayOrdersCompanion(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (menuId.present) {
      map['menu_id'] = Variable<int>(menuId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TakeAwayOrdersCompanion(')
          ..write('id: $id, ')
          ..write('menuId: $menuId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TakeAwayOrderLinesTable extends TakeAwayOrderLines
    with TableInfo<$TakeAwayOrderLinesTable, TakeAwayOrderLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TakeAwayOrderLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _menuItemIdMeta =
      const VerificationMeta('menuItemId');
  @override
  late final GeneratedColumn<int> menuItemId = GeneratedColumn<int>(
      'menu_item_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [id, orderId, menuItemId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'take_away_order_lines';
  @override
  VerificationContext validateIntegrity(Insertable<TakeAwayOrderLine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('menu_item_id')) {
      context.handle(
          _menuItemIdMeta,
          menuItemId.isAcceptableOrUnknown(
              data['menu_item_id']!, _menuItemIdMeta));
    } else if (isInserting) {
      context.missing(_menuItemIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TakeAwayOrderLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TakeAwayOrderLine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      menuItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}menu_item_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $TakeAwayOrderLinesTable createAlias(String alias) {
    return $TakeAwayOrderLinesTable(attachedDatabase, alias);
  }
}

class TakeAwayOrderLine extends DataClass
    implements Insertable<TakeAwayOrderLine> {
  final int id;
  final int orderId;
  final int menuItemId;
  final int quantity;
  const TakeAwayOrderLine(
      {required this.id,
      required this.orderId,
      required this.menuItemId,
      required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['menu_item_id'] = Variable<int>(menuItemId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  TakeAwayOrderLinesCompanion toCompanion(bool nullToAbsent) {
    return TakeAwayOrderLinesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      menuItemId: Value(menuItemId),
      quantity: Value(quantity),
    );
  }

  factory TakeAwayOrderLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TakeAwayOrderLine(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      menuItemId: serializer.fromJson<int>(json['menuItemId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'menuItemId': serializer.toJson<int>(menuItemId),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  TakeAwayOrderLine copyWith(
          {int? id, int? orderId, int? menuItemId, int? quantity}) =>
      TakeAwayOrderLine(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        menuItemId: menuItemId ?? this.menuItemId,
        quantity: quantity ?? this.quantity,
      );
  TakeAwayOrderLine copyWithCompanion(TakeAwayOrderLinesCompanion data) {
    return TakeAwayOrderLine(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      menuItemId:
          data.menuItemId.present ? data.menuItemId.value : this.menuItemId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TakeAwayOrderLine(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('menuItemId: $menuItemId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, menuItemId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TakeAwayOrderLine &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.menuItemId == this.menuItemId &&
          other.quantity == this.quantity);
}

class TakeAwayOrderLinesCompanion extends UpdateCompanion<TakeAwayOrderLine> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<int> menuItemId;
  final Value<int> quantity;
  const TakeAwayOrderLinesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.menuItemId = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  TakeAwayOrderLinesCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required int menuItemId,
    this.quantity = const Value.absent(),
  })  : orderId = Value(orderId),
        menuItemId = Value(menuItemId);
  static Insertable<TakeAwayOrderLine> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<int>? menuItemId,
    Expression<int>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (menuItemId != null) 'menu_item_id': menuItemId,
      if (quantity != null) 'quantity': quantity,
    });
  }

  TakeAwayOrderLinesCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<int>? menuItemId,
      Value<int>? quantity}) {
    return TakeAwayOrderLinesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (menuItemId.present) {
      map['menu_item_id'] = Variable<int>(menuItemId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TakeAwayOrderLinesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('menuItemId: $menuItemId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  late final $ShoppingListsTable shoppingLists = $ShoppingListsTable(this);
  late final $ListItemsTable listItems = $ListItemsTable(this);
  late final $CheckOffEventsTable checkOffEvents = $CheckOffEventsTable(this);
  late final $CategoryRankStatsTable categoryRankStats =
      $CategoryRankStatsTable(this);
  late final $ItemRankStatsTable itemRankStats = $ItemRankStatsTable(this);
  late final $ShopStatsRecordsTable shopStatsRecords =
      $ShopStatsRecordsTable(this);
  late final $MealsTable meals = $MealsTable(this);
  late final $MealPlanItemsTable mealPlanItems = $MealPlanItemsTable(this);
  late final $MealIngredientsTable mealIngredients =
      $MealIngredientsTable(this);
  late final $MealCheckOffEventsTable mealCheckOffEvents =
      $MealCheckOffEventsTable(this);
  late final $MealStepsTable mealSteps = $MealStepsTable(this);
  late final $MealTagsTable mealTags = $MealTagsTable(this);
  late final $MealTagAssignmentsTable mealTagAssignments =
      $MealTagAssignmentsTable(this);
  late final $TodoListsTable todoLists = $TodoListsTable(this);
  late final $TodoItemsTable todoItems = $TodoItemsTable(this);
  late final $TodoCompletedArchiveTable todoCompletedArchive =
      $TodoCompletedArchiveTable(this);
  late final $TakeAwayListsTable takeAwayLists = $TakeAwayListsTable(this);
  late final $TakeAwayMenusTable takeAwayMenus = $TakeAwayMenusTable(this);
  late final $TakeAwayMenuItemsTable takeAwayMenuItems =
      $TakeAwayMenuItemsTable(this);
  late final $TakeAwayOrdersTable takeAwayOrders = $TakeAwayOrdersTable(this);
  late final $TakeAwayOrderLinesTable takeAwayOrderLines =
      $TakeAwayOrderLinesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        catalogItems,
        shoppingLists,
        listItems,
        checkOffEvents,
        categoryRankStats,
        itemRankStats,
        shopStatsRecords,
        meals,
        mealPlanItems,
        mealIngredients,
        mealCheckOffEvents,
        mealSteps,
        mealTags,
        mealTagAssignments,
        todoLists,
        todoItems,
        todoCompletedArchive,
        takeAwayLists,
        takeAwayMenus,
        takeAwayMenuItems,
        takeAwayOrders,
        takeAwayOrderLines
      ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int sortOrder,
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()>;
typedef $$CatalogItemsTableCreateCompanionBuilder = CatalogItemsCompanion
    Function({
  Value<int> id,
  required String name,
  required String displayName,
  required String categoryId,
  Value<bool> isUserAdded,
  required DateTime createdAt,
});
typedef $$CatalogItemsTableUpdateCompanionBuilder = CatalogItemsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> displayName,
  Value<String> categoryId,
  Value<bool> isUserAdded,
  Value<DateTime> createdAt,
});

class $$CatalogItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUserAdded => $composableBuilder(
      column: $table.isUserAdded, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CatalogItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUserAdded => $composableBuilder(
      column: $table.isUserAdded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CatalogItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<bool> get isUserAdded => $composableBuilder(
      column: $table.isUserAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CatalogItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogItemsTable,
    CatalogItem,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (
      CatalogItem,
      BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItem>
    ),
    CatalogItem,
    PrefetchHooks Function()> {
  $$CatalogItemsTableTableManager(_$AppDatabase db, $CatalogItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<bool> isUserAdded = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CatalogItemsCompanion(
            id: id,
            name: name,
            displayName: displayName,
            categoryId: categoryId,
            isUserAdded: isUserAdded,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String displayName,
            required String categoryId,
            Value<bool> isUserAdded = const Value.absent(),
            required DateTime createdAt,
          }) =>
              CatalogItemsCompanion.insert(
            id: id,
            name: name,
            displayName: displayName,
            categoryId: categoryId,
            isUserAdded: isUserAdded,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CatalogItemsTable,
    CatalogItem,
    $$CatalogItemsTableFilterComposer,
    $$CatalogItemsTableOrderingComposer,
    $$CatalogItemsTableAnnotationComposer,
    $$CatalogItemsTableCreateCompanionBuilder,
    $$CatalogItemsTableUpdateCompanionBuilder,
    (
      CatalogItem,
      BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItem>
    ),
    CatalogItem,
    PrefetchHooks Function()>;
typedef $$ShoppingListsTableCreateCompanionBuilder = ShoppingListsCompanion
    Function({
  Value<int> id,
  required String name,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> lastCheckOffAt,
  Value<int> currentTripId,
  Value<int> currentTripSequence,
  Value<DateTime?> activeShopStartedAt,
});
typedef $$ShoppingListsTableUpdateCompanionBuilder = ShoppingListsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastCheckOffAt,
  Value<int> currentTripId,
  Value<int> currentTripSequence,
  Value<DateTime?> activeShopStartedAt,
});

class $$ShoppingListsTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastCheckOffAt => $composableBuilder(
      column: $table.lastCheckOffAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentTripId => $composableBuilder(
      column: $table.currentTripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentTripSequence => $composableBuilder(
      column: $table.currentTripSequence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get activeShopStartedAt => $composableBuilder(
      column: $table.activeShopStartedAt,
      builder: (column) => ColumnFilters(column));
}

class $$ShoppingListsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastCheckOffAt => $composableBuilder(
      column: $table.lastCheckOffAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentTripId => $composableBuilder(
      column: $table.currentTripId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentTripSequence => $composableBuilder(
      column: $table.currentTripSequence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get activeShopStartedAt => $composableBuilder(
      column: $table.activeShopStartedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ShoppingListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCheckOffAt => $composableBuilder(
      column: $table.lastCheckOffAt, builder: (column) => column);

  GeneratedColumn<int> get currentTripId => $composableBuilder(
      column: $table.currentTripId, builder: (column) => column);

  GeneratedColumn<int> get currentTripSequence => $composableBuilder(
      column: $table.currentTripSequence, builder: (column) => column);

  GeneratedColumn<DateTime> get activeShopStartedAt => $composableBuilder(
      column: $table.activeShopStartedAt, builder: (column) => column);
}

class $$ShoppingListsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShoppingListsTable,
    ShoppingList,
    $$ShoppingListsTableFilterComposer,
    $$ShoppingListsTableOrderingComposer,
    $$ShoppingListsTableAnnotationComposer,
    $$ShoppingListsTableCreateCompanionBuilder,
    $$ShoppingListsTableUpdateCompanionBuilder,
    (
      ShoppingList,
      BaseReferences<_$AppDatabase, $ShoppingListsTable, ShoppingList>
    ),
    ShoppingList,
    PrefetchHooks Function()> {
  $$ShoppingListsTableTableManager(_$AppDatabase db, $ShoppingListsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastCheckOffAt = const Value.absent(),
            Value<int> currentTripId = const Value.absent(),
            Value<int> currentTripSequence = const Value.absent(),
            Value<DateTime?> activeShopStartedAt = const Value.absent(),
          }) =>
              ShoppingListsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastCheckOffAt: lastCheckOffAt,
            currentTripId: currentTripId,
            currentTripSequence: currentTripSequence,
            activeShopStartedAt: activeShopStartedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> lastCheckOffAt = const Value.absent(),
            Value<int> currentTripId = const Value.absent(),
            Value<int> currentTripSequence = const Value.absent(),
            Value<DateTime?> activeShopStartedAt = const Value.absent(),
          }) =>
              ShoppingListsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastCheckOffAt: lastCheckOffAt,
            currentTripId: currentTripId,
            currentTripSequence: currentTripSequence,
            activeShopStartedAt: activeShopStartedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShoppingListsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShoppingListsTable,
    ShoppingList,
    $$ShoppingListsTableFilterComposer,
    $$ShoppingListsTableOrderingComposer,
    $$ShoppingListsTableAnnotationComposer,
    $$ShoppingListsTableCreateCompanionBuilder,
    $$ShoppingListsTableUpdateCompanionBuilder,
    (
      ShoppingList,
      BaseReferences<_$AppDatabase, $ShoppingListsTable, ShoppingList>
    ),
    ShoppingList,
    PrefetchHooks Function()>;
typedef $$ListItemsTableCreateCompanionBuilder = ListItemsCompanion Function({
  Value<int> id,
  required int listId,
  Value<int?> catalogItemId,
  required String displayName,
  required String categoryId,
  Value<double?> quantityValue,
  Value<String?> quantityUnit,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  required DateTime addedAt,
});
typedef $$ListItemsTableUpdateCompanionBuilder = ListItemsCompanion Function({
  Value<int> id,
  Value<int> listId,
  Value<int?> catalogItemId,
  Value<String> displayName,
  Value<String> categoryId,
  Value<double?> quantityValue,
  Value<String?> quantityUnit,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<DateTime> addedAt,
});

class $$ListItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ListItemsTable> {
  $$ListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityValue => $composableBuilder(
      column: $table.quantityValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantityUnit => $composableBuilder(
      column: $table.quantityUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$ListItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListItemsTable> {
  $$ListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityValue => $composableBuilder(
      column: $table.quantityValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
      column: $table.quantityUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$ListItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListItemsTable> {
  $$ListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<double> get quantityValue => $composableBuilder(
      column: $table.quantityValue, builder: (column) => column);

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
      column: $table.quantityUnit, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$ListItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListItemsTable,
    ListItem,
    $$ListItemsTableFilterComposer,
    $$ListItemsTableOrderingComposer,
    $$ListItemsTableAnnotationComposer,
    $$ListItemsTableCreateCompanionBuilder,
    $$ListItemsTableUpdateCompanionBuilder,
    (ListItem, BaseReferences<_$AppDatabase, $ListItemsTable, ListItem>),
    ListItem,
    PrefetchHooks Function()> {
  $$ListItemsTableTableManager(_$AppDatabase db, $ListItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> listId = const Value.absent(),
            Value<int?> catalogItemId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<double?> quantityValue = const Value.absent(),
            Value<String?> quantityUnit = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
          }) =>
              ListItemsCompanion(
            id: id,
            listId: listId,
            catalogItemId: catalogItemId,
            displayName: displayName,
            categoryId: categoryId,
            quantityValue: quantityValue,
            quantityUnit: quantityUnit,
            isCompleted: isCompleted,
            completedAt: completedAt,
            addedAt: addedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int listId,
            Value<int?> catalogItemId = const Value.absent(),
            required String displayName,
            required String categoryId,
            Value<double?> quantityValue = const Value.absent(),
            Value<String?> quantityUnit = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            required DateTime addedAt,
          }) =>
              ListItemsCompanion.insert(
            id: id,
            listId: listId,
            catalogItemId: catalogItemId,
            displayName: displayName,
            categoryId: categoryId,
            quantityValue: quantityValue,
            quantityUnit: quantityUnit,
            isCompleted: isCompleted,
            completedAt: completedAt,
            addedAt: addedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ListItemsTable,
    ListItem,
    $$ListItemsTableFilterComposer,
    $$ListItemsTableOrderingComposer,
    $$ListItemsTableAnnotationComposer,
    $$ListItemsTableCreateCompanionBuilder,
    $$ListItemsTableUpdateCompanionBuilder,
    (ListItem, BaseReferences<_$AppDatabase, $ListItemsTable, ListItem>),
    ListItem,
    PrefetchHooks Function()>;
typedef $$CheckOffEventsTableCreateCompanionBuilder = CheckOffEventsCompanion
    Function({
  Value<int> id,
  required int listId,
  required int listItemId,
  required String categoryId,
  Value<int?> catalogItemId,
  required DateTime checkedAt,
  required int sequenceIndex,
  required int tripId,
  Value<double> weight,
});
typedef $$CheckOffEventsTableUpdateCompanionBuilder = CheckOffEventsCompanion
    Function({
  Value<int> id,
  Value<int> listId,
  Value<int> listItemId,
  Value<String> categoryId,
  Value<int?> catalogItemId,
  Value<DateTime> checkedAt,
  Value<int> sequenceIndex,
  Value<int> tripId,
  Value<double> weight,
});

class $$CheckOffEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckOffEventsTable> {
  $$CheckOffEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listItemId => $composableBuilder(
      column: $table.listItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
      column: $table.checkedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));
}

class $$CheckOffEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckOffEventsTable> {
  $$CheckOffEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listItemId => $composableBuilder(
      column: $table.listItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
      column: $table.checkedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));
}

class $$CheckOffEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckOffEventsTable> {
  $$CheckOffEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<int> get listItemId => $composableBuilder(
      column: $table.listItemId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);

  GeneratedColumn<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex, builder: (column) => column);

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);
}

class $$CheckOffEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CheckOffEventsTable,
    CheckOffEvent,
    $$CheckOffEventsTableFilterComposer,
    $$CheckOffEventsTableOrderingComposer,
    $$CheckOffEventsTableAnnotationComposer,
    $$CheckOffEventsTableCreateCompanionBuilder,
    $$CheckOffEventsTableUpdateCompanionBuilder,
    (
      CheckOffEvent,
      BaseReferences<_$AppDatabase, $CheckOffEventsTable, CheckOffEvent>
    ),
    CheckOffEvent,
    PrefetchHooks Function()> {
  $$CheckOffEventsTableTableManager(
      _$AppDatabase db, $CheckOffEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckOffEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckOffEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckOffEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> listId = const Value.absent(),
            Value<int> listItemId = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<int?> catalogItemId = const Value.absent(),
            Value<DateTime> checkedAt = const Value.absent(),
            Value<int> sequenceIndex = const Value.absent(),
            Value<int> tripId = const Value.absent(),
            Value<double> weight = const Value.absent(),
          }) =>
              CheckOffEventsCompanion(
            id: id,
            listId: listId,
            listItemId: listItemId,
            categoryId: categoryId,
            catalogItemId: catalogItemId,
            checkedAt: checkedAt,
            sequenceIndex: sequenceIndex,
            tripId: tripId,
            weight: weight,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int listId,
            required int listItemId,
            required String categoryId,
            Value<int?> catalogItemId = const Value.absent(),
            required DateTime checkedAt,
            required int sequenceIndex,
            required int tripId,
            Value<double> weight = const Value.absent(),
          }) =>
              CheckOffEventsCompanion.insert(
            id: id,
            listId: listId,
            listItemId: listItemId,
            categoryId: categoryId,
            catalogItemId: catalogItemId,
            checkedAt: checkedAt,
            sequenceIndex: sequenceIndex,
            tripId: tripId,
            weight: weight,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CheckOffEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CheckOffEventsTable,
    CheckOffEvent,
    $$CheckOffEventsTableFilterComposer,
    $$CheckOffEventsTableOrderingComposer,
    $$CheckOffEventsTableAnnotationComposer,
    $$CheckOffEventsTableCreateCompanionBuilder,
    $$CheckOffEventsTableUpdateCompanionBuilder,
    (
      CheckOffEvent,
      BaseReferences<_$AppDatabase, $CheckOffEventsTable, CheckOffEvent>
    ),
    CheckOffEvent,
    PrefetchHooks Function()>;
typedef $$CategoryRankStatsTableCreateCompanionBuilder
    = CategoryRankStatsCompanion Function({
  required int listId,
  required String categoryId,
  required double medianRank,
  required int sampleCount,
  required DateTime lastUpdated,
  Value<int> rowid,
});
typedef $$CategoryRankStatsTableUpdateCompanionBuilder
    = CategoryRankStatsCompanion Function({
  Value<int> listId,
  Value<String> categoryId,
  Value<double> medianRank,
  Value<int> sampleCount,
  Value<DateTime> lastUpdated,
  Value<int> rowid,
});

class $$CategoryRankStatsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRankStatsTable> {
  $$CategoryRankStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get medianRank => $composableBuilder(
      column: $table.medianRank, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sampleCount => $composableBuilder(
      column: $table.sampleCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$CategoryRankStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRankStatsTable> {
  $$CategoryRankStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get medianRank => $composableBuilder(
      column: $table.medianRank, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sampleCount => $composableBuilder(
      column: $table.sampleCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$CategoryRankStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRankStatsTable> {
  $$CategoryRankStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<double> get medianRank => $composableBuilder(
      column: $table.medianRank, builder: (column) => column);

  GeneratedColumn<int> get sampleCount => $composableBuilder(
      column: $table.sampleCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);
}

class $$CategoryRankStatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoryRankStatsTable,
    CategoryRankStat,
    $$CategoryRankStatsTableFilterComposer,
    $$CategoryRankStatsTableOrderingComposer,
    $$CategoryRankStatsTableAnnotationComposer,
    $$CategoryRankStatsTableCreateCompanionBuilder,
    $$CategoryRankStatsTableUpdateCompanionBuilder,
    (
      CategoryRankStat,
      BaseReferences<_$AppDatabase, $CategoryRankStatsTable, CategoryRankStat>
    ),
    CategoryRankStat,
    PrefetchHooks Function()> {
  $$CategoryRankStatsTableTableManager(
      _$AppDatabase db, $CategoryRankStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRankStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRankStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRankStatsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> listId = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<double> medianRank = const Value.absent(),
            Value<int> sampleCount = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoryRankStatsCompanion(
            listId: listId,
            categoryId: categoryId,
            medianRank: medianRank,
            sampleCount: sampleCount,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int listId,
            required String categoryId,
            required double medianRank,
            required int sampleCount,
            required DateTime lastUpdated,
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoryRankStatsCompanion.insert(
            listId: listId,
            categoryId: categoryId,
            medianRank: medianRank,
            sampleCount: sampleCount,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoryRankStatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoryRankStatsTable,
    CategoryRankStat,
    $$CategoryRankStatsTableFilterComposer,
    $$CategoryRankStatsTableOrderingComposer,
    $$CategoryRankStatsTableAnnotationComposer,
    $$CategoryRankStatsTableCreateCompanionBuilder,
    $$CategoryRankStatsTableUpdateCompanionBuilder,
    (
      CategoryRankStat,
      BaseReferences<_$AppDatabase, $CategoryRankStatsTable, CategoryRankStat>
    ),
    CategoryRankStat,
    PrefetchHooks Function()>;
typedef $$ItemRankStatsTableCreateCompanionBuilder = ItemRankStatsCompanion
    Function({
  required int listId,
  required int catalogItemId,
  required String categoryId,
  required double medianRank,
  required int sampleCount,
  required DateTime lastUpdated,
  Value<int> rowid,
});
typedef $$ItemRankStatsTableUpdateCompanionBuilder = ItemRankStatsCompanion
    Function({
  Value<int> listId,
  Value<int> catalogItemId,
  Value<String> categoryId,
  Value<double> medianRank,
  Value<int> sampleCount,
  Value<DateTime> lastUpdated,
  Value<int> rowid,
});

class $$ItemRankStatsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemRankStatsTable> {
  $$ItemRankStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get medianRank => $composableBuilder(
      column: $table.medianRank, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sampleCount => $composableBuilder(
      column: $table.sampleCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$ItemRankStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemRankStatsTable> {
  $$ItemRankStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get medianRank => $composableBuilder(
      column: $table.medianRank, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sampleCount => $composableBuilder(
      column: $table.sampleCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$ItemRankStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemRankStatsTable> {
  $$ItemRankStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<double> get medianRank => $composableBuilder(
      column: $table.medianRank, builder: (column) => column);

  GeneratedColumn<int> get sampleCount => $composableBuilder(
      column: $table.sampleCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);
}

class $$ItemRankStatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemRankStatsTable,
    ItemRankStat,
    $$ItemRankStatsTableFilterComposer,
    $$ItemRankStatsTableOrderingComposer,
    $$ItemRankStatsTableAnnotationComposer,
    $$ItemRankStatsTableCreateCompanionBuilder,
    $$ItemRankStatsTableUpdateCompanionBuilder,
    (
      ItemRankStat,
      BaseReferences<_$AppDatabase, $ItemRankStatsTable, ItemRankStat>
    ),
    ItemRankStat,
    PrefetchHooks Function()> {
  $$ItemRankStatsTableTableManager(_$AppDatabase db, $ItemRankStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemRankStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemRankStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemRankStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> listId = const Value.absent(),
            Value<int> catalogItemId = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<double> medianRank = const Value.absent(),
            Value<int> sampleCount = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemRankStatsCompanion(
            listId: listId,
            catalogItemId: catalogItemId,
            categoryId: categoryId,
            medianRank: medianRank,
            sampleCount: sampleCount,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int listId,
            required int catalogItemId,
            required String categoryId,
            required double medianRank,
            required int sampleCount,
            required DateTime lastUpdated,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemRankStatsCompanion.insert(
            listId: listId,
            catalogItemId: catalogItemId,
            categoryId: categoryId,
            medianRank: medianRank,
            sampleCount: sampleCount,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemRankStatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemRankStatsTable,
    ItemRankStat,
    $$ItemRankStatsTableFilterComposer,
    $$ItemRankStatsTableOrderingComposer,
    $$ItemRankStatsTableAnnotationComposer,
    $$ItemRankStatsTableCreateCompanionBuilder,
    $$ItemRankStatsTableUpdateCompanionBuilder,
    (
      ItemRankStat,
      BaseReferences<_$AppDatabase, $ItemRankStatsTable, ItemRankStat>
    ),
    ItemRankStat,
    PrefetchHooks Function()>;
typedef $$ShopStatsRecordsTableCreateCompanionBuilder
    = ShopStatsRecordsCompanion Function({
  Value<int> id,
  required int listId,
  required DateTime startedAt,
  required DateTime completedAt,
  required int itemCount,
});
typedef $$ShopStatsRecordsTableUpdateCompanionBuilder
    = ShopStatsRecordsCompanion Function({
  Value<int> id,
  Value<int> listId,
  Value<DateTime> startedAt,
  Value<DateTime> completedAt,
  Value<int> itemCount,
});

class $$ShopStatsRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ShopStatsRecordsTable> {
  $$ShopStatsRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemCount => $composableBuilder(
      column: $table.itemCount, builder: (column) => ColumnFilters(column));
}

class $$ShopStatsRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopStatsRecordsTable> {
  $$ShopStatsRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemCount => $composableBuilder(
      column: $table.itemCount, builder: (column) => ColumnOrderings(column));
}

class $$ShopStatsRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopStatsRecordsTable> {
  $$ShopStatsRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);
}

class $$ShopStatsRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShopStatsRecordsTable,
    ShopStatsRecord,
    $$ShopStatsRecordsTableFilterComposer,
    $$ShopStatsRecordsTableOrderingComposer,
    $$ShopStatsRecordsTableAnnotationComposer,
    $$ShopStatsRecordsTableCreateCompanionBuilder,
    $$ShopStatsRecordsTableUpdateCompanionBuilder,
    (
      ShopStatsRecord,
      BaseReferences<_$AppDatabase, $ShopStatsRecordsTable, ShopStatsRecord>
    ),
    ShopStatsRecord,
    PrefetchHooks Function()> {
  $$ShopStatsRecordsTableTableManager(
      _$AppDatabase db, $ShopStatsRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopStatsRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopStatsRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopStatsRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> listId = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<int> itemCount = const Value.absent(),
          }) =>
              ShopStatsRecordsCompanion(
            id: id,
            listId: listId,
            startedAt: startedAt,
            completedAt: completedAt,
            itemCount: itemCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int listId,
            required DateTime startedAt,
            required DateTime completedAt,
            required int itemCount,
          }) =>
              ShopStatsRecordsCompanion.insert(
            id: id,
            listId: listId,
            startedAt: startedAt,
            completedAt: completedAt,
            itemCount: itemCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShopStatsRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShopStatsRecordsTable,
    ShopStatsRecord,
    $$ShopStatsRecordsTableFilterComposer,
    $$ShopStatsRecordsTableOrderingComposer,
    $$ShopStatsRecordsTableAnnotationComposer,
    $$ShopStatsRecordsTableCreateCompanionBuilder,
    $$ShopStatsRecordsTableUpdateCompanionBuilder,
    (
      ShopStatsRecord,
      BaseReferences<_$AppDatabase, $ShopStatsRecordsTable, ShopStatsRecord>
    ),
    ShopStatsRecord,
    PrefetchHooks Function()>;
typedef $$MealsTableCreateCompanionBuilder = MealsCompanion Function({
  Value<int> id,
  required String name,
  required String displayName,
  Value<String?> photoPath,
  Value<String?> notes,
  Value<int> portions,
  Value<String?> recipeLink,
  Value<bool> isUserAdded,
  required DateTime createdAt,
});
typedef $$MealsTableUpdateCompanionBuilder = MealsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> displayName,
  Value<String?> photoPath,
  Value<String?> notes,
  Value<int> portions,
  Value<String?> recipeLink,
  Value<bool> isUserAdded,
  Value<DateTime> createdAt,
});

class $$MealsTableFilterComposer extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get portions => $composableBuilder(
      column: $table.portions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recipeLink => $composableBuilder(
      column: $table.recipeLink, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUserAdded => $composableBuilder(
      column: $table.isUserAdded, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MealsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get portions => $composableBuilder(
      column: $table.portions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipeLink => $composableBuilder(
      column: $table.recipeLink, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUserAdded => $composableBuilder(
      column: $table.isUserAdded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get portions =>
      $composableBuilder(column: $table.portions, builder: (column) => column);

  GeneratedColumn<String> get recipeLink => $composableBuilder(
      column: $table.recipeLink, builder: (column) => column);

  GeneratedColumn<bool> get isUserAdded => $composableBuilder(
      column: $table.isUserAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MealsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealsTable,
    Meal,
    $$MealsTableFilterComposer,
    $$MealsTableOrderingComposer,
    $$MealsTableAnnotationComposer,
    $$MealsTableCreateCompanionBuilder,
    $$MealsTableUpdateCompanionBuilder,
    (Meal, BaseReferences<_$AppDatabase, $MealsTable, Meal>),
    Meal,
    PrefetchHooks Function()> {
  $$MealsTableTableManager(_$AppDatabase db, $MealsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> portions = const Value.absent(),
            Value<String?> recipeLink = const Value.absent(),
            Value<bool> isUserAdded = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MealsCompanion(
            id: id,
            name: name,
            displayName: displayName,
            photoPath: photoPath,
            notes: notes,
            portions: portions,
            recipeLink: recipeLink,
            isUserAdded: isUserAdded,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String displayName,
            Value<String?> photoPath = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> portions = const Value.absent(),
            Value<String?> recipeLink = const Value.absent(),
            Value<bool> isUserAdded = const Value.absent(),
            required DateTime createdAt,
          }) =>
              MealsCompanion.insert(
            id: id,
            name: name,
            displayName: displayName,
            photoPath: photoPath,
            notes: notes,
            portions: portions,
            recipeLink: recipeLink,
            isUserAdded: isUserAdded,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealsTable,
    Meal,
    $$MealsTableFilterComposer,
    $$MealsTableOrderingComposer,
    $$MealsTableAnnotationComposer,
    $$MealsTableCreateCompanionBuilder,
    $$MealsTableUpdateCompanionBuilder,
    (Meal, BaseReferences<_$AppDatabase, $MealsTable, Meal>),
    Meal,
    PrefetchHooks Function()>;
typedef $$MealPlanItemsTableCreateCompanionBuilder = MealPlanItemsCompanion
    Function({
  Value<int> id,
  required int mealId,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  required DateTime addedAt,
});
typedef $$MealPlanItemsTableUpdateCompanionBuilder = MealPlanItemsCompanion
    Function({
  Value<int> id,
  Value<int> mealId,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<DateTime> addedAt,
});

class $$MealPlanItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MealPlanItemsTable> {
  $$MealPlanItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$MealPlanItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealPlanItemsTable> {
  $$MealPlanItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$MealPlanItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealPlanItemsTable> {
  $$MealPlanItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mealId =>
      $composableBuilder(column: $table.mealId, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$MealPlanItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealPlanItemsTable,
    MealPlanItem,
    $$MealPlanItemsTableFilterComposer,
    $$MealPlanItemsTableOrderingComposer,
    $$MealPlanItemsTableAnnotationComposer,
    $$MealPlanItemsTableCreateCompanionBuilder,
    $$MealPlanItemsTableUpdateCompanionBuilder,
    (
      MealPlanItem,
      BaseReferences<_$AppDatabase, $MealPlanItemsTable, MealPlanItem>
    ),
    MealPlanItem,
    PrefetchHooks Function()> {
  $$MealPlanItemsTableTableManager(_$AppDatabase db, $MealPlanItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealPlanItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealPlanItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealPlanItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> mealId = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
          }) =>
              MealPlanItemsCompanion(
            id: id,
            mealId: mealId,
            isCompleted: isCompleted,
            completedAt: completedAt,
            addedAt: addedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int mealId,
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            required DateTime addedAt,
          }) =>
              MealPlanItemsCompanion.insert(
            id: id,
            mealId: mealId,
            isCompleted: isCompleted,
            completedAt: completedAt,
            addedAt: addedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealPlanItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealPlanItemsTable,
    MealPlanItem,
    $$MealPlanItemsTableFilterComposer,
    $$MealPlanItemsTableOrderingComposer,
    $$MealPlanItemsTableAnnotationComposer,
    $$MealPlanItemsTableCreateCompanionBuilder,
    $$MealPlanItemsTableUpdateCompanionBuilder,
    (
      MealPlanItem,
      BaseReferences<_$AppDatabase, $MealPlanItemsTable, MealPlanItem>
    ),
    MealPlanItem,
    PrefetchHooks Function()>;
typedef $$MealIngredientsTableCreateCompanionBuilder = MealIngredientsCompanion
    Function({
  Value<int> id,
  required int mealId,
  Value<int?> catalogItemId,
  required String displayName,
  Value<bool> addToShoppingList,
});
typedef $$MealIngredientsTableUpdateCompanionBuilder = MealIngredientsCompanion
    Function({
  Value<int> id,
  Value<int> mealId,
  Value<int?> catalogItemId,
  Value<String> displayName,
  Value<bool> addToShoppingList,
});

class $$MealIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $MealIngredientsTable> {
  $$MealIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get addToShoppingList => $composableBuilder(
      column: $table.addToShoppingList,
      builder: (column) => ColumnFilters(column));
}

class $$MealIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealIngredientsTable> {
  $$MealIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get addToShoppingList => $composableBuilder(
      column: $table.addToShoppingList,
      builder: (column) => ColumnOrderings(column));
}

class $$MealIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealIngredientsTable> {
  $$MealIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mealId =>
      $composableBuilder(column: $table.mealId, builder: (column) => column);

  GeneratedColumn<int> get catalogItemId => $composableBuilder(
      column: $table.catalogItemId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<bool> get addToShoppingList => $composableBuilder(
      column: $table.addToShoppingList, builder: (column) => column);
}

class $$MealIngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealIngredientsTable,
    MealIngredient,
    $$MealIngredientsTableFilterComposer,
    $$MealIngredientsTableOrderingComposer,
    $$MealIngredientsTableAnnotationComposer,
    $$MealIngredientsTableCreateCompanionBuilder,
    $$MealIngredientsTableUpdateCompanionBuilder,
    (
      MealIngredient,
      BaseReferences<_$AppDatabase, $MealIngredientsTable, MealIngredient>
    ),
    MealIngredient,
    PrefetchHooks Function()> {
  $$MealIngredientsTableTableManager(
      _$AppDatabase db, $MealIngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealIngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> mealId = const Value.absent(),
            Value<int?> catalogItemId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<bool> addToShoppingList = const Value.absent(),
          }) =>
              MealIngredientsCompanion(
            id: id,
            mealId: mealId,
            catalogItemId: catalogItemId,
            displayName: displayName,
            addToShoppingList: addToShoppingList,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int mealId,
            Value<int?> catalogItemId = const Value.absent(),
            required String displayName,
            Value<bool> addToShoppingList = const Value.absent(),
          }) =>
              MealIngredientsCompanion.insert(
            id: id,
            mealId: mealId,
            catalogItemId: catalogItemId,
            displayName: displayName,
            addToShoppingList: addToShoppingList,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealIngredientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealIngredientsTable,
    MealIngredient,
    $$MealIngredientsTableFilterComposer,
    $$MealIngredientsTableOrderingComposer,
    $$MealIngredientsTableAnnotationComposer,
    $$MealIngredientsTableCreateCompanionBuilder,
    $$MealIngredientsTableUpdateCompanionBuilder,
    (
      MealIngredient,
      BaseReferences<_$AppDatabase, $MealIngredientsTable, MealIngredient>
    ),
    MealIngredient,
    PrefetchHooks Function()>;
typedef $$MealCheckOffEventsTableCreateCompanionBuilder
    = MealCheckOffEventsCompanion Function({
  Value<int> id,
  required int mealId,
  Value<int?> mealPlanItemId,
  required DateTime checkedAt,
});
typedef $$MealCheckOffEventsTableUpdateCompanionBuilder
    = MealCheckOffEventsCompanion Function({
  Value<int> id,
  Value<int> mealId,
  Value<int?> mealPlanItemId,
  Value<DateTime> checkedAt,
});

class $$MealCheckOffEventsTableFilterComposer
    extends Composer<_$AppDatabase, $MealCheckOffEventsTable> {
  $$MealCheckOffEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mealPlanItemId => $composableBuilder(
      column: $table.mealPlanItemId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
      column: $table.checkedAt, builder: (column) => ColumnFilters(column));
}

class $$MealCheckOffEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealCheckOffEventsTable> {
  $$MealCheckOffEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mealPlanItemId => $composableBuilder(
      column: $table.mealPlanItemId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
      column: $table.checkedAt, builder: (column) => ColumnOrderings(column));
}

class $$MealCheckOffEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealCheckOffEventsTable> {
  $$MealCheckOffEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mealId =>
      $composableBuilder(column: $table.mealId, builder: (column) => column);

  GeneratedColumn<int> get mealPlanItemId => $composableBuilder(
      column: $table.mealPlanItemId, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);
}

class $$MealCheckOffEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealCheckOffEventsTable,
    MealCheckOffEvent,
    $$MealCheckOffEventsTableFilterComposer,
    $$MealCheckOffEventsTableOrderingComposer,
    $$MealCheckOffEventsTableAnnotationComposer,
    $$MealCheckOffEventsTableCreateCompanionBuilder,
    $$MealCheckOffEventsTableUpdateCompanionBuilder,
    (
      MealCheckOffEvent,
      BaseReferences<_$AppDatabase, $MealCheckOffEventsTable, MealCheckOffEvent>
    ),
    MealCheckOffEvent,
    PrefetchHooks Function()> {
  $$MealCheckOffEventsTableTableManager(
      _$AppDatabase db, $MealCheckOffEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealCheckOffEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealCheckOffEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealCheckOffEventsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> mealId = const Value.absent(),
            Value<int?> mealPlanItemId = const Value.absent(),
            Value<DateTime> checkedAt = const Value.absent(),
          }) =>
              MealCheckOffEventsCompanion(
            id: id,
            mealId: mealId,
            mealPlanItemId: mealPlanItemId,
            checkedAt: checkedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int mealId,
            Value<int?> mealPlanItemId = const Value.absent(),
            required DateTime checkedAt,
          }) =>
              MealCheckOffEventsCompanion.insert(
            id: id,
            mealId: mealId,
            mealPlanItemId: mealPlanItemId,
            checkedAt: checkedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealCheckOffEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealCheckOffEventsTable,
    MealCheckOffEvent,
    $$MealCheckOffEventsTableFilterComposer,
    $$MealCheckOffEventsTableOrderingComposer,
    $$MealCheckOffEventsTableAnnotationComposer,
    $$MealCheckOffEventsTableCreateCompanionBuilder,
    $$MealCheckOffEventsTableUpdateCompanionBuilder,
    (
      MealCheckOffEvent,
      BaseReferences<_$AppDatabase, $MealCheckOffEventsTable, MealCheckOffEvent>
    ),
    MealCheckOffEvent,
    PrefetchHooks Function()>;
typedef $$MealStepsTableCreateCompanionBuilder = MealStepsCompanion Function({
  Value<int> id,
  required int mealId,
  required int stepOrder,
  required String instruction,
});
typedef $$MealStepsTableUpdateCompanionBuilder = MealStepsCompanion Function({
  Value<int> id,
  Value<int> mealId,
  Value<int> stepOrder,
  Value<String> instruction,
});

class $$MealStepsTableFilterComposer
    extends Composer<_$AppDatabase, $MealStepsTable> {
  $$MealStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stepOrder => $composableBuilder(
      column: $table.stepOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instruction => $composableBuilder(
      column: $table.instruction, builder: (column) => ColumnFilters(column));
}

class $$MealStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealStepsTable> {
  $$MealStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stepOrder => $composableBuilder(
      column: $table.stepOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instruction => $composableBuilder(
      column: $table.instruction, builder: (column) => ColumnOrderings(column));
}

class $$MealStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealStepsTable> {
  $$MealStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mealId =>
      $composableBuilder(column: $table.mealId, builder: (column) => column);

  GeneratedColumn<int> get stepOrder =>
      $composableBuilder(column: $table.stepOrder, builder: (column) => column);

  GeneratedColumn<String> get instruction => $composableBuilder(
      column: $table.instruction, builder: (column) => column);
}

class $$MealStepsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealStepsTable,
    MealStep,
    $$MealStepsTableFilterComposer,
    $$MealStepsTableOrderingComposer,
    $$MealStepsTableAnnotationComposer,
    $$MealStepsTableCreateCompanionBuilder,
    $$MealStepsTableUpdateCompanionBuilder,
    (MealStep, BaseReferences<_$AppDatabase, $MealStepsTable, MealStep>),
    MealStep,
    PrefetchHooks Function()> {
  $$MealStepsTableTableManager(_$AppDatabase db, $MealStepsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> mealId = const Value.absent(),
            Value<int> stepOrder = const Value.absent(),
            Value<String> instruction = const Value.absent(),
          }) =>
              MealStepsCompanion(
            id: id,
            mealId: mealId,
            stepOrder: stepOrder,
            instruction: instruction,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int mealId,
            required int stepOrder,
            required String instruction,
          }) =>
              MealStepsCompanion.insert(
            id: id,
            mealId: mealId,
            stepOrder: stepOrder,
            instruction: instruction,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealStepsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealStepsTable,
    MealStep,
    $$MealStepsTableFilterComposer,
    $$MealStepsTableOrderingComposer,
    $$MealStepsTableAnnotationComposer,
    $$MealStepsTableCreateCompanionBuilder,
    $$MealStepsTableUpdateCompanionBuilder,
    (MealStep, BaseReferences<_$AppDatabase, $MealStepsTable, MealStep>),
    MealStep,
    PrefetchHooks Function()>;
typedef $$MealTagsTableCreateCompanionBuilder = MealTagsCompanion Function({
  Value<int> id,
  required String name,
  required String displayName,
});
typedef $$MealTagsTableUpdateCompanionBuilder = MealTagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> displayName,
});

class $$MealTagsTableFilterComposer
    extends Composer<_$AppDatabase, $MealTagsTable> {
  $$MealTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));
}

class $$MealTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealTagsTable> {
  $$MealTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));
}

class $$MealTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealTagsTable> {
  $$MealTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);
}

class $$MealTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealTagsTable,
    MealTag,
    $$MealTagsTableFilterComposer,
    $$MealTagsTableOrderingComposer,
    $$MealTagsTableAnnotationComposer,
    $$MealTagsTableCreateCompanionBuilder,
    $$MealTagsTableUpdateCompanionBuilder,
    (MealTag, BaseReferences<_$AppDatabase, $MealTagsTable, MealTag>),
    MealTag,
    PrefetchHooks Function()> {
  $$MealTagsTableTableManager(_$AppDatabase db, $MealTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> displayName = const Value.absent(),
          }) =>
              MealTagsCompanion(
            id: id,
            name: name,
            displayName: displayName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String displayName,
          }) =>
              MealTagsCompanion.insert(
            id: id,
            name: name,
            displayName: displayName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealTagsTable,
    MealTag,
    $$MealTagsTableFilterComposer,
    $$MealTagsTableOrderingComposer,
    $$MealTagsTableAnnotationComposer,
    $$MealTagsTableCreateCompanionBuilder,
    $$MealTagsTableUpdateCompanionBuilder,
    (MealTag, BaseReferences<_$AppDatabase, $MealTagsTable, MealTag>),
    MealTag,
    PrefetchHooks Function()>;
typedef $$MealTagAssignmentsTableCreateCompanionBuilder
    = MealTagAssignmentsCompanion Function({
  required int mealId,
  required int tagId,
  Value<int> rowid,
});
typedef $$MealTagAssignmentsTableUpdateCompanionBuilder
    = MealTagAssignmentsCompanion Function({
  Value<int> mealId,
  Value<int> tagId,
  Value<int> rowid,
});

class $$MealTagAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $MealTagAssignmentsTable> {
  $$MealTagAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));
}

class $$MealTagAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealTagAssignmentsTable> {
  $$MealTagAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));
}

class $$MealTagAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealTagAssignmentsTable> {
  $$MealTagAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get mealId =>
      $composableBuilder(column: $table.mealId, builder: (column) => column);

  GeneratedColumn<int> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$MealTagAssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealTagAssignmentsTable,
    MealTagAssignment,
    $$MealTagAssignmentsTableFilterComposer,
    $$MealTagAssignmentsTableOrderingComposer,
    $$MealTagAssignmentsTableAnnotationComposer,
    $$MealTagAssignmentsTableCreateCompanionBuilder,
    $$MealTagAssignmentsTableUpdateCompanionBuilder,
    (
      MealTagAssignment,
      BaseReferences<_$AppDatabase, $MealTagAssignmentsTable, MealTagAssignment>
    ),
    MealTagAssignment,
    PrefetchHooks Function()> {
  $$MealTagAssignmentsTableTableManager(
      _$AppDatabase db, $MealTagAssignmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealTagAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealTagAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealTagAssignmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> mealId = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealTagAssignmentsCompanion(
            mealId: mealId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int mealId,
            required int tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              MealTagAssignmentsCompanion.insert(
            mealId: mealId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealTagAssignmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealTagAssignmentsTable,
    MealTagAssignment,
    $$MealTagAssignmentsTableFilterComposer,
    $$MealTagAssignmentsTableOrderingComposer,
    $$MealTagAssignmentsTableAnnotationComposer,
    $$MealTagAssignmentsTableCreateCompanionBuilder,
    $$MealTagAssignmentsTableUpdateCompanionBuilder,
    (
      MealTagAssignment,
      BaseReferences<_$AppDatabase, $MealTagAssignmentsTable, MealTagAssignment>
    ),
    MealTagAssignment,
    PrefetchHooks Function()>;
typedef $$TodoListsTableCreateCompanionBuilder = TodoListsCompanion Function({
  Value<int> id,
  required String name,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$TodoListsTableUpdateCompanionBuilder = TodoListsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$TodoListsTableFilterComposer
    extends Composer<_$AppDatabase, $TodoListsTable> {
  $$TodoListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TodoListsTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoListsTable> {
  $$TodoListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TodoListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoListsTable> {
  $$TodoListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TodoListsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TodoListsTable,
    TodoList,
    $$TodoListsTableFilterComposer,
    $$TodoListsTableOrderingComposer,
    $$TodoListsTableAnnotationComposer,
    $$TodoListsTableCreateCompanionBuilder,
    $$TodoListsTableUpdateCompanionBuilder,
    (TodoList, BaseReferences<_$AppDatabase, $TodoListsTable, TodoList>),
    TodoList,
    PrefetchHooks Function()> {
  $$TodoListsTableTableManager(_$AppDatabase db, $TodoListsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TodoListsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              TodoListsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TodoListsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TodoListsTable,
    TodoList,
    $$TodoListsTableFilterComposer,
    $$TodoListsTableOrderingComposer,
    $$TodoListsTableAnnotationComposer,
    $$TodoListsTableCreateCompanionBuilder,
    $$TodoListsTableUpdateCompanionBuilder,
    (TodoList, BaseReferences<_$AppDatabase, $TodoListsTable, TodoList>),
    TodoList,
    PrefetchHooks Function()>;
typedef $$TodoItemsTableCreateCompanionBuilder = TodoItemsCompanion Function({
  Value<int> id,
  required int listId,
  required String displayName,
  Value<String?> notes,
  required DateTime scheduledDate,
  Value<int> sortOrder,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  required DateTime addedAt,
  Value<DateTime?> reminderAt,
});
typedef $$TodoItemsTableUpdateCompanionBuilder = TodoItemsCompanion Function({
  Value<int> id,
  Value<int> listId,
  Value<String> displayName,
  Value<String?> notes,
  Value<DateTime> scheduledDate,
  Value<int> sortOrder,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<DateTime> addedAt,
  Value<DateTime?> reminderAt,
});

class $$TodoItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TodoItemsTable> {
  $$TodoItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reminderAt => $composableBuilder(
      column: $table.reminderAt, builder: (column) => ColumnFilters(column));
}

class $$TodoItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoItemsTable> {
  $$TodoItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reminderAt => $composableBuilder(
      column: $table.reminderAt, builder: (column) => ColumnOrderings(column));
}

class $$TodoItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoItemsTable> {
  $$TodoItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get reminderAt => $composableBuilder(
      column: $table.reminderAt, builder: (column) => column);
}

class $$TodoItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TodoItemsTable,
    TodoItem,
    $$TodoItemsTableFilterComposer,
    $$TodoItemsTableOrderingComposer,
    $$TodoItemsTableAnnotationComposer,
    $$TodoItemsTableCreateCompanionBuilder,
    $$TodoItemsTableUpdateCompanionBuilder,
    (TodoItem, BaseReferences<_$AppDatabase, $TodoItemsTable, TodoItem>),
    TodoItem,
    PrefetchHooks Function()> {
  $$TodoItemsTableTableManager(_$AppDatabase db, $TodoItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> listId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> scheduledDate = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<DateTime?> reminderAt = const Value.absent(),
          }) =>
              TodoItemsCompanion(
            id: id,
            listId: listId,
            displayName: displayName,
            notes: notes,
            scheduledDate: scheduledDate,
            sortOrder: sortOrder,
            isCompleted: isCompleted,
            completedAt: completedAt,
            addedAt: addedAt,
            reminderAt: reminderAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int listId,
            required String displayName,
            Value<String?> notes = const Value.absent(),
            required DateTime scheduledDate,
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            required DateTime addedAt,
            Value<DateTime?> reminderAt = const Value.absent(),
          }) =>
              TodoItemsCompanion.insert(
            id: id,
            listId: listId,
            displayName: displayName,
            notes: notes,
            scheduledDate: scheduledDate,
            sortOrder: sortOrder,
            isCompleted: isCompleted,
            completedAt: completedAt,
            addedAt: addedAt,
            reminderAt: reminderAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TodoItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TodoItemsTable,
    TodoItem,
    $$TodoItemsTableFilterComposer,
    $$TodoItemsTableOrderingComposer,
    $$TodoItemsTableAnnotationComposer,
    $$TodoItemsTableCreateCompanionBuilder,
    $$TodoItemsTableUpdateCompanionBuilder,
    (TodoItem, BaseReferences<_$AppDatabase, $TodoItemsTable, TodoItem>),
    TodoItem,
    PrefetchHooks Function()>;
typedef $$TodoCompletedArchiveTableCreateCompanionBuilder
    = TodoCompletedArchiveCompanion Function({
  Value<int> id,
  required int listId,
  required String displayName,
  Value<String?> notes,
  required DateTime scheduledDate,
  required DateTime completedAt,
  required DateTime archivedAt,
});
typedef $$TodoCompletedArchiveTableUpdateCompanionBuilder
    = TodoCompletedArchiveCompanion Function({
  Value<int> id,
  Value<int> listId,
  Value<String> displayName,
  Value<String?> notes,
  Value<DateTime> scheduledDate,
  Value<DateTime> completedAt,
  Value<DateTime> archivedAt,
});

class $$TodoCompletedArchiveTableFilterComposer
    extends Composer<_$AppDatabase, $TodoCompletedArchiveTable> {
  $$TodoCompletedArchiveTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));
}

class $$TodoCompletedArchiveTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoCompletedArchiveTable> {
  $$TodoCompletedArchiveTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));
}

class $$TodoCompletedArchiveTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoCompletedArchiveTable> {
  $$TodoCompletedArchiveTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);
}

class $$TodoCompletedArchiveTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TodoCompletedArchiveTable,
    TodoCompletedArchiveData,
    $$TodoCompletedArchiveTableFilterComposer,
    $$TodoCompletedArchiveTableOrderingComposer,
    $$TodoCompletedArchiveTableAnnotationComposer,
    $$TodoCompletedArchiveTableCreateCompanionBuilder,
    $$TodoCompletedArchiveTableUpdateCompanionBuilder,
    (
      TodoCompletedArchiveData,
      BaseReferences<_$AppDatabase, $TodoCompletedArchiveTable,
          TodoCompletedArchiveData>
    ),
    TodoCompletedArchiveData,
    PrefetchHooks Function()> {
  $$TodoCompletedArchiveTableTableManager(
      _$AppDatabase db, $TodoCompletedArchiveTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoCompletedArchiveTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoCompletedArchiveTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoCompletedArchiveTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> listId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> scheduledDate = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<DateTime> archivedAt = const Value.absent(),
          }) =>
              TodoCompletedArchiveCompanion(
            id: id,
            listId: listId,
            displayName: displayName,
            notes: notes,
            scheduledDate: scheduledDate,
            completedAt: completedAt,
            archivedAt: archivedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int listId,
            required String displayName,
            Value<String?> notes = const Value.absent(),
            required DateTime scheduledDate,
            required DateTime completedAt,
            required DateTime archivedAt,
          }) =>
              TodoCompletedArchiveCompanion.insert(
            id: id,
            listId: listId,
            displayName: displayName,
            notes: notes,
            scheduledDate: scheduledDate,
            completedAt: completedAt,
            archivedAt: archivedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TodoCompletedArchiveTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TodoCompletedArchiveTable,
        TodoCompletedArchiveData,
        $$TodoCompletedArchiveTableFilterComposer,
        $$TodoCompletedArchiveTableOrderingComposer,
        $$TodoCompletedArchiveTableAnnotationComposer,
        $$TodoCompletedArchiveTableCreateCompanionBuilder,
        $$TodoCompletedArchiveTableUpdateCompanionBuilder,
        (
          TodoCompletedArchiveData,
          BaseReferences<_$AppDatabase, $TodoCompletedArchiveTable,
              TodoCompletedArchiveData>
        ),
        TodoCompletedArchiveData,
        PrefetchHooks Function()>;
typedef $$TakeAwayListsTableCreateCompanionBuilder = TakeAwayListsCompanion
    Function({
  Value<int> id,
  required String name,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$TakeAwayListsTableUpdateCompanionBuilder = TakeAwayListsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$TakeAwayListsTableFilterComposer
    extends Composer<_$AppDatabase, $TakeAwayListsTable> {
  $$TakeAwayListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TakeAwayListsTableOrderingComposer
    extends Composer<_$AppDatabase, $TakeAwayListsTable> {
  $$TakeAwayListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TakeAwayListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TakeAwayListsTable> {
  $$TakeAwayListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TakeAwayListsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TakeAwayListsTable,
    TakeAwayList,
    $$TakeAwayListsTableFilterComposer,
    $$TakeAwayListsTableOrderingComposer,
    $$TakeAwayListsTableAnnotationComposer,
    $$TakeAwayListsTableCreateCompanionBuilder,
    $$TakeAwayListsTableUpdateCompanionBuilder,
    (
      TakeAwayList,
      BaseReferences<_$AppDatabase, $TakeAwayListsTable, TakeAwayList>
    ),
    TakeAwayList,
    PrefetchHooks Function()> {
  $$TakeAwayListsTableTableManager(_$AppDatabase db, $TakeAwayListsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TakeAwayListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TakeAwayListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TakeAwayListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TakeAwayListsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              TakeAwayListsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TakeAwayListsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TakeAwayListsTable,
    TakeAwayList,
    $$TakeAwayListsTableFilterComposer,
    $$TakeAwayListsTableOrderingComposer,
    $$TakeAwayListsTableAnnotationComposer,
    $$TakeAwayListsTableCreateCompanionBuilder,
    $$TakeAwayListsTableUpdateCompanionBuilder,
    (
      TakeAwayList,
      BaseReferences<_$AppDatabase, $TakeAwayListsTable, TakeAwayList>
    ),
    TakeAwayList,
    PrefetchHooks Function()>;
typedef $$TakeAwayMenusTableCreateCompanionBuilder = TakeAwayMenusCompanion
    Function({
  Value<int> id,
  required int listId,
  required String restaurantName,
  Value<String?> location,
  Value<String?> mapsUrl,
  Value<String?> website,
  Value<String?> phone,
  Value<String?> menuUrl,
  Value<String?> currency,
  Value<bool> isFinalized,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$TakeAwayMenusTableUpdateCompanionBuilder = TakeAwayMenusCompanion
    Function({
  Value<int> id,
  Value<int> listId,
  Value<String> restaurantName,
  Value<String?> location,
  Value<String?> mapsUrl,
  Value<String?> website,
  Value<String?> phone,
  Value<String?> menuUrl,
  Value<String?> currency,
  Value<bool> isFinalized,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$TakeAwayMenusTableFilterComposer
    extends Composer<_$AppDatabase, $TakeAwayMenusTable> {
  $$TakeAwayMenusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get restaurantName => $composableBuilder(
      column: $table.restaurantName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mapsUrl => $composableBuilder(
      column: $table.mapsUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get menuUrl => $composableBuilder(
      column: $table.menuUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFinalized => $composableBuilder(
      column: $table.isFinalized, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TakeAwayMenusTableOrderingComposer
    extends Composer<_$AppDatabase, $TakeAwayMenusTable> {
  $$TakeAwayMenusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listId => $composableBuilder(
      column: $table.listId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get restaurantName => $composableBuilder(
      column: $table.restaurantName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mapsUrl => $composableBuilder(
      column: $table.mapsUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get menuUrl => $composableBuilder(
      column: $table.menuUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFinalized => $composableBuilder(
      column: $table.isFinalized, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TakeAwayMenusTableAnnotationComposer
    extends Composer<_$AppDatabase, $TakeAwayMenusTable> {
  $$TakeAwayMenusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get restaurantName => $composableBuilder(
      column: $table.restaurantName, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get mapsUrl =>
      $composableBuilder(column: $table.mapsUrl, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get menuUrl =>
      $composableBuilder(column: $table.menuUrl, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get isFinalized => $composableBuilder(
      column: $table.isFinalized, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TakeAwayMenusTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TakeAwayMenusTable,
    TakeAwayMenu,
    $$TakeAwayMenusTableFilterComposer,
    $$TakeAwayMenusTableOrderingComposer,
    $$TakeAwayMenusTableAnnotationComposer,
    $$TakeAwayMenusTableCreateCompanionBuilder,
    $$TakeAwayMenusTableUpdateCompanionBuilder,
    (
      TakeAwayMenu,
      BaseReferences<_$AppDatabase, $TakeAwayMenusTable, TakeAwayMenu>
    ),
    TakeAwayMenu,
    PrefetchHooks Function()> {
  $$TakeAwayMenusTableTableManager(_$AppDatabase db, $TakeAwayMenusTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TakeAwayMenusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TakeAwayMenusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TakeAwayMenusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> listId = const Value.absent(),
            Value<String> restaurantName = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> mapsUrl = const Value.absent(),
            Value<String?> website = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> menuUrl = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<bool> isFinalized = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TakeAwayMenusCompanion(
            id: id,
            listId: listId,
            restaurantName: restaurantName,
            location: location,
            mapsUrl: mapsUrl,
            website: website,
            phone: phone,
            menuUrl: menuUrl,
            currency: currency,
            isFinalized: isFinalized,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int listId,
            required String restaurantName,
            Value<String?> location = const Value.absent(),
            Value<String?> mapsUrl = const Value.absent(),
            Value<String?> website = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> menuUrl = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<bool> isFinalized = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              TakeAwayMenusCompanion.insert(
            id: id,
            listId: listId,
            restaurantName: restaurantName,
            location: location,
            mapsUrl: mapsUrl,
            website: website,
            phone: phone,
            menuUrl: menuUrl,
            currency: currency,
            isFinalized: isFinalized,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TakeAwayMenusTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TakeAwayMenusTable,
    TakeAwayMenu,
    $$TakeAwayMenusTableFilterComposer,
    $$TakeAwayMenusTableOrderingComposer,
    $$TakeAwayMenusTableAnnotationComposer,
    $$TakeAwayMenusTableCreateCompanionBuilder,
    $$TakeAwayMenusTableUpdateCompanionBuilder,
    (
      TakeAwayMenu,
      BaseReferences<_$AppDatabase, $TakeAwayMenusTable, TakeAwayMenu>
    ),
    TakeAwayMenu,
    PrefetchHooks Function()>;
typedef $$TakeAwayMenuItemsTableCreateCompanionBuilder
    = TakeAwayMenuItemsCompanion Function({
  Value<int> id,
  required int menuId,
  Value<String?> itemNumber,
  required String name,
  required String priceDisplay,
  Value<double?> priceAmount,
  Value<int> sortOrder,
});
typedef $$TakeAwayMenuItemsTableUpdateCompanionBuilder
    = TakeAwayMenuItemsCompanion Function({
  Value<int> id,
  Value<int> menuId,
  Value<String?> itemNumber,
  Value<String> name,
  Value<String> priceDisplay,
  Value<double?> priceAmount,
  Value<int> sortOrder,
});

class $$TakeAwayMenuItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TakeAwayMenuItemsTable> {
  $$TakeAwayMenuItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get menuId => $composableBuilder(
      column: $table.menuId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemNumber => $composableBuilder(
      column: $table.itemNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priceDisplay => $composableBuilder(
      column: $table.priceDisplay, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get priceAmount => $composableBuilder(
      column: $table.priceAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$TakeAwayMenuItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TakeAwayMenuItemsTable> {
  $$TakeAwayMenuItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get menuId => $composableBuilder(
      column: $table.menuId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemNumber => $composableBuilder(
      column: $table.itemNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priceDisplay => $composableBuilder(
      column: $table.priceDisplay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get priceAmount => $composableBuilder(
      column: $table.priceAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$TakeAwayMenuItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TakeAwayMenuItemsTable> {
  $$TakeAwayMenuItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get menuId =>
      $composableBuilder(column: $table.menuId, builder: (column) => column);

  GeneratedColumn<String> get itemNumber => $composableBuilder(
      column: $table.itemNumber, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get priceDisplay => $composableBuilder(
      column: $table.priceDisplay, builder: (column) => column);

  GeneratedColumn<double> get priceAmount => $composableBuilder(
      column: $table.priceAmount, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$TakeAwayMenuItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TakeAwayMenuItemsTable,
    TakeAwayMenuItem,
    $$TakeAwayMenuItemsTableFilterComposer,
    $$TakeAwayMenuItemsTableOrderingComposer,
    $$TakeAwayMenuItemsTableAnnotationComposer,
    $$TakeAwayMenuItemsTableCreateCompanionBuilder,
    $$TakeAwayMenuItemsTableUpdateCompanionBuilder,
    (
      TakeAwayMenuItem,
      BaseReferences<_$AppDatabase, $TakeAwayMenuItemsTable, TakeAwayMenuItem>
    ),
    TakeAwayMenuItem,
    PrefetchHooks Function()> {
  $$TakeAwayMenuItemsTableTableManager(
      _$AppDatabase db, $TakeAwayMenuItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TakeAwayMenuItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TakeAwayMenuItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TakeAwayMenuItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> menuId = const Value.absent(),
            Value<String?> itemNumber = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> priceDisplay = const Value.absent(),
            Value<double?> priceAmount = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              TakeAwayMenuItemsCompanion(
            id: id,
            menuId: menuId,
            itemNumber: itemNumber,
            name: name,
            priceDisplay: priceDisplay,
            priceAmount: priceAmount,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int menuId,
            Value<String?> itemNumber = const Value.absent(),
            required String name,
            required String priceDisplay,
            Value<double?> priceAmount = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              TakeAwayMenuItemsCompanion.insert(
            id: id,
            menuId: menuId,
            itemNumber: itemNumber,
            name: name,
            priceDisplay: priceDisplay,
            priceAmount: priceAmount,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TakeAwayMenuItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TakeAwayMenuItemsTable,
    TakeAwayMenuItem,
    $$TakeAwayMenuItemsTableFilterComposer,
    $$TakeAwayMenuItemsTableOrderingComposer,
    $$TakeAwayMenuItemsTableAnnotationComposer,
    $$TakeAwayMenuItemsTableCreateCompanionBuilder,
    $$TakeAwayMenuItemsTableUpdateCompanionBuilder,
    (
      TakeAwayMenuItem,
      BaseReferences<_$AppDatabase, $TakeAwayMenuItemsTable, TakeAwayMenuItem>
    ),
    TakeAwayMenuItem,
    PrefetchHooks Function()>;
typedef $$TakeAwayOrdersTableCreateCompanionBuilder = TakeAwayOrdersCompanion
    Function({
  Value<int> id,
  required int menuId,
  required DateTime updatedAt,
});
typedef $$TakeAwayOrdersTableUpdateCompanionBuilder = TakeAwayOrdersCompanion
    Function({
  Value<int> id,
  Value<int> menuId,
  Value<DateTime> updatedAt,
});

class $$TakeAwayOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $TakeAwayOrdersTable> {
  $$TakeAwayOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get menuId => $composableBuilder(
      column: $table.menuId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TakeAwayOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $TakeAwayOrdersTable> {
  $$TakeAwayOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get menuId => $composableBuilder(
      column: $table.menuId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TakeAwayOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TakeAwayOrdersTable> {
  $$TakeAwayOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get menuId =>
      $composableBuilder(column: $table.menuId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TakeAwayOrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TakeAwayOrdersTable,
    TakeAwayOrder,
    $$TakeAwayOrdersTableFilterComposer,
    $$TakeAwayOrdersTableOrderingComposer,
    $$TakeAwayOrdersTableAnnotationComposer,
    $$TakeAwayOrdersTableCreateCompanionBuilder,
    $$TakeAwayOrdersTableUpdateCompanionBuilder,
    (
      TakeAwayOrder,
      BaseReferences<_$AppDatabase, $TakeAwayOrdersTable, TakeAwayOrder>
    ),
    TakeAwayOrder,
    PrefetchHooks Function()> {
  $$TakeAwayOrdersTableTableManager(
      _$AppDatabase db, $TakeAwayOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TakeAwayOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TakeAwayOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TakeAwayOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> menuId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TakeAwayOrdersCompanion(
            id: id,
            menuId: menuId,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int menuId,
            required DateTime updatedAt,
          }) =>
              TakeAwayOrdersCompanion.insert(
            id: id,
            menuId: menuId,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TakeAwayOrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TakeAwayOrdersTable,
    TakeAwayOrder,
    $$TakeAwayOrdersTableFilterComposer,
    $$TakeAwayOrdersTableOrderingComposer,
    $$TakeAwayOrdersTableAnnotationComposer,
    $$TakeAwayOrdersTableCreateCompanionBuilder,
    $$TakeAwayOrdersTableUpdateCompanionBuilder,
    (
      TakeAwayOrder,
      BaseReferences<_$AppDatabase, $TakeAwayOrdersTable, TakeAwayOrder>
    ),
    TakeAwayOrder,
    PrefetchHooks Function()>;
typedef $$TakeAwayOrderLinesTableCreateCompanionBuilder
    = TakeAwayOrderLinesCompanion Function({
  Value<int> id,
  required int orderId,
  required int menuItemId,
  Value<int> quantity,
});
typedef $$TakeAwayOrderLinesTableUpdateCompanionBuilder
    = TakeAwayOrderLinesCompanion Function({
  Value<int> id,
  Value<int> orderId,
  Value<int> menuItemId,
  Value<int> quantity,
});

class $$TakeAwayOrderLinesTableFilterComposer
    extends Composer<_$AppDatabase, $TakeAwayOrderLinesTable> {
  $$TakeAwayOrderLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get menuItemId => $composableBuilder(
      column: $table.menuItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));
}

class $$TakeAwayOrderLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $TakeAwayOrderLinesTable> {
  $$TakeAwayOrderLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get menuItemId => $composableBuilder(
      column: $table.menuItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));
}

class $$TakeAwayOrderLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TakeAwayOrderLinesTable> {
  $$TakeAwayOrderLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<int> get menuItemId => $composableBuilder(
      column: $table.menuItemId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$TakeAwayOrderLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TakeAwayOrderLinesTable,
    TakeAwayOrderLine,
    $$TakeAwayOrderLinesTableFilterComposer,
    $$TakeAwayOrderLinesTableOrderingComposer,
    $$TakeAwayOrderLinesTableAnnotationComposer,
    $$TakeAwayOrderLinesTableCreateCompanionBuilder,
    $$TakeAwayOrderLinesTableUpdateCompanionBuilder,
    (
      TakeAwayOrderLine,
      BaseReferences<_$AppDatabase, $TakeAwayOrderLinesTable, TakeAwayOrderLine>
    ),
    TakeAwayOrderLine,
    PrefetchHooks Function()> {
  $$TakeAwayOrderLinesTableTableManager(
      _$AppDatabase db, $TakeAwayOrderLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TakeAwayOrderLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TakeAwayOrderLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TakeAwayOrderLinesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<int> menuItemId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
          }) =>
              TakeAwayOrderLinesCompanion(
            id: id,
            orderId: orderId,
            menuItemId: menuItemId,
            quantity: quantity,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            required int menuItemId,
            Value<int> quantity = const Value.absent(),
          }) =>
              TakeAwayOrderLinesCompanion.insert(
            id: id,
            orderId: orderId,
            menuItemId: menuItemId,
            quantity: quantity,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TakeAwayOrderLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TakeAwayOrderLinesTable,
    TakeAwayOrderLine,
    $$TakeAwayOrderLinesTableFilterComposer,
    $$TakeAwayOrderLinesTableOrderingComposer,
    $$TakeAwayOrderLinesTableAnnotationComposer,
    $$TakeAwayOrderLinesTableCreateCompanionBuilder,
    $$TakeAwayOrderLinesTableUpdateCompanionBuilder,
    (
      TakeAwayOrderLine,
      BaseReferences<_$AppDatabase, $TakeAwayOrderLinesTable, TakeAwayOrderLine>
    ),
    TakeAwayOrderLine,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CatalogItemsTableTableManager get catalogItems =>
      $$CatalogItemsTableTableManager(_db, _db.catalogItems);
  $$ShoppingListsTableTableManager get shoppingLists =>
      $$ShoppingListsTableTableManager(_db, _db.shoppingLists);
  $$ListItemsTableTableManager get listItems =>
      $$ListItemsTableTableManager(_db, _db.listItems);
  $$CheckOffEventsTableTableManager get checkOffEvents =>
      $$CheckOffEventsTableTableManager(_db, _db.checkOffEvents);
  $$CategoryRankStatsTableTableManager get categoryRankStats =>
      $$CategoryRankStatsTableTableManager(_db, _db.categoryRankStats);
  $$ItemRankStatsTableTableManager get itemRankStats =>
      $$ItemRankStatsTableTableManager(_db, _db.itemRankStats);
  $$ShopStatsRecordsTableTableManager get shopStatsRecords =>
      $$ShopStatsRecordsTableTableManager(_db, _db.shopStatsRecords);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db, _db.meals);
  $$MealPlanItemsTableTableManager get mealPlanItems =>
      $$MealPlanItemsTableTableManager(_db, _db.mealPlanItems);
  $$MealIngredientsTableTableManager get mealIngredients =>
      $$MealIngredientsTableTableManager(_db, _db.mealIngredients);
  $$MealCheckOffEventsTableTableManager get mealCheckOffEvents =>
      $$MealCheckOffEventsTableTableManager(_db, _db.mealCheckOffEvents);
  $$MealStepsTableTableManager get mealSteps =>
      $$MealStepsTableTableManager(_db, _db.mealSteps);
  $$MealTagsTableTableManager get mealTags =>
      $$MealTagsTableTableManager(_db, _db.mealTags);
  $$MealTagAssignmentsTableTableManager get mealTagAssignments =>
      $$MealTagAssignmentsTableTableManager(_db, _db.mealTagAssignments);
  $$TodoListsTableTableManager get todoLists =>
      $$TodoListsTableTableManager(_db, _db.todoLists);
  $$TodoItemsTableTableManager get todoItems =>
      $$TodoItemsTableTableManager(_db, _db.todoItems);
  $$TodoCompletedArchiveTableTableManager get todoCompletedArchive =>
      $$TodoCompletedArchiveTableTableManager(_db, _db.todoCompletedArchive);
  $$TakeAwayListsTableTableManager get takeAwayLists =>
      $$TakeAwayListsTableTableManager(_db, _db.takeAwayLists);
  $$TakeAwayMenusTableTableManager get takeAwayMenus =>
      $$TakeAwayMenusTableTableManager(_db, _db.takeAwayMenus);
  $$TakeAwayMenuItemsTableTableManager get takeAwayMenuItems =>
      $$TakeAwayMenuItemsTableTableManager(_db, _db.takeAwayMenuItems);
  $$TakeAwayOrdersTableTableManager get takeAwayOrders =>
      $$TakeAwayOrdersTableTableManager(_db, _db.takeAwayOrders);
  $$TakeAwayOrderLinesTableTableManager get takeAwayOrderLines =>
      $$TakeAwayOrderLinesTableTableManager(_db, _db.takeAwayOrderLines);
}
