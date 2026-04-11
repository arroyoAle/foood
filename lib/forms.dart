import 'package:flutter/material.dart';
import 'package:foood/helpers/recipe_manager.dart';

import 'helpers/item_manager.dart';

class IngredientForm extends StatefulWidget {
  final RecipeManager recipeManager;
  final ItemManager? itemManager;

  const IngredientForm({super.key, required this.recipeManager, this.itemManager});

  @override
  IngredientFormState createState() {
    return IngredientFormState();
  }
}

class IngredientFormState extends State<IngredientForm> {
  late final ItemManager _itemManager;
  late Future<void> _loadingFuture;
  final _ingredientFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _itemManager = widget.itemManager ?? ItemManager();
    _loadingFuture = _itemManager.loadAllItems();
  }

  Future<void> _onAdd() async {
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Form(
          child: Column(
            key: _ingredientFormKey,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add new ingredient',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ingredient',
                  ),
                  items: _itemManager.allItems.map((item) => DropdownMenuItem(
                    value: item.id,
                    child: Text(item.name),
                  )).toList(),
                  onChanged: (String? ingredient) {
                    setState(() {});
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: _onAdd,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class InstructionForm extends StatefulWidget {
  final RecipeManager recipeManager;

  const InstructionForm({super.key, required this.recipeManager});

  @override
  InstructionFormState createState() {
    return InstructionFormState();
  }
}

class InstructionFormState extends State<InstructionForm> {
  final TextEditingController instructionController = TextEditingController();
  final _instructionFormKey = GlobalKey<FormState>();

  Future<void> _onAdd() async {
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _instructionFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add new instruction',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Instruction',
              ),
              controller: instructionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: _onAdd,
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}