import 'package:json_annotation/json_annotation.dart';

part 'list_item.g.dart';

@JsonSerializable()
class ListItem {
  ListItem({
    required this.id,
    required this.itemId,
    required this.quantityRequired,
    required this.quantityInPantry,
    required this.quantityToBuy,
    required this.units,
    required this.selected,
    required this.ordering,
});
  String id;
  String itemId;
  int quantityRequired;
  int quantityInPantry;
  int quantityToBuy;
  String units;
  bool selected;
  int ordering;

  factory ListItem.fromJson(Map<String, dynamic> json) => _$ListItemFromJson(json);

  Map<String, dynamic> toJson() => _$ListItemToJson(this);
}
