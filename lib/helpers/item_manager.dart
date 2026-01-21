import 'package:foood/helpers/storage.dart';
import 'package:uuid/uuid.dart';

import '../models/item.dart';

const String _itemsNamesFileName = 'items';


class ItemManager {
  final Storage _storage;
  List<Item> _allItems = [];
  Item? activeItem;
  List<Item> get allItems => _allItems;

  ItemManager({Storage? storage}) : _storage = storage ?? Storage();

  Future<void> loadAllItems() async {
    final items = await _storage.read(_itemsNamesFileName);
    _allItems = [];

    if (items is Map && items.isNotEmpty) {
      for (var itemName in items.values) {
        final itemJson = await _storage.read(itemName as String);
        if (itemJson is Map<String, dynamic> && itemJson.isNotEmpty) {
          _allItems.add(Item.fromJson(itemJson));
        }
      }
    }
  }

  Future<List<Item>> loadItemsFromId(List<Uuid> ids) async {
    final items = <Item>[];
    for (var id in ids) {
      final itemJson = await _storage.read(id.toString());
      if (itemJson is Map<String, dynamic> && itemJson.isNotEmpty) {
        items.add(Item.fromJson(itemJson));
      }
    }
    return items;
  }

  Future<void> createItem() async {

  }
}