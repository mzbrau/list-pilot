import '../database/app_database.dart';

/// Maps global sync IDs to local integer primary keys.
class SyncIdMapper {
  SyncIdMapper(this._db);

  final AppDatabase _db;

  final Map<String, _LocalRef> _cache = {};

  Future<int?> localShoppingListId(String? globalId) async {
    if (globalId == null) return null;
    final cached = _cache['shoppingList:$globalId'];
    if (cached != null) return cached.localId;
    final row = await _db.getListByGlobalId(globalId);
    if (row == null) return null;
    _remember('shoppingList', globalId, row.id);
    return row.id;
  }

  Future<int?> localListItemId(String? globalId) async {
    if (globalId == null) return null;
    final cached = _cache['listItem:$globalId'];
    if (cached != null) return cached.localId;
    final row = await _db.getListItemByGlobalId(globalId);
    if (row == null) return null;
    _remember('listItem', globalId, row.id);
    return row.id;
  }

  Future<String?> shoppingListGlobalId(int localId) async {
    final row = await _db.getListById(localId);
    return row?.globalId;
  }

  Future<String?> listItemGlobalId(int localId) async {
    final row = await _db.getListItemById(localId);
    return row?.globalId;
  }

  void rememberShoppingList(String globalId, int localId) {
    _remember('shoppingList', globalId, localId);
  }

  void rememberListItem(String globalId, int localId) {
    _remember('listItem', globalId, localId);
  }

  void _remember(String type, String globalId, int localId) {
    _cache['$type:$globalId'] = _LocalRef(type: type, localId: localId);
  }
}

class _LocalRef {
  const _LocalRef({required this.type, required this.localId});

  final String type;
  final int localId;
}
