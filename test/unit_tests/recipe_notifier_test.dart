import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/providers/providers.dart';
import 'package:drift/native.dart';
import 'package:foood/repositories/recipe_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late ProviderContainer container;
  late db.AppDatabase database;
  late RecipeRepository recipeRepository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    recipeRepository = RecipeRepository(database);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        recipeRepositoryProvider.overrideWithValue(recipeRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('RecipeNotifier', () {
    test('createRecipe adds a new recipe to the list', () async {
      await container.read(recipesProvider.notifier).createRecipe('New Recipe');

      final recipes = await container.read(recipesProvider.future);
      expect(recipes.any((r) => r.name == 'New Recipe'), isTrue);
    });

    test('updateRecipeName updates name and refreshes state', () async {
      // Create an initial recipe
      await recipeRepository.createRecipe('Original Name');

      // Initial state
      var recipes = await container.read(recipesProvider.future);
      expect(recipes.first.name, 'Original Name');
      final recipeId = recipes.first.id;

      // Update name via notifier
      await container
          .read(recipesProvider.notifier)
          .updateRecipeName(recipeId, 'New Name');

      // Check state updated
      recipes = await container.read(recipesProvider.future);
      expect(recipes.first.name, 'New Name');

      // Verify database updated
      final dbRecipes = await recipeRepository.getAllRecipes();
      expect(dbRecipes.any((r) => r.name == 'New Name'), isTrue);
    });

    test('addIngredient adds an ingredient and refreshes state', () async {
      final recipe = await recipeRepository.createRecipe('Recipe');
      final item = await container
          .read(shoppingRepositoryProvider)
          .findOrCreateItem(name: 'Salt', units: 'tsp');

      await container
          .read(recipesProvider.notifier)
          .addIngredient(recipe.id, item, 1.0, 'tsp');

      final recipes = await container.read(recipesProvider.future);
      final updatedRecipe = recipes.firstWhere((r) => r.id == recipe.id);
      expect(updatedRecipe.ingredients.any((i) => i.item.name == 'Salt'), isTrue);
    });

    test('addInstruction adds an instruction and refreshes state', () async {
      final recipe = await recipeRepository.createRecipe('Recipe');

      await container
          .read(recipesProvider.notifier)
          .addInstruction(recipe.id, 'Mix well');

      final recipes = await container.read(recipesProvider.future);
      final updatedRecipe = recipes.firstWhere((r) => r.id == recipe.id);
      expect(updatedRecipe.instructions.any((i) => i.text == 'Mix well'), isTrue);
    });
  });
}
