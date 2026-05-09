import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../data/database.dart' as db;
import '../models/recipe.dart';
import '../models/item.dart';

class RecipeRepository {
  final db.AppDatabase _db;
  final _uuid = const Uuid();

  RecipeRepository(this._db);

  Future<List<Recipe>> getAllRecipes() async {
    final recipeRows = await _db.recipeDao.getAllRecipes();
    final recipes = <Recipe>[];

    for (final row in recipeRows) {
      recipes.add(await _hydrateRecipe(row));
    }

    return recipes;
  }

  Future<Recipe> _hydrateRecipe(db.Recipe row) async {
    final ingredientRows = await _db.recipeDao.getRecipeIngredients(row.id);
    final instructionRows = await _db.recipeDao.getRecipeInstructions(row.id);

    final ingredients = ingredientRows.map((result) {
      final item = result.readTable(_db.items);
      return Item(
        id: item.id,
        name: item.name,
        defaultUnits: item.defaultUnits,
        category: item.category,
      );
    }).toList();

    final instructions = instructionRows.map((i) => i.textContent).toList();

    return Recipe(
      id: row.id,
      name: row.name,
      instructions: instructions,
      ingredients: ingredients,
    );
  }

  Future<Recipe> createRecipe(String name) async {
    final id = _uuid.v4();
    final companion = db.RecipesCompanion.insert(
      id: id,
      name: name,
    );
    await _db.recipeDao.insertRecipe(companion);
    return Recipe(id: id, name: name, instructions: [], ingredients: []);
  }

  Future<void> addIngredient(String recipeId, Item item, double quantity, String units) async {
    await _db.recipeDao.insertRecipeIngredient(
      db.RecipeIngredientsCompanion.insert(
        id: _uuid.v4(),
        recipeId: recipeId,
        itemId: item.id,
        quantity: quantity,
        units: units,
      ),
    );
  }

  Future<void> addInstruction(String recipeId, String text) async {
    final ordering = await _db.recipeDao.getNextInstructionOrdering(recipeId);
    await _db.recipeDao.insertInstruction(
      db.InstructionsCompanion.insert(
        id: _uuid.v4(),
        recipeId: recipeId,
        textContent: text,
        ordering: ordering,
      ),
    );
  }

  Future<void> updateRecipeName(String recipeId, String name) async {
    await (_db.update(_db.recipes)..where((t) => t.id.equals(recipeId)))
        .write(db.RecipesCompanion(name: Value(name)));
  }
}
