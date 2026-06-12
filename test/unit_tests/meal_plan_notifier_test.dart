import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/providers/providers.dart';
import 'package:foood/repositories/meal_plan_repository.dart';
import 'package:foood/repositories/recipe_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late ProviderContainer container;
  late db.AppDatabase database;
  late RecipeRepository recipeRepository;
  late MealPlanRepository mealPlanRepository;

  final monday = DateTime.utc(2024, 1, 1);

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    recipeRepository = RecipeRepository(database);
    mealPlanRepository = MealPlanRepository(database, recipeRepository);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        recipeRepositoryProvider.overrideWithValue(recipeRepository),
        mealPlanRepositoryProvider.overrideWithValue(mealPlanRepository),
        selectedWeekProvider.overrideWith((ref) => monday),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('MealPlanNotifier', () {
    test('initial state is empty for a new week', () async {
      final state = await container.read(mealPlanProvider.future);
      expect(state, isEmpty);
    });

    test('addRecipeToMeal updates state', () async {
      final recipe = await recipeRepository.createRecipe('Pasta');
      
      await container.read(mealPlanProvider.notifier).addRecipeToMeal(
        date: monday,
        mealType: 'Dinner',
        recipeId: recipe.id,
        servings: 2,
      );

      final state = await container.read(mealPlanProvider.future);
      expect(state.length, 1);
      expect(state.first.recipes.first.recipe.name, 'Pasta');
    });

    test('updateServings refreshes state', () async {
      final recipe = await recipeRepository.createRecipe('Pasta');
      await container.read(mealPlanProvider.notifier).addRecipeToMeal(
        date: monday,
        mealType: 'Dinner',
        recipeId: recipe.id,
        servings: 2,
      );

      final initialState = await container.read(mealPlanProvider.future);
      final entryRecipeId = initialState.first.recipes.first.id;

      await container.read(mealPlanProvider.notifier).updateServings(entryRecipeId, 5);

      final updatedState = await container.read(mealPlanProvider.future);
      expect(updatedState.first.recipes.first.servings, 5);
    });

    test('removeRecipeFromMeal refreshes state', () async {
      final recipe = await recipeRepository.createRecipe('Pasta');
      await container.read(mealPlanProvider.notifier).addRecipeToMeal(
        date: monday,
        mealType: 'Dinner',
        recipeId: recipe.id,
        servings: 2,
      );

      final initialState = await container.read(mealPlanProvider.future);
      final entryRecipeId = initialState.first.recipes.first.id;

      await container.read(mealPlanProvider.notifier).removeRecipeFromMeal(entryRecipeId);

      final updatedState = await container.read(mealPlanProvider.future);
      expect(updatedState.first.recipes, isEmpty);
    });

    test('changing selectedWeek updates mealPlanProvider', () async {
      final recipe = await recipeRepository.createRecipe('Monday Meal');
      await container.read(mealPlanProvider.notifier).addRecipeToMeal(
        date: monday,
        mealType: 'Dinner',
        recipeId: recipe.id,
      );

      // Verify current week has the meal
      expect((await container.read(mealPlanProvider.future)).length, 1);

      // Change week
      final nextMonday = monday.add(const Duration(days: 7));
      container.read(selectedWeekProvider.notifier).state = nextMonday;

      // New week should be empty
      expect((await container.read(mealPlanProvider.future)).length, 0);
    });
  });
}
