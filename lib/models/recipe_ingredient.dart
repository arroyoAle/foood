import 'package:json_annotation/json_annotation.dart';
import 'item.dart';

part 'recipe_ingredient.g.dart';

@JsonSerializable(explicitToJson: true)
class RecipeIngredient {
  final String id;
  final String itemId;
  final Item item;
  final double quantity;
  final String units;

  RecipeIngredient({
    required this.id,
    required this.itemId,
    required this.item,
    required this.quantity,
    required this.units,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);
}
