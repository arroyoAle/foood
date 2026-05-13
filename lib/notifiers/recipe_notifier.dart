import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../models/item.dart';
import '../providers/providers.dart';

class RecipeNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    return ref.read(recipeRepositoryProvider).getAllRecipes();
  }

  Future<void> createRecipe(String name) async {
    state = const AsyncLoading<List<Recipe>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await ref.read(recipeRepositoryProvider).createRecipe(name);
      return ref.read(recipeRepositoryProvider).getAllRecipes();
    });
  }

  Future<void> addIngredient(
    String recipeId,
    Item item,
    double quantity,
    String units,
  ) async {
    state = const AsyncLoading<List<Recipe>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await ref
          .read(recipeRepositoryProvider)
          .addIngredient(recipeId, item, quantity, units);
      return ref.read(recipeRepositoryProvider).getAllRecipes();
    });
  }

  Future<void> addInstruction(String recipeId, String text) async {
    state = const AsyncLoading<List<Recipe>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await ref.read(recipeRepositoryProvider).addInstruction(recipeId, text);
      return ref.read(recipeRepositoryProvider).getAllRecipes();
    });
  }

  Future<void> updateRecipeName(String recipeId, String name) async {
    state = const AsyncLoading<List<Recipe>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await ref.read(recipeRepositoryProvider).updateRecipeName(recipeId, name);
      return ref.read(recipeRepositoryProvider).getAllRecipes();
    });
  }
}
