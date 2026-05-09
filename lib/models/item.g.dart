// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  id: json['id'] as String,
  name: json['name'] as String,
  defaultUnits: json['defaultUnits'] as String,
  category: json['category'] as String,
);

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'defaultUnits': instance.defaultUnits,
  'category': instance.category,
};
