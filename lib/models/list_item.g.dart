// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListItem _$ListItemFromJson(Map<String, dynamic> json) => ListItem(
  id: json['id'] as String,
  itemId: json['itemId'] as String,
  item: Item.fromJson(json['item'] as Map<String, dynamic>),
  quantityRequired: (json['quantityRequired'] as num).toDouble(),
  quantityInPantry: (json['quantityInPantry'] as num).toDouble(),
  quantityToBuy: (json['quantityToBuy'] as num).toDouble(),
  units: json['units'] as String,
  selected: json['selected'] as bool,
  ordering: (json['ordering'] as num).toInt(),
);

Map<String, dynamic> _$ListItemToJson(ListItem instance) => <String, dynamic>{
  'id': instance.id,
  'itemId': instance.itemId,
  'item': instance.item,
  'quantityRequired': instance.quantityRequired,
  'quantityInPantry': instance.quantityInPantry,
  'quantityToBuy': instance.quantityToBuy,
  'units': instance.units,
  'selected': instance.selected,
  'ordering': instance.ordering,
};
