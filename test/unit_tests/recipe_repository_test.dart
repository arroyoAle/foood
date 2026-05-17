import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/repositories/recipe_repository.dart';
import 'package:foood/repositories/shopping_list_repository.dart';

void main() {
  late db.AppDatabase database;
  late RecipeRepository recipeRepository;
  late ShoppingRepository shoppingRepository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    recipeRepository = RecipeRepository(database);
    shoppingRepository = ShoppingRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('RecipeRepository', () {
    test('createRecipe creates a new recipe', () async {
      final recipe = await recipeRepository.createRecipe('Pasta');
      expect(recipe.name, 'Pasta');

      final allRecipes = await recipeRepository.getAllRecipes();
      expect(allRecipes.length, 1);
      expect(allRecipes.first.name, 'Pasta');
    });

    test('addIngredient adds an ingredient to a recipe', () async {
      final recipe = await recipeRepository.createRecipe('Pasta');
      final item = await shoppingRepository.findOrCreateItem(
        name: 'Flour',
        units: 'g',
      );

      await recipeRepository.addIngredient(recipe.id, item, 500.0, 'g');

      final recipes = await recipeRepository.getAllRecipes();
      expect(recipes.first.ingredients.length, 1);
      expect(recipes.first.ingredients.first.item.name, 'Flour');
    });

    test('addInstruction adds an instruction to a recipe', () async {
      final recipe = await recipeRepository.createRecipe('Pasta');

      await recipeRepository.addInstruction(recipe.id, 'Boil water');
      await recipeRepository.addInstruction(recipe.id, 'Add pasta');

      final recipes = await recipeRepository.getAllRecipes();
      expect(recipes.first.instructions.length, 2);
      expect(recipes.first.instructions[0].text, 'Boil water');
      expect(recipes.first.instructions[1].text, 'Add pasta');
    });

    test('updateRecipeName updates the name', () async {
      final recipe = await recipeRepository.createRecipe('Pasta');
      await recipeRepository.updateRecipeName(recipe.id, 'Spaghetti');

      final recipes = await recipeRepository.getAllRecipes();
      expect(recipes.first.name, 'Spaghetti');
    });
  });
}
