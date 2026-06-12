import 'package:json_annotation/json_annotation.dart';
import 'recipe.dart';

part 'meal_plan.g.dart';

@JsonSerializable(explicitToJson: true)
class MealPlanEntryRecipeModel {
  final String id;
  final Recipe recipe;
  final int servings;

  MealPlanEntryRecipeModel({
    required this.id,
    required this.recipe,
    required this.servings,
  });

  factory MealPlanEntryRecipeModel.fromJson(Map<String, dynamic> json) =>
      _$MealPlanEntryRecipeModelFromJson(json);
  Map<String, dynamic> toJson() => _$MealPlanEntryRecipeModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MealPlanEntryModel {
  final String id;
  final DateTime date;
  final String mealType;
  final List<MealPlanEntryRecipeModel> recipes;

  MealPlanEntryModel({
    required this.id,
    required this.date,
    required this.mealType,
    required this.recipes,
  });

  factory MealPlanEntryModel.fromJson(Map<String, dynamic> json) =>
      _$MealPlanEntryModelFromJson(json);
  Map<String, dynamic> toJson() => _$MealPlanEntryModelToJson(this);
}
