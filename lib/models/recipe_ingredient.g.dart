// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeIngredient _$RecipeIngredientFromJson(Map<String, dynamic> json) =>
    RecipeIngredient(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      item: Item.fromJson(json['item'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
      units: json['units'] as String,
    );

Map<String, dynamic> _$RecipeIngredientToJson(RecipeIngredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'item': instance.item.toJson(),
      'quantity': instance.quantity,
      'units': instance.units,
    };
