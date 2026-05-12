import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/pages/shopping_lists/shopping_list_screen.dart';
import 'package:foood/providers/providers.dart';

import '../data/database.dart' as db;
import '../partials/drawer.dart';
import '../partials/top_bar.dart';

class AllListsPage extends ConsumerWidget {
  const AllListsPage({super.key});

  final String title = 'Lists Home Page';

  void _openList(BuildContext context, WidgetRef ref, db.ShoppingList list) {
    ref.read(activeShoppingListIdProvider.notifier).state = list.id;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ShoppingListScreen()));
  }

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New List'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'List name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              try {
                await ref.read(allListsProvider.notifier).createList(name);
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(filteredAllListsProvider);
    final searchQuery = ref.watch(listSearchQueryProvider);

    return Scaffold(
      appBar: TopBarPartial(title: title),
      drawer: DrawerPartial(currentPage: 'lists_page'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => ref.read(listSearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search lists...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(listSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: listsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (lists) => lists.isEmpty
                  ? const Center(child: Text('No lists found.'))
                  : ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text(lists[index].name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openList(context, ref, lists[index]),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context, ref),
        tooltip: 'Create New List',
        child: const Icon(Icons.add),
      ),
    );
  }
}
