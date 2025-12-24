import 'package:flutter/material.dart';
import 'package:foood/forms.dart';
import 'package:foood/helpers/shopping_list_manager.dart';
import 'package:foood/partials/drawer.dart';
import 'package:foood/partials/top_bar.dart';

class ListsHomePage extends StatefulWidget {
  const ListsHomePage({super.key});

  final String title = 'Lists Home Page';
  @override
  State<ListsHomePage> createState() => _ListsHomePageState();
}

class _ListsHomePageState extends State<ListsHomePage> {
  final ShoppingListManager _shoppingListManager = ShoppingListManager();
  late Future<void> _loadingFuture;
  // ShoppingList shoppingList = ShoppingListManager().shoppingList;

  @override
  void initState() {
    super.initState();
    _loadingFuture = _shoppingListManager.loadList('testing_shopping_list');
  }

  void _addNewItem() async {
    final bool? itemAdded = await _dialogBuilder(context);
    if (itemAdded == true) {
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarPartial(title: widget.title),
      drawer: DrawerPartial(currentPage: 'lists_page'),
      body: FutureBuilder(
          future: _loadingFuture,
          builder: (context, snapshot) {
            // --- While Loading ---
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // --- If an Error Occurs ---
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error loading list: ${snapshot.error}'));
            }

            // --- When Data is Loaded Successfully ---
            // Now it's safe to access the shopping list from the manager
            final shoppingList = _shoppingListManager.shoppingList;

            return ListView.builder(
              itemCount: shoppingList.items.length,
              itemBuilder: (context, index) =>
                  Card(
                    child: CheckboxListTile(
                      value: shoppingList.items[index].selected,
                      title: Text(shoppingList.items[index].name),
                      secondary: Text(
                          '${shoppingList.items[index].quantity} ${shoppingList
                              .items[index].units}'),
                      onChanged: (bool? value) {
                        setState(() {
                          shoppingList.items[index].selected = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
            );
          },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        tooltip: 'Add new item',
        child: const Icon(Icons.add),
      )
    );
  }

  Future<bool?> _dialogBuilder(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context) {
      return Dialog(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(15),
            child: ItemForm(manager: _shoppingListManager),
          ),
        ),
      );
    });
  }
}