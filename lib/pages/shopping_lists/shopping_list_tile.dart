import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/models/list_item.dart';
import '../../providers/providers.dart';
import 'dialogs/item_dialog.dart';

class ShoppingListTile extends ConsumerWidget {
  final ListItem listItem;

  const ShoppingListTile({super.key, required this.listItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      return Container(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onLongPress: () => showDialog(
              context: context,
              builder: (_) => ItemDialog(listItem: listItem),
            ),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              value: listItem.selected,
              onChanged: (_) =>
                  ref.read(shoppingListProvider.notifier).toggleSelected(listItem),
              title: Text(listItem.item.name,
                style: TextStyle(
                  decoration: listItem.selected ? TextDecoration.lineThrough : null,
                  color: listItem.selected ? Colors.grey : null,
                ),
              ),
              secondary: Text('${listItem.quantityToBuy} ${listItem.units}'),
              controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
      ),
    );
  }
}