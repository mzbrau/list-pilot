import '../../data/database/app_database.dart';

sealed class OverviewListEntry {
  const OverviewListEntry();

  int get id;
  String get name;
  DateTime get updatedAt;
}

class ShoppingListEntry extends OverviewListEntry {
  const ShoppingListEntry(this.list);

  final ShoppingList list;

  @override
  int get id => list.id;

  @override
  String get name => list.name;

  @override
  DateTime get updatedAt => list.updatedAt;
}

class TodoListEntry extends OverviewListEntry {
  const TodoListEntry(this.list);

  final TodoList list;

  @override
  int get id => list.id;

  @override
  String get name => list.name;

  @override
  DateTime get updatedAt => list.updatedAt;
}

class TakeAwayListEntry extends OverviewListEntry {
  const TakeAwayListEntry(this.list);

  final TakeAwayList list;

  @override
  int get id => list.id;

  @override
  String get name => list.name;

  @override
  DateTime get updatedAt => list.updatedAt;
}

class ReceiptListEntry extends OverviewListEntry {
  const ReceiptListEntry(this.list);

  final ReceiptList list;

  @override
  int get id => list.id;

  @override
  String get name => list.name;

  @override
  DateTime get updatedAt => list.updatedAt;
}

enum ListCreateType { shopping, todo, takeAway, receipts }
