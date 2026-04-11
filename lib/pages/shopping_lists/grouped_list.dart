import 'package:flutter/material.dart';
import '../../models/list_item.dart';
import 'shopping_list_tile.dart';

class GroupedList extends StatelessWidget {
  final List<ListItem> items;

  const GroupedList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // Group here instead of in the repository
    final grouped = <String, List<ListItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.item.category, () => []).add(item);
    }

    return ListView(
      children: grouped.entries.map((entry) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              entry.key,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...entry.value.map((item) => ShoppingListTile(listItem: item)),
        ],
      )).toList(),
    );
  }
}