import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../data/database.dart' as db;
import '../models/recipe.dart';
import '../models/item.dart';
import '../models/recipe_ingredient.dart';
import '../models/instruction.dart';

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
      final recipeIngredient = result.readTable(_db.recipeIngredients);
      return RecipeIngredient(
        id: recipeIngredient.id,
        itemId: item.id,
        item: Item(
          id: item.id,
          name: item.name,
          defaultUnits: item.defaultUnits,
          category: item.category,
        ),
        quantity: recipeIngredient.quantity,
        units: recipeIngredient.units,
      );
    }).toList();

    final instructions = instructionRows
        .map((i) => Instruction(id: i.id, text: i.textContent))
        .toList();

    return Recipe(
      id: row.id,
      name: row.name,
      instructions: instructions,
      ingredients: ingredients,
    );
  }

  Future<Recipe> createRecipe(String name) async {
    final id = _uuid.v4();
    final companion = db.RecipesCompanion.insert(id: id, name: name);
    await _db.recipeDao.insertRecipe(companion);
    return Recipe(id: id, name: name, instructions: [], ingredients: []);
  }

  Future<void> addIngredient(
    String recipeId,
    Item item,
    double quantity,
    String units,
  ) async {
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
    await (_db.update(_db.recipes)..where((t) => t.id.equals(recipeId))).write(
      db.RecipesCompanion(name: Value(name)),
    );
  }

  Future<void> updateIngredient(
    String ingredientId,
    double quantity,
    String units,
  ) async {
    // We need the itemId to call the Dao method. 
    // Usually, we'd fetch the current ingredient or assume it doesn't change here.
    // If the requirement is just to edit quantity/units like shopping items.
    
    // Let's check what RecipeIngredient row looks like.
    final row = await (_db.select(_db.recipeIngredients)..where((t) => t.id.equals(ingredientId))).getSingle();

    await _db.recipeDao.updateIngredient(
      id: ingredientId,
      itemId: row.itemId,
      quantity: quantity,
      units: units,
    );
  }

  Future<void> updateInstruction(String instructionId, String text) async {
    await _db.recipeDao.updateInstruction(
      id: instructionId,
      textContent: text,
    );
  }
}
