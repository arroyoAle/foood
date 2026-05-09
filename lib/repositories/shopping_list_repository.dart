import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart' as database;
import '../models/list_item.dart';
import '../models/item.dart';

const _uuid = Uuid();

class ShoppingRepository {
  final database.AppDatabase db;

  ShoppingRepository(this.db);

  Future<Item> findOrCreateItem({
    required String name,
    required String units,
    String category = 'Uncategorised',
  }) async {
    final existing = await db.shoppingDao.findItemByName(name);

    if (existing != null) {
      return Item(
        id: existing.id,
        name: existing.name,
        defaultUnits: existing.defaultUnits,
        category: existing.category,
      );
    }

    final id = _uuid.v4();
    await db.shoppingDao.insertItem(
      database.ItemsCompanion.insert(
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
      database.ShoppingListItemsCompanion.insert(
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
      item: item,
      quantityRequired: quantity,
      quantityInPantry: inPantry,
      quantityToBuy: toBuy,
      units: units,
      selected: false,
      ordering: ordering,
    );
  }

  Future<List<ListItem>> getList(String shoppingListId) async {
    final rows = await db.shoppingDao.getItemsWithDetails(shoppingListId);

    return rows.map((row) {
      final listItem = row.readTable(db.shoppingListItems);
      final item = row.readTable(db.items);

      return ListItem(
        id: listItem.id,
        itemId: listItem.itemId,
        item: Item(
          id: item.id,
          name: item.name,
          defaultUnits: item.defaultUnits,
          category: item.category,
        ),
        quantityRequired: listItem.quantityRequired,
        quantityInPantry: listItem.quantityInPantry,
        quantityToBuy: listItem.quantityToBuy,
        units: listItem.units,
        selected: listItem.selected,
        ordering: listItem.ordering,
      );
    }).toList();
  }

  Future<void> updateSelected(String listItemId, bool selected) =>
      db.shoppingDao.updateSelected(listItemId, selected);

  Future<void> updateManualItem({
    required String listItemId,
    required String itemId,
    required String name,
    required double quantity,
    required String units,
    required String category,
  }) async {
    // Update the underlying Item
    await db.shoppingDao.updateItem(
      id: itemId,
      name: name,
      category: category,
      units: units,
    );

    // Calculate new quantityToBuy
    final inPantry = await db.shoppingDao.getPantryStock(itemId);
    final toBuy = (quantity - inPantry).clamp(0.0, quantity);

    // Update the ShoppingListItem
    await db.shoppingDao.updateShoppingListItem(
      id: listItemId,
      quantityRequired: quantity,
      quantityToBuy: toBuy,
      units: units,
    );
  }
}