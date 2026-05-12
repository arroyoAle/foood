import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/providers/providers.dart';

class IngredientForm extends ConsumerStatefulWidget {
  const IngredientForm({super.key});

  @override
  ConsumerState<IngredientForm> createState() => _IngredientFormState();
}

class _IngredientFormState extends ConsumerState<IngredientForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItemId;
  final _quantityController = TextEditingController(text: '1.0');
  final _unitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);

    return itemsAsync.when(
      data: (items) => Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Ingredient',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Ingredient',
                border: OutlineInputBorder(),
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedItemId = value;
                  final item = items.firstWhere((i) => i.id == value);
                  _unitController.text = item.defaultUnits;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select an ingredient' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final recipeId = ref.read(activeRecipeIdProvider);
                      final item = items.firstWhere(
                        (i) => i.id == _selectedItemId,
                      );
                      if (recipeId.isNotEmpty) {
                        await ref
                            .read(recipesProvider.notifier)
                            .addIngredient(
                              recipeId,
                              item,
                              double.parse(_quantityController.text),
                              _unitController.text,
                            );
                        if (context.mounted) Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class InstructionForm extends ConsumerStatefulWidget {
  const InstructionForm({super.key});

  @override
  ConsumerState<InstructionForm> createState() => _InstructionFormState();
}

class _InstructionFormState extends ConsumerState<InstructionForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Instruction',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Instruction',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter instruction'
                : null,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final recipeId = ref.read(activeRecipeIdProvider);
                    if (recipeId.isNotEmpty) {
                      await ref
                          .read(recipesProvider.notifier)
                          .addInstruction(recipeId, _controller.text);
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
