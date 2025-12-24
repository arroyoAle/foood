import 'package:uuid/uuid.dart';
import 'package:foood/models/item.dart';
import 'package:foood/helpers/storage.dart';
import 'package:foood/models/shopping_list.dart';

class ShoppingListManager {
  final Storage _storage = Storage();
  late ShoppingList shoppingList;

  Future<void> loadList(String listName) async {
    final data = await _storage.read(listName);
    if (data is Map<String, dynamic> && data.isNotEmpty) {
      shoppingList = ShoppingList.fromJson(data);
    } else {
      final String newId = Uuid().v4();
      shoppingList = ShoppingList(id: newId, name: listName, items: []);
    }
  }

  Future<void> addNewItem({
    required String name,
    required String units,
    required int quantity,
  }) async {
    final String newId = Uuid().v4();

    final newItem = Item(
        newId,
        name,
        units,
        quantity,
        false
    );

    shoppingList.items.add(newItem);

    await _storage.write(shoppingList.name, shoppingList.toJson());
  }
}