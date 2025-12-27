import 'package:flutter/material.dart';
import 'package:foood/forms.dart';
import 'package:foood/helpers/shopping_list_manager.dart';
import 'package:foood/partials/drawer.dart';
import 'package:foood/partials/top_bar.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.manager});

  final ShoppingListManager manager;
  // final String title = 'Lists Home Page';

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late final ShoppingListManager _shoppingListManager;

  @override
  void initState() {
    super.initState();
    _shoppingListManager = widget.manager;

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
    final shoppingList = _shoppingListManager.activeList!;

    return Scaffold(
      appBar: TopBarPartial(title: shoppingList.name),
      drawer: DrawerPartial(currentPage: 'lists_page'),
      body:
      // FutureBuilder(
      //   future: _loadingFuture,
      //   builder: (context, snapshot) {
      //     // --- While Loading ---
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child: CircularProgressIndicator());
      //     }
      //
      //     // --- If an Error Occurs ---
      //     if (snapshot.hasError) {
      //       return Center(
      //         child: Text('Error loading list: ${snapshot.error}')
      //       );
      //     }
      //
      //     // --- When Data is Loaded Successfully ---
      //     // Now it's safe to access the shopping list from the manager
      //     final shoppingList = _shoppingListManager.activeList!;
      //
      //     if (shoppingList.items.isEmpty) {
      //       return const Center(
      //         child: Text(
      //           "No items in this list. \n\nAdd a new item with the '+' button below.",
      //           textAlign: TextAlign.center,
      //         ),
      //       );
      //     } else {
      //       return
              ListView.builder(
              itemCount: shoppingList.items.length,
              itemBuilder: (context, index) =>
                Card(
                  child: CheckboxListTile(
                    value: shoppingList.items[index].selected,
                    title: Text(shoppingList.items[index].name),
                    secondary: Text(
                        '${shoppingList.items[index]
                            .quantity} ${shoppingList
                            .items[index].units}'),
                    onChanged: (bool? value) {
                      setState(() {
                        shoppingList.items[index].selected = value!;
                        _shoppingListManager.saveActiveList();
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
            ),
          // }
        // },
      // ),
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