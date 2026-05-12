import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import 'grouped_list.dart';
import 'dialogs/item_dialog.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _toBuyKey = GlobalKey();
  final GlobalKey _inCartKey = GlobalKey();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(filteredShoppingListProvider);
    final isReorderMode = ref.watch(isReorderModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search items...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(itemSearchQueryProvider.notifier).state = value;
                },
              )
            : const Text('Shopping List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  ref.read(itemSearchQueryProvider.notifier).state = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => listAsync.value != null
            ? GroupedList(
                items: listAsync.value!,
                scrollController: _scrollController,
                toBuyKey: _toBuyKey,
                inCartKey: _inCartKey,
                isReorderMode: isReorderMode,
              )
            : const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No items yet'))
            : GroupedList(
                items: items,
                scrollController: _scrollController,
                toBuyKey: _toBuyKey,
                inCartKey: _inCartKey,
                isReorderMode: isReorderMode,
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () => _scrollToSection(_toBuyKey),
                    tooltip: 'Jump to To Buy',
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: () => _scrollToSection(_inCartKey),
                    tooltip: 'Jump to In Cart',
                  ),
                  const VerticalDivider(
                      width: 20, thickness: 1, indent: 12, endIndent: 12),
                  IconButton(
                    icon: Icon(isReorderMode ? Icons.check : Icons.swap_vert),
                    onPressed: () =>
                        ref.read(isReorderModeProvider.notifier).state =
                            !isReorderMode,
                    color: isReorderMode
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    tooltip:
                        isReorderMode ? 'Done Reordering' : 'Reorder Items',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const ItemDialog(),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
