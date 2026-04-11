import 'package:foood/data/storage.dart';
import 'package:foood/models/recipe.dart';

import '../models/item.dart';

class RecipeManager {
  final Storage _storage = Storage();
  final String _recipeNamesFileName = 'recipes_data';
  List<Recipe> _recipes = [];
  Recipe? activeRecipe;
  List<Recipe> get allRecipes => _recipes;

  Future<void> loadRecipes() async {
    final recipeNames = await _storage.read(_recipeNamesFileName);
    _recipes = [];

    if (recipeNames is Map && recipeNames.isNotEmpty) {
      for (var recipeName in recipeNames.values) {
        final listJson = await _storage.read(recipeName as String);
        if (listJson is Map<String, dynamic> && listJson.isNotEmpty) {
          _recipes.add(Recipe.fromJson(listJson));
        }
      }
    }
  }

  void setActiveRecipe(Recipe recipe) {
    activeRecipe = recipe;
  }

  Future<void> saveActiveRecipe() async {
    if (activeRecipe == null) return;
    await _storage.write(activeRecipe!.name, activeRecipe!.toJson());
  }

  Future<Recipe> createNewRecipe(String recipeName) async {
    if (_recipes.any((recipe) => recipe.name == recipeName)) {
      throw Exception('A recipe with this name already exists.');
    }

    final newRecipe = Recipe.empty();
    newRecipe.name = recipeName;
    _recipes.add(newRecipe);

    await _storage.write(newRecipe.name, newRecipe.toJson());
    await _updateRecipeNames();

    return newRecipe;
  }

  Future<void> _updateRecipeNames() async {
    final allRecipeNames = Map.fromEntries(_recipes.map(
            (recipe) => MapEntry(recipe.id, recipe.name))
    );
    await _storage.write(_recipeNamesFileName, allRecipeNames);
  }

  Future<void> addIngredientToRecipe(String recipeId, Item ingredient) async {

  }

  Future<void> addInstructionToRecipe(String recipeId, String instruction) async {

  }
}