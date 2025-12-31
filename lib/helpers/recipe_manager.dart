import 'package:foood/helpers/storage.dart';
import 'package:foood/models/recipe.dart';

class RecipeManager {
  final Storage _storage = Storage();
  final String _recipeNamesFileName = 'recipes_data';
  List<Recipe> _recipes = [];
  Recipe? activeRecipe;
  List<Recipe> get allRecipes => _recipes;

  Future<void> loadRecipes() async {
    final data = await _storage.read(_recipeNamesFileName);
    if (data is List) {
      _recipes = data.map(
              (recipeJson) => Recipe.fromJson(recipeJson as Map<String, dynamic>)
      ).toList();
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
}