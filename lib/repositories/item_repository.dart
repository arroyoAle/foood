import '../data/database.dart' as db;
import '../models/item.dart';

class ItemRepository {
  final db.AppDatabase _db;

  ItemRepository(this._db);

  Future<List<Item>> getAllItems() async {
    final results = await _db.select(_db.items).get();
    return results
        .map(
          (row) => Item(
            id: row.id,
            name: row.name,
            defaultUnits: row.defaultUnits,
            category: row.category,
          ),
        )
        .toList();
  }

  Future<Item?> getItem(String id) async {
    final row = await (_db.select(
      _db.items,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return Item(
      id: row.id,
      name: row.name,
      defaultUnits: row.defaultUnits,
      category: row.category,
    );
  }
}
