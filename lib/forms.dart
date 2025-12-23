import 'package:flutter/material.dart';
import 'package:foood/models/item.dart';

class ItemForm extends StatefulWidget {
  const ItemForm({super.key});

  @override
  ItemFormState createState() {
    return ItemFormState();
  }
}

List<String> units = ['kg', 'g', 'l', 'ml', 'count'];

class ItemFormState extends State<ItemForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedUnits;


  void onAdd() {
    Item item = Item(nameController.text, _selectedUnits!, int.parse(quantityController.text), false);

  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
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
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Item quantity',
                  ),
                  controller: quantityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  }),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: DropdownMenu<String>(
                  label: Text('Units'),
                  dropdownMenuEntries: units.map<DropdownMenuEntry<String>>(
                    (String unit) {
                      return DropdownMenuEntry<String>(
                        value: unit,
                        label: unit,
                      );
                    }).toList(),
                  onSelected: (String? value) {
                    setState(() {
                      _selectedUnits = value;
                    });
                  },
                )
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                    Navigator.pop(context);
                  },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('New item added')),
                    );
                    onAdd;
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ]
          ),
        ]
      ),
    );
  }
}