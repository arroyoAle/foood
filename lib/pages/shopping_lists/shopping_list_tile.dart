import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/models/list_item.dart';
import '../../providers/providers.dart';
import 'dialogs/item_dialog.dart';

class ShoppingListTile extends ConsumerWidget {
  final ListItem listItem;
  final bool isReorderMode;
  final int index;

  const ShoppingListTile({
    super.key,
    required this.listItem,
    this.isReorderMode = false,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onLongPress: isReorderMode
              ? null
              : () => showDialog(
                  context: context,
                  builder: (_) => ItemDialog(listItem: listItem),
                ),
          child: Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  value: listItem.selected,
                  onChanged: isReorderMode
                      ? null
                      : (_) => ref
                            .read(shoppingListProvider.notifier)
                            .toggleSelected(listItem),
                  title: Text(
                    listItem.item.name,
                    style: TextStyle(
                      decoration: listItem.selected
                          ? TextDecoration.lineThrough
                          : null,
                      color: listItem.selected ? Colors.grey : null,
                    ),
                  ),
                  secondary: isReorderMode
                      ? null
                      : Text('${listItem.quantityToBuy} ${listItem.units}'),
                  controlAffinity: ListTileControlAffinity.leading,
                  enabled: !isReorderMode,
                ),
              ),
              if (isReorderMode)
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(Icons.drag_handle),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
