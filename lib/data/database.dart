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
  TextColumn get category => text().withDefault(const Constant('Uncategorised'))();
  TextColumn get defaultUnit => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class PantryItems extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(Items, #id)();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ShoppingLists extends Table {
  TextColumn get id => text()();
  DateTimeColumn get generatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ListItems extends Table {
  TextColumn get id => text()();
  TextColumn get listId => text().references(ShoppingLists, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  RealColumn get quantityRequired => real()();
  RealColumn get quantityInPantry => real()();
  RealColumn get quantityToBuy => real()();
  TextColumn get unit => text()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  BoolColumn get addedManually => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// --- DAO ---

@DriftAccessor(tables: [ListItems, Items, PantryItems])
class ShoppingDao extends DatabaseAccessor<AppDatabase>
    with _$ShoppingDaoMixin {
  ShoppingDao(super.db);

  // Joined query — returns raw rows with ingredient fields included
  Future<List<TypedResult>> getItemsWithIngredients(String listId) {
    final query = select(listItems).join([
      innerJoin(
        items,
        items.id.equalsExp(ListItems().itemId),
      ),
    ])
      ..where(listItems.listId.equals(listId))
      ..orderBy([
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

  Future<double> getPantryStock(String itemId) async {
    final row = await (select(pantryItems)
      ..where((p) => p.itemId.equals(itemId)))
        .getSingleOrNull();
    return row?.quantity ?? 0;
  }

  Future<void> insertItem(Insertable<Item> item) =>
      into(items).insert(item);

  Future<void> insertListItem(Insertable<ListItem> item) =>
      into(listItems).insert(item);

  Future<void> updateChecked(String itemId, bool checked) =>
      (update(listItems)..where((i) => i.id.equals(itemId)))
          .write(ListItemsCompanion(checked: Value(checked)));
}

// --- Database ---

@DriftDatabase(tables: [Items, PantryItems, ShoppingLists, ListItems], daos: [ShoppingDao])
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