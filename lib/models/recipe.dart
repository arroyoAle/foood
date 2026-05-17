import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'recipe_ingredient.dart';
import 'instruction.dart';

part 'recipe.g.dart';

@JsonSerializable(explicitToJson: true)
class Recipe {
  String id;
  String name;
  List<Instruction> instructions;
  List<RecipeIngredient> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.instructions,
    required this.ingredients,
  });

  /// A factory constructor to create a new, empty recipe with a unique ID.
  factory Recipe.empty() {
    return Recipe(id: Uuid().v4(), name: '', instructions: [], ingredients: []);
  }

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}
