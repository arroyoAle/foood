import 'package:flutter/material.dart';
import 'package:foood/helpers/recipe_manager.dart';
import 'package:foood/helpers/shopping_list_manager.dart';
import 'package:foood/models/item.dart';

import 'helpers/item_manager.dart';

class ItemForm extends StatefulWidget {
  final ShoppingListManager manager;

  const ItemForm({super.key, required this.manager});

  @override
  ItemFormState createState() {
    return ItemFormState();
  }
}

List<String> units = ['kg', 'g', 'l', 'ml', 'count'];

class ItemFormState extends State<ItemForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final _itemFormKey = GlobalKey<FormState>();
  String? _selectedUnits;


  Future<void> onAdd() async {
    if (!_itemFormKey.currentState!.validate()) {
      return;
    }

    await widget.manager.addNewItemToActiveList(
        name: nameController.text,
        units: _selectedUnits!,
        quantity: double.parse(quantityController.text));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New item added')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _itemFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add new item',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Item name',
            ),
            controller: nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Item quantity',
                  ),
                  controller: quantityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a quantity';
                    }
                    return null;
                  }),
                ),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.centerRight,
                  child:
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Units',
                    ),
                    items: units.map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit)
                    )).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedUnits = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Select an option';
                      }
                      return null;
                    },
                  )
                )
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                    Navigator.pop(context, false);
                  },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: onAdd,
                child: const Text('Add'),
              ),
            ]
          ),
        ]
      ),
    );
  }
}

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
    // TODO: implement initState
    super.initState();
    _itemManager = widget.itemManager ?? ItemManager();
    _loadingFuture = _itemManager.loadAllItems();
  }


  Future<void> _onAdd() async {
    // if (!_ingredientFormKey!.validate()) {
    //   return;
    // }

  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return
          Form(
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
                  // todo: make into searchable dropdown https://pub.dev/packages/dropdown_search
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ingredient',
                    ),
                    items: _itemManager.allItems.map((item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name)
                    )).toList(),
                    onChanged: (String? ingredient) {
                      setState(() {

                      });
                    },
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: _onAdd,
                        child: const Text('Add'),
                      ),
                    ]
                ),
              ],
            ),
          );
    });
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
  late final ItemManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = ItemManager();
  }

  Future<void> _onAdd() async {

  }

  @override
  Widget build(BuildContext context){
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Instruction',
                ),
                controller: instructionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: _onAdd,
                child: const Text('Add'),
              ),
            ]
          ),
        ],
      ),
    );
  }
}
