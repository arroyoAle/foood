import 'package:flutter/material.dart';
import '../../models/list_item.dart';
import 'shopping_list_tile.dart';

class GroupedList extends StatelessWidget {
  final List<ListItem> items;

  const GroupedList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final unselectedItems = items.where((i) => !i.selected).toList();
    final selectedItems = items.where((i) => i.selected).toList();

    return ListView(
      children: [
        _buildSectionHeader(context, 'To Buy'),

        if (unselectedItems.isNotEmpty) ...[
          ..._buildGroupedItems(context, unselectedItems),
        ] else ...[
          Container(
            alignment: Alignment.center,
            child: Text("No items to buy"),
          )
        ],
        _buildSectionHeader(context, 'In Cart'),
        if (selectedItems.isNotEmpty) ...[
          ..._buildGroupedItems(context, selectedItems),
        ] else ...[
          Container(
            alignment: Alignment.center,
            child: Text("No items in cart"),
          )
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  List<Widget> _buildGroupedItems(BuildContext context, List<ListItem> items) {
    final grouped = <String, List<ListItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.item.category, () => []).add(item);
    }

    final sortedCategories = grouped.keys.toList()..sort();

    return sortedCategories.expand((category) {
      final categoryItems = grouped[category]!;
      categoryItems.sort((a, b) => a.ordering.compareTo(b.ordering));

      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            category,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...categoryItems.map((item) => ShoppingListTile(listItem: item)),
      ];
    }).toList();
  }
}
