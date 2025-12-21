import 'package:flutter/material.dart';

class UnitsInput extends StatelessWidget {
  const UnitsInput({super.key, required this.radioValue});

  final RadioValue? radioValue;

  @override
  Widget build(BuildContext context) {
    if (radioValue == RadioValue.weight){
      return Text('weight');
    } else if (radioValue == RadioValue.liquid) {
      return Text('liquid');
    } else if (radioValue == RadioValue.count) {
      return Text('count');
    }
    return Container();
  }
}

class ItemForm extends StatefulWidget {
  const ItemForm({super.key});

  @override
  ItemFormState createState() {
    return ItemFormState();
  }
}

enum RadioValue { weight, liquid, count }

class ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  RadioValue? _radioValue;

  void _handleRadioInput(RadioValue? value) {

  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            child: Text('Add new item'),
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text('Item details'),
          ),
          Container(
            alignment: Alignment.center,
            child: RadioGroup(
              groupValue: _radioValue,
              onChanged: (RadioValue? value) {
                setState(() {
                  _radioValue = value;
                });
                _handleRadioInput(value);
              },
              child: Row(
                children: [
                  Radio<RadioValue>(
                    value: RadioValue.weight,
                  ),
                  Text('kg'),
                  Radio<RadioValue>(
                    value: RadioValue.liquid,
                  ),
                  // Radio(value: Text('ml')),
                  Text('ml'),
                  Radio(
                    value: RadioValue.count
                  ),
                  Text('count'),
                ],
              )
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: UnitsInput(radioValue: _radioValue),
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
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('New item added')),
                    );
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