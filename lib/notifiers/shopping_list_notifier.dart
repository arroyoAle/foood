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
      state = AsyncData(_updateItem(state.value!, listItem.id, !listItem.selected));
    }

    await repo.updateSelected(listItem.id, !listItem.selected);
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