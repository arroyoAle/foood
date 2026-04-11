import 'package:foood/models/list_item.dart';


class ShoppingList {
  ShoppingList({required this.id, required this.name, List<ListItem>? items,}) : items = items ?? [];

  String id;
  String name;
  List<ListItem> items;

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    var itemsList = <ListItem>[];
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((itemJson) => ListItem.fromJson(itemJson))
          .toList();
    }

    return ShoppingList(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      items: itemsList,
    );
  }

  /// Converts the ListModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

