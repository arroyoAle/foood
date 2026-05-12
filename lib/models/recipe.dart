import 'package:json_annotation/json_annotation.dart';
import 'package:foood/models/item.dart'; // Reuse the existing Item model for ingredients
import 'package:uuid/uuid.dart';

part 'recipe.g.dart';

@JsonSerializable(explicitToJson: true)
class Recipe {
  String id;
  String name;
  List<String> instructions;
  List<Item> ingredients;

  // Optional fields you might want to add later:
  // int? cookingTimeMinutes;
  // String? category; // e.g., "Dinner", "Dessert"

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
