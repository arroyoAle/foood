import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/list_item.dart';
import '../providers/providers.dart';

class ShoppingListNotifier extends AsyncNotifier<List<ListItem>> {
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];

  @override
  Future<List<ListItem>> build() async {
    final listId = ref.watch(activeShoppingListIdProvider);

    // Clear stacks when entering a new list (active ID changed)
    _undoStack.clear();
    _redoStack.clear();
    // Ensure stack providers are updated immediately
    Future.microtask(() => _updateStackProviders());

    return ref.read(shoppingRepositoryProvider).getList(listId);
  }

  void _updateStackProviders() {
    ref.read(shoppingListUndoProvider.notifier).state = _undoStack.isNotEmpty;
    ref.read(shoppingListRedoProvider.notifier).state = _redoStack.isNotEmpty;
  }

  Future<void> addManualItem({
    required String name,
    required double quantity,
    required String units,
    String? category,
  }) async {
    final listId = ref.read(activeShoppingListIdProvider);
    final repo = ref.read(shoppingRepositoryProvider);

    state = const AsyncLoading<List<ListItem>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await repo.addManualItem(
        shoppingListId: listId,
        name: name,
        quantity: quantity,
        units: units,
        category: category,
      );
      return repo.getList(listId);
    });
  }

  Future<void> toggleSelected(
    ListItem listItem, {
    bool isUndo = false,
    bool isRedo = false,
  }) async {
    final repo = ref.read(shoppingRepositoryProvider);

    if (!isUndo && !isRedo) {
      _undoStack.add(listItem.id);
      _redoStack.clear();
      _updateStackProviders();
    }

    if (state.value != null) {
      state = AsyncData(
        _updateItem(state.value!, listItem.id, !listItem.selected),
      );
    }

    await repo.updateSelected(listItem.id, !listItem.selected);
  }

  Future<void> undoLastToggle() async {
    if (_undoStack.isEmpty) return;
    final itemId = _undoStack.removeLast();
    _redoStack.add(itemId);
    _updateStackProviders();

    if (state.value != null) {
      final item = state.value!.firstWhere((i) => i.id == itemId);
      await toggleSelected(item, isUndo: true);
    }
  }

  Future<void> redoLastToggle() async {
    if (_redoStack.isEmpty) return;
    final itemId = _redoStack.removeLast();
    _undoStack.add(itemId);
    _updateStackProviders();

    if (state.value != null) {
      final item = state.value!.firstWhere((i) => i.id == itemId);
      await toggleSelected(item, isRedo: true);
    }
  }

  Future<void> reorderItem(ListItem item, int offset) async {
    if (state.value == null) return;
    final items = state.value!;

    final sameCategoryItems = items
        .where(
          (i) =>
              i.selected == item.selected &&
              i.item.category == item.item.category,
        )
        .toList();
    sameCategoryItems.sort((a, b) => a.ordering.compareTo(b.ordering));

    final index = sameCategoryItems.indexWhere((i) => i.id == item.id);
    final targetIndex = index + offset;

    if (targetIndex < 0 || targetIndex >= sameCategoryItems.length) return;

    final targetItem = sameCategoryItems[targetIndex];

    final repo = ref.read(shoppingRepositoryProvider);
    final listId = ref.read(activeShoppingListIdProvider);

    await repo.db.shoppingDao.updateOrdering(item.id, targetItem.ordering);
    await repo.db.shoppingDao.updateOrdering(targetItem.id, item.ordering);

    state = AsyncData(await repo.getList(listId));
  }

  Future<void> reorderItemsInCategory(
    List<ListItem> categoryItems,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    final movedItem = categoryItems.removeAt(oldIndex);
    categoryItems.insert(newIndex, movedItem);

    final repo = ref.read(shoppingRepositoryProvider);
    final listId = ref.read(activeShoppingListIdProvider);

    // We keep the actual ordering values from the original items but redistribute them
    // This assumes original orderings were sorted.
    final originalOrderings = categoryItems.map((i) => i.ordering).toList();
    originalOrderings.sort();

    final updates = <({String id, int ordering})>[];
    for (int i = 0; i < categoryItems.length; i++) {
      updates.add((id: categoryItems[i].id, ordering: originalOrderings[i]));
    }

    await repo.db.shoppingDao.updateAllOrderings(updates);
    state = AsyncData(await repo.getList(listId));
  }

  Future<void> updateManualItem({
    required String listItemId,
    required String itemId,
    required String name,
    required double quantity,
    required String units,
    required String category,
  }) async {
    final listId = ref.read(activeShoppingListIdProvider);
    final repo = ref.read(shoppingRepositoryProvider);

    state = const AsyncLoading<List<ListItem>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await repo.updateManualItem(
        listItemId: listItemId,
        itemId: itemId,
        name: name,
        quantity: quantity,
        units: units,
        category: category,
      );
      return repo.getList(listId);
    });
  }

  List<ListItem> _updateItem(
    List<ListItem> current,
    String listItemId,
    bool newSelected,
  ) {
    return current.map((listItem) {
      if (listItem.id != listItemId) return listItem;
      return ListItem(
        id: listItem.id,
        itemId: listItem.itemId,
        item: listItem.item,
        quantityRequired: listItem.quantityRequired,
        quantityInPantry: listItem.quantityInPantry,
        quantityToBuy: listItem.quantityToBuy,
        units: listItem.units,
        selected: newSelected,
        ordering: listItem.ordering,
      );
    }).toList();
  }
}
