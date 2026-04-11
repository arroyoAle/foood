import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  Item({
    required this.id,
    required this.name,
    required this.defaultUnits,
    required this.category,
  });

  String id;
  String name;
  String defaultUnits;
  String category;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
