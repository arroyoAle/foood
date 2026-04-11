import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// --- Tables ---

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get defaultUnits => text()();           // was defaultUnit
  TextColumn get category => text().withDefault(const Constant('Uncategorised'))();

  @override
  Set<Column> get primaryKey => {id};
}

class PantryItems extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(Items, #id)(); // was ingredientId
  RealColumn get quantity => real()();
  TextColumn get units => text()();                  // was unit

  @override
  Set<Column> get primaryKey => {id};
}

class ShoppingLists extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ShoppingListItems extends Table {
  TextColumn get id => text()();
  TextColumn get shoppingListId => text().references(ShoppingLists, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  RealColumn get quantityRequired => real()();
  RealColumn get quantityInPantry => real()();
  RealColumn get quantityToBuy => real()();
  TextColumn get units => text()();
  BoolColumn get selected => boolean().withDefault(const Constant(false))();
  IntColumn get ordering => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- DAO ---

@DriftAccessor(tables: [ShoppingListItems, Items, PantryItems])
class ShoppingDao extends DatabaseAccessor<AppDatabase>
    with _$ShoppingDaoMixin {
  ShoppingDao(super.db);

  Future<List<TypedResult>> getItemsWithDetails(String listId) {
    final query = select(shoppingListItems).join([
      innerJoin(
        items,
        items.id.equalsExp(shoppingListItems.itemId),
      ),
    ])
      ..where(shoppingListItems.shoppingListId.equals(listId))
      ..orderBy([
        OrderingTerm.asc(shoppingListItems.ordering),
        OrderingTerm.asc(items.category),
        OrderingTerm.asc(items.name),
      ]);

    return query.get();
  }

  Future<Item?> findItemByName(String name) {
    return (select(items)
      ..where((i) => i.name.lower().equals(name.toLowerCase())))
        .getSingleOrNull();
  }

  Future<int> getPantryStock(String itemId) async {
    final row = await (select(pantryItems)
      ..where((p) => p.itemId.equals(itemId)))
        .getSingleOrNull();
    return row?.quantity.toInt() ?? 0;
  }

  Future<void> insertItem(Insertable<Item> item) =>
      into(items).insert(item);

  Future<void> insertShoppingListItem(Insertable<ShoppingListItem> item) =>
      into(shoppingListItems).insert(item);

  Future<int> getNextOrdering(String listId) async {
    final query = selectOnly(shoppingListItems)
      ..addColumns([shoppingListItems.ordering.max()])
      ..where(shoppingListItems.shoppingListId.equals(listId));
    final result = await query.getSingleOrNull();
    return (result?.read(shoppingListItems.ordering.max()) ?? 0) + 1;
  }

  Future<void> updateSelected(String itemId, bool selected) =>
  (update(shoppingListItems)..where((i) => i.id.equals(itemId)))
      .write(ShoppingListItemsCompanion(selected: Value(selected)));
}

// --- Database ---

@DriftDatabase(
  tables: [Items, PantryItems, ShoppingLists, ShoppingListItems],
  daos: [ShoppingDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'recipes.db'));
    return NativeDatabase(file);
  });
}