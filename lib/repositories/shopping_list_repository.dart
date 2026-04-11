import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart';
import '../models/list_item.dart';

const _uuid = Uuid();

class ShoppingRepository {
  final AppDatabase db;

  ShoppingRepository(this.db);

  Future<Item> findOrCreateItem({
    required String name,
    required String units,
    String category = 'Uncategorised',
  }) async {
    final existing = await db.shoppingDao.findItemByName(name);

    if (existing != null) {
      // Map Drift row → your Item model
      return Item(
        id: existing.id,
        name: existing.name,
        defaultUnits: existing.defaultUnits,
        category: existing.category,
      );
    }

    final id = _uuid.v4();
    await db.shoppingDao.insertItem(
      ItemsCompanion.insert(
        id: id,
        name: name,
        defaultUnits: units,
        category: Value(category),
      ),
    );

    return Item(id: id, name: name, defaultUnits: units, category: category);
  }

  Future<ListItem> addManualItem({
    required String shoppingListId,
    required String name,
    required double quantity,
    required String units,
    String? category,
  }) async {
    final item = await findOrCreateItem(
      name: name,
      units: units,
      category: category ?? 'Uncategorised',
    );

    final inPantry = await db.shoppingDao.getPantryStock(item.id);
    final toBuy = (quantity - inPantry).clamp(0.0, quantity);
    final id = _uuid.v4();
    final ordering = await db.shoppingDao.getNextOrdering(shoppingListId);

    await db.shoppingDao.insertShoppingListItem(
      ShoppingListItemsCompanion.insert(
        id: id,
        shoppingListId: shoppingListId,
        itemId: item.id,
        quantityRequired: quantity,
        quantityInPantry: inPantry,
        quantityToBuy: toBuy,
        units: units,
        selected: const Value(false),
        ordering: ordering,
      ),
    );

    return ListItem(
      id: id,
      itemId: item.id,
      quantityRequired: quantity,
      quantityInPantry: inPantry,
      quantityToBuy: toBuy,
      units: units,
      selected: false,
      ordering: ordering,
    );
  }

  // Returns items paired with their Item details for display
  Future<Map<String, List<(ListItem, Item)>>> getGroupedList(
      String shoppingListId,
      ) async {
    final rows = await db.shoppingDao.getItemsWithDetails(shoppingListId);

    final pairs = rows.map((row) {
      final listItem = row.readTable(db.shoppingListItems);
      final item = row.readTable(db.items);

      return (
      ListItem(
        id: listItem.id,
        itemId: listItem.itemId,
        quantityRequired: listItem.quantityRequired,
        quantityInPantry: listItem.quantityInPantry,
        quantityToBuy: listItem.quantityToBuy,
        units: listItem.units,
        selected: listItem.selected,
        ordering: listItem.ordering,
      ),
      Item(
        id: item.id,
        name: item.name,
        defaultUnits: item.defaultUnits,
        category: item.category,
      ),
      );
    }).toList();

    final grouped = <String, List<(ListItem, Item)>>{};
    for (final pair in pairs) {
      grouped.putIfAbsent(pair.$2.category, () => []).add(pair);
    }
    return grouped;
  }

  Future<void> updateSelected(String listItemId, bool selected) =>
      db.shoppingDao.updateSelected(listItemId, selected);
}