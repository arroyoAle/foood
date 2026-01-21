// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  id: json['id'] as String,
  name: json['name'] as String,
  units: json['units'] as String,
  quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  selected: json['selected'] as bool? ?? false,
  ordering: (json['ordering'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'units': instance.units,
  'quantity': instance.quantity,
  'selected': instance.selected,
  'ordering': instance.ordering,
};
