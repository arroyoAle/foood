import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  Item({
    required this.id,
    required this.name,
    required this.units,
    // todo: need to change this to a list of quantities for each item
    required this.quantity,
    required this.selected,
    required this.ordering,
  });

  String id;
  String name;
  String units;
  @JsonKey(defaultValue: 0)
  int quantity;
  @JsonKey(defaultValue: false)
  bool selected;
  @JsonKey(defaultValue: 0)
  int ordering = 0;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
