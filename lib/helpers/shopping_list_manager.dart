import 'package:uuid/uuid.dart';
import 'package:foood/models/item.dart';
import 'package:foood/helpers/storage.dart';
import 'package:foood/models/shopping_list.dart';

const String _shoppingListsFileName = 'shopping_lists';

class ShoppingListManager {
  final Storage _storage = Storage();
  late ShoppingList shoppingList;

  Future<void> loadList(String listName) async {
    final data = await _storage.read(_shoppingListsFileName);
    if (data is Map<String, dynamic> && data.isNotEmpty) {
      shoppingList = ShoppingList.fromJson(data);
    } else {
      final String newId = Uuid().v4();
      shoppingList = ShoppingList(id: newId, name: listName, items: []);
    }
  }

  Future<void> saveList() async {
    await _storage.write(_shoppingListsFileName, shoppingList.toJson());
  }

  Future<void> addNewItem({
    required String name,
    required String units,
    required int quantity,
    int? ordering,
  }) async {
    final String newId = Uuid().v4();

    ordering ??= shoppingList.items.length + 1;

    final newItem = Item(
      id: newId,
      name: name,
      units: units,
      quantity: quantity,
      selected: false,
      ordering: ordering,
    );

    shoppingList.items.add(newItem);

    await saveList();
  }
}