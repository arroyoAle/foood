import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'database.g.dart';

// --- Tables ---

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get defaultUnits => text()();
  TextColumn get category => text().withDefault(const Constant('Uncategorised'))();

  @override
  Set<Column> get primaryKey => {id};
}

class PantryItems extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(Items, #id)();
  RealColumn get quantity => real()();
  TextColumn get units => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ShoppingLists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
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

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeIngredients extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text().references(Recipes, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  RealColumn get quantity => real()();
  TextColumn get units => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Instructions extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text().references(Recipes, #id)();
  TextColumn get textContent => text()();
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

  Future<double> getPantryStock(String itemId) async {
    final row = await (select(pantryItems)
      ..where((p) => p.itemId.equals(itemId)))
        .getSingleOrNull();
    return row?.quantity ?? 0;
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

  Future<void> updateShoppingListItem({
    required String id,
    required double quantityRequired,
    required double quantityToBuy,
    required String units,
  }) {
    return (update(shoppingListItems)..where((i) => i.id.equals(id))).write(
      ShoppingListItemsCompanion(
        quantityRequired: Value(quantityRequired),
        quantityToBuy: Value(quantityToBuy),
        units: Value(units),
      ),
    );
  }

  Future<void> updateOrdering(String id, int ordering) {
    return (update(shoppingListItems)..where((i) => i.id.equals(id))).write(
      ShoppingListItemsCompanion(ordering: Value(ordering)),
    );
  }

  Future<void> updateAllOrderings(List<({String id, int ordering})> updates) async {
    await batch((batch) {
      for (final update in updates) {
        batch.update(
          shoppingListItems,
          ShoppingListItemsCompanion(ordering: Value(update.ordering)),
          where: (t) => t.id.equals(update.id),
        );
      }
    });
  }

  Future<void> updateItem({
    required String id,
    required String name,
    required String category,
    required String units,
  }) {
    return (update(items)..where((i) => i.id.equals(id))).write(
      ItemsCompanion(
        name: Value(name),
        category: Value(category),
        defaultUnits: Value(units),
      ),
    );
  }

  Future<List<ShoppingList>> getAllLists() {
    return select(shoppingLists).get();
  }

  Future<ShoppingList> createList(String name) async {
    final id = const Uuid().v4();
    final list = ShoppingListsCompanion.insert(
      id: id,
      name: name,
      generatedAt: DateTime.now(),
    );
    await into(shoppingLists).insert(list);
    return ShoppingList(id: id, name: name, generatedAt: DateTime.now());
  }

}

@DriftAccessor(tables: [Recipes, RecipeIngredients, Instructions, Items])
class RecipeDao extends DatabaseAccessor<AppDatabase> with _$RecipeDaoMixin {
  RecipeDao(super.db);

  Future<List<Recipe>> getAllRecipes() => select(recipes).get();

  Future<List<TypedResult>> getRecipeIngredients(String recipeId) {
    return (select(recipeIngredients).join([
      innerJoin(items, items.id.equalsExp(recipeIngredients.itemId)),
    ])..where(recipeIngredients.recipeId.equals(recipeId)))
        .get();
  }

  Future<List<Instruction>> getRecipeInstructions(String recipeId) {
    return (select(instructions)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => OrderingTerm.asc(t.ordering)]))
        .get();
  }

  Future<void> insertRecipe(Insertable<Recipe> recipe) => into(recipes).insert(recipe);

  Future<void> insertRecipeIngredient(Insertable<RecipeIngredient> ingredient) =>
      into(recipeIngredients).insert(ingredient);

  Future<void> insertInstruction(Insertable<Instruction> instruction) =>
      into(instructions).insert(instruction);

  Future<int> getNextInstructionOrdering(String recipeId) async {
    final query = selectOnly(instructions)
      ..addColumns([instructions.ordering.max()])
      ..where(instructions.recipeId.equals(recipeId));
    final result = await query.getSingleOrNull();
    return (result?.read(instructions.ordering.max()) ?? 0) + 1;
  }
}

// --- Database ---

@DriftDatabase(
  tables: [Items, PantryItems, ShoppingLists, ShoppingListItems, Recipes, RecipeIngredients, Instructions],
  daos: [ShoppingDao, RecipeDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'foood_app.db'));
    return NativeDatabase(file);
  });
}