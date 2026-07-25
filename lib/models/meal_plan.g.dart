// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlanEntryRecipeModel _$MealPlanEntryRecipeModelFromJson(
  Map<String, dynamic> json,
) => MealPlanEntryRecipeModel(
  id: json['id'] as String,
  recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
  servings: (json['servings'] as num).toInt(),
  parentId: json['parentId'] as String?,
  sides:
      (json['sides'] as List<dynamic>?)
          ?.map(
            (e) => MealPlanEntryRecipeModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$MealPlanEntryRecipeModelToJson(
  MealPlanEntryRecipeModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'recipe': instance.recipe.toJson(),
  'servings': instance.servings,
  'parentId': instance.parentId,
  'sides': instance.sides.map((e) => e.toJson()).toList(),
};

MealPlanEntryModel _$MealPlanEntryModelFromJson(Map<String, dynamic> json) =>
    MealPlanEntryModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mealType: json['mealType'] as String,
      recipes: (json['recipes'] as List<dynamic>)
          .map(
            (e) => MealPlanEntryRecipeModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$MealPlanEntryModelToJson(MealPlanEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'mealType': instance.mealType,
      'recipes': instance.recipes.map((e) => e.toJson()).toList(),
    };
