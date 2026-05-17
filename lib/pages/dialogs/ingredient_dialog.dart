import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';
import '../../models/item.dart';
import '../../models/recipe_ingredient.dart';

class IngredientDialog extends ConsumerStatefulWidget {
  final RecipeIngredient? ingredient;

  const IngredientDialog({super.key, this.ingredient});

  @override
  ConsumerState<IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends ConsumerState<IngredientDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late String? _selectedItemId;

  bool get _isEditing => widget.ingredient != null;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.ingredient?.quantity.toString() ?? '1.0',
    );
    _unitController = TextEditingController(
      text: widget.ingredient?.units ?? '',
    );
    _selectedItemId = widget.ingredient?.itemId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _submit(Item item) async {
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;

    final notifier = ref.read(recipesProvider.notifier);
    final recipeId = ref.read(activeRecipeIdProvider);

    if (_isEditing) {
      await notifier.updateIngredient(
        ingredientId: widget.ingredient!.id,
        quantity: quantity,
        units: _unitController.text,
      );
    } else {
      await notifier.addIngredient(
        recipeId,
        item,
        quantity,
        _unitController.text,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);

    return itemsAsync.when(
      data: (items) => AlertDialog(
        title: Text(_isEditing ? 'Edit Ingredient' : 'Add Ingredient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedItemId,
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
                onChanged: _isEditing
                    ? null
                    : (value) {
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final item = items.firstWhere((i) => i.id == _selectedItemId);
              _submit(item);
            },
            child: Text(_isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
