import 'package:uuid/uuid.dart';
import 'package:foood/data/storage.dart';
import 'package:foood/models/shopping_list.dart';

import '../models/list_item.dart';

const String _shoppingListNamesFileName = 'shopping_lists';

class ShoppingListManager {
  final Storage _storage;
  List<ShoppingList> _allLists = [];
  ShoppingList? activeList;
  List<ShoppingList> get allLists => _allLists;

  ShoppingListManager({Storage? storage}) : _storage = storage ?? Storage();

  Future<void> loadAllLists() async {
    final lists = await _storage.read(_shoppingListNamesFileName);
    _allLists = [];

    if (lists is Map && lists.isNotEmpty) {
      for (var listName in lists.values) {
        final listJson = await _storage.read(listName as String);
        if (listJson is Map<String, dynamic> && listJson.isNotEmpty) {
          _allLists.add(ShoppingList.fromJson(listJson));
        }
      }
    }
  }

  void setActiveList(ShoppingList list) {
    activeList = list;
  }

  Future<ShoppingList> createNewList(String listName) async {
    if (_allLists.any((list) => list.name == listName)) {
      throw Exception('A list with this name already exists.');
    }

    final newList = ShoppingList(id: Uuid().v4(), name: listName, items: []);
    _allLists.add(newList);

    await _storage.write(newList.name, newList.toJson());
    await _updateListNames();

    return newList;
  }

  Future<void> saveActiveList() async {
    if (activeList == null) return;
    await _storage.write(activeList!.name, activeList!.toJson());
  }

  Future<void> addNewItemToActiveList({
    required String name,
    required String units,
    required double quantity,
    int? ordering,
  }) async {
    if (activeList == null) return;

    final String newId = Uuid().v4();
    ordering ??= activeList!.items.length + 1;

    final newListItem = ListItem(
      id: newId,
      itemId: name,
      units: units,
      quantityRequired: quantity,
      quantityInPantry: 0,
      quantityToBuy: 0,
      selected: false,
      ordering: ordering,
    );

    activeList!.items.add(newListItem);

    await saveActiveList();
  }

  Future<void> _updateListNames() async {
    final allListNames = Map.fromEntries(_allLists.map(
            (list) => MapEntry(list.id, list.name))
    );
    await _storage.write(_shoppingListNamesFileName, allListNames);
  }
}