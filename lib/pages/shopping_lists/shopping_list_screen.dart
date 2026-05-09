import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import 'grouped_list.dart';
import 'add_manual_item_sheet.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: listAsync.when(
        loading: () => listAsync.value != null
            ? GroupedList(items: listAsync.value!)
            : const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No items yet'))
            : GroupedList(items: items),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const AddManualItemSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}