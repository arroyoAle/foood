import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  Item({
    required this.id,
    required this.name,
    required this.units,
    required this.quantity,
    required this.selected});

  String id;
  String name;
  String units;
  int quantity;
  bool selected;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
