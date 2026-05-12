import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/list_item.dart';
import '../providers/providers.dart';

class ShoppingListNotifier extends AsyncNotifier<List<ListItem>> {
  @override
  Future<List<ListItem>> build() async {
    final listId = ref.watch(activeShoppingListIdProvider);
    return ref.read(shoppingRepositoryProvider).getList(listId);
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

  Future<void> toggleSelected(ListItem listItem) async {
    final repo = ref.read(shoppingRepositoryProvider);

    if (state.value != null) {
      state = AsyncData(
        _updateItem(state.value!, listItem.id, !listItem.selected),
      );
    }

    await repo.updateSelected(listItem.id, !listItem.selected);
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
