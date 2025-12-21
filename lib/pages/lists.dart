import 'package:flutter/material.dart';
import 'package:foood/forms.dart';
import 'package:foood/models/item.dart';
import 'package:foood/models/shopping_list.dart';
import 'package:foood/partials/drawer.dart';
import 'package:foood/partials/top_bar.dart';

class ListsHomePage extends StatefulWidget {
  const ListsHomePage({super.key});

  final String title = 'Lists Home Page';
  @override
  State<ListsHomePage> createState() => _ListsHomePageState();
}

class _ListsHomePageState extends State<ListsHomePage> {
  ShoppingList shoppingList = ShoppingList(name: 'test', items: [Item('test1', 'g', 400, false)]);

  void _addNewItem(){
    _dialogBuilder(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarPartial(title: widget.title),
      drawer: DrawerPartial(currentPage: 'lists_page'),
      body: ListView.builder(
        itemCount: shoppingList.items.length,
          itemBuilder: (context, index) => Card(
            child: CheckboxListTile(
              value: shoppingList.items[index].selected,
              title: Text(shoppingList.items[index].name),
              secondary: Text('${shoppingList.items[index].quantity} ${shoppingList.items[index].units}'),
              onChanged: (bool? value) {
                setState(() {
                  shoppingList.items[index].selected = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        tooltip: 'Add new item',
        child: const Icon(Icons.add),
      )
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context) {
      return Dialog(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: ItemForm(),


          // title: Text('Add new item'),
          // content: ItemForm(),
        ),
        ),
      );
    });
  }
}