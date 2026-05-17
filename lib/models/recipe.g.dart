// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
  id: json['id'] as String,
  name: json['name'] as String,
  instructions: (json['instructions'] as List<dynamic>)
      .map((e) => Instruction.fromJson(e as Map<String, dynamic>))
      .toList(),
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'instructions': instance.instructions.map((e) => e.toJson()).toList(),
  'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
};
