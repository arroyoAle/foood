import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/models/list_item.dart';
import '../../../providers/providers.dart';

class ItemDialog extends ConsumerStatefulWidget {
  final ListItem? listItem;

  const ItemDialog({super.key, this.listItem});

  @override
  ConsumerState<ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends ConsumerState<ItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late String _unit;
  late String _category;

  bool get _isEditing => widget.listItem != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.listItem?.item.name ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.listItem?.quantityRequired.toString() ?? '',
    );
    _unit = widget.listItem?.units ?? 'whole';
    _category = widget.listItem?.item.category ?? 'Uncategorised';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final quantity = double.tryParse(_quantityController.text) ?? 1;
    if (name.isEmpty) return;

    final notifier = ref.read(shoppingListProvider.notifier);

    if (_isEditing) {
      notifier.updateManualItem(
        listItemId: widget.listItem!.id,
        itemId: widget.listItem!.itemId,
        name: name,
        quantity: quantity,
        units: _unit,
        category: _category,
      );
    } else {
      notifier.addManualItem(
        name: name,
        quantity: quantity,
        units: _unit,
        category: _category,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Item' : 'Add Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item name'),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: ['whole', 'g', 'kg', 'ml', 'l', 'tbsp', 'tsp', 'cup']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) => setState(() => _unit = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                'Uncategorised',
                'Bathroom',
                'Kitchen',
                'Cleaning',
                'Spices',
                'Fruit',
                'Vegetables',
                'Staples',
                'Half ready meals',
                'Fridge',
                'Freezer',
                'Packet mixes',
                'Snacks',
              ].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
