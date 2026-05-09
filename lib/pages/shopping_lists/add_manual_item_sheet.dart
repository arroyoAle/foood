import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class AddManualItemSheet extends ConsumerStatefulWidget {
  const AddManualItemSheet({super.key});

  @override
  ConsumerState<AddManualItemSheet> createState() => _AddManualItemSheetState();
}

class _AddManualItemSheetState extends ConsumerState<AddManualItemSheet> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _unit = 'whole';

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

    ref.read(shoppingListProvider.notifier).addManualItem(
      name: name,
      quantity: quantity,
      units: _unit,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Item', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Item name'),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          const SizedBox(height: 8),
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
              DropdownButton<String>(
                value: _unit,
                items: ['whole', 'g', 'kg', 'ml', 'l', 'tbsp', 'tsp', 'cup']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (val) => setState(() => _unit = val!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _submit, child: const Text('Add to list')),
        ],
      ),
    );
  }
}