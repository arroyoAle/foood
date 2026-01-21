import 'package:flutter/material.dart';
import 'package:foood/helpers/shopping_list_manager.dart';
import 'package:foood/models/shopping_list.dart';
import 'package:foood/pages/list.dart';

import '../partials/drawer.dart';
import '../partials/top_bar.dart';

class AllListsPage extends StatefulWidget {
  const AllListsPage({super.key, this.manager});

  final String title = 'Lists Home Page';
  final ShoppingListManager? manager;

  @override
  State<AllListsPage> createState() => _AllListsPageState();
}

class _AllListsPageState extends State<AllListsPage> {
  late final ShoppingListManager _manager;
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _manager = widget.manager ?? ShoppingListManager();
    _loadingFuture = _manager.loadAllLists();
  }

  void _openList(ShoppingList list) {
    _manager.setActiveList(list);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListPage(manager: _manager),
      ),
    ).then((_) {
      setState(() {
        _loadingFuture = _manager.loadAllLists();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarPartial(title: widget.title),
      drawer: DrawerPartial(currentPage: 'lists_page'),
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lists = _manager.allLists;
          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              return Card(child: ListTile(
                title: Text(lists[index].name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openList(lists[index]),
              ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Currently does nothing')));
          },
        tooltip: 'Create New List',
        child: const Icon(Icons.add),
      ),
    );
  }
}