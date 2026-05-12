import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/list_item.dart';
import '../../providers/providers.dart';
import 'shopping_list_tile.dart';

class GroupedList extends StatelessWidget {
  final List<ListItem> items;
  final ScrollController? scrollController;
  final GlobalKey? toBuyKey;
  final GlobalKey? inCartKey;
  final bool isReorderMode;

  const GroupedList({
    super.key,
    required this.items,
    this.scrollController,
    this.toBuyKey,
    this.inCartKey,
    this.isReorderMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedItems = items.where((i) => !i.selected).toList();
    final selectedItems = items.where((i) => i.selected).toList();

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 100), // Space for floating toolbar
      child: Column(
        children: [
          _buildSectionHeader(context, 'To Buy', toBuyKey),
          if (unselectedItems.isNotEmpty) ...[
            ..._buildGroupedItems(context, unselectedItems),
          ] else ...[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text("No items to buy"),
            )
          ],
          const Divider(),
          _buildSectionHeader(context, 'In Cart', inCartKey),
          if (selectedItems.isNotEmpty) ...[
            ..._buildGroupedItems(context, selectedItems),
          ] else ...[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
              child: const Text("No items in cart"),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, GlobalKey? key) {
    return Padding(
      key: key,
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

    return sortedCategories.map((category) {
      final categoryItems = grouped[category]!;
      categoryItems.sort((a, b) => a.ordering.compareTo(b.ordering));

      return Consumer(
        builder: (context, ref, child) {
          return Card(
            color: Theme.of(context).colorScheme.surface,
            elevation: 0,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text(
                '$category (${categoryItems.length})',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              initiallyExpanded: true,
              children: [
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryItems.length,
                  buildDefaultDragHandles: false, // We use custom handle
                  itemBuilder: (context, index) {
                    final item = categoryItems[index];
                    return ShoppingListTile(
                      key: ValueKey(item.id),
                      listItem: item,
                      isReorderMode: isReorderMode,
                      index: index,
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(shoppingListProvider.notifier)
                        .reorderItemsInCategory(
                        categoryItems, oldIndex, newIndex
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }).toList();
  }
}
