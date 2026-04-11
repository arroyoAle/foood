import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/models/list_item.dart';
import '../../providers/providers.dart';

class ShoppingListTile extends ConsumerWidget {
  final ListItem listItem;

  const ShoppingListTile({super.key, required this.listItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: listItem.selected,
        onChanged: (_) =>
            ref.read(shoppingListProvider.notifier).toggleSelected(listItem),
      ),
      title: Text(
        listItem.item.name,
        style: TextStyle(
          decoration: listItem.selected ? TextDecoration.lineThrough : null,
          color: listItem.selected ? Colors.grey : null,
        ),
      ),
      trailing: Text('${listItem.quantityToBuy} ${listItem.units}'),
    );
  }
}