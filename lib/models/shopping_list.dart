import 'item.dart';

class ShoppingList {
  ShoppingList({required this.name, List<Item>? items,}) : items = items ?? [];

  String name;
  List<Item> items;

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    // Safely parse the list of items.
    var itemsList = <Item>[];
    if (json['items'] != null && json['items'] is List) {
      // For each item in the json list, create an Item object.
      itemsList = (json['items'] as List)
          .map((itemJson) => Item.fromJson(itemJson))
          .toList();
    }

    return ShoppingList(
      name: json['name'] ?? '', // Provide a default value in case of null.
      items: itemsList,
    );
  }

  /// Converts the ListModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // Convert each Item object in the list to its JSON representation.
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

