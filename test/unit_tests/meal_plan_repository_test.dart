import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/repositories/meal_plan_repository.dart';
import 'package:foood/repositories/recipe_repository.dart';

void main() {
  late db.AppDatabase database;
  late MealPlanRepository mealPlanRepository;
  late RecipeRepository recipeRepository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    recipeRepository = RecipeRepository(database);
    mealPlanRepository = MealPlanRepository(database, recipeRepository);
  });

  tearDown(() async {
    await database.close();
  });

  group('MealPlanRepository', () {
    final monday = DateTime.utc(2024, 1, 1); // A Monday

    test('getMealPlanForWeek creates a plan if it does not exist', () async {
      final entries = await mealPlanRepository.getMealPlanForWeek(monday);
      expect(entries, isEmpty);

      // Verify it was created in DB
      final plan = await database.mealPlanDao.getMealPlanForWeek(monday);
      expect(plan, isNotNull);
      expect(plan!.weekStartDate.toUtc(), monday);
    });

    test('addRecipeToMeal adds a recipe and creates entry', () async {
      final recipe = await recipeRepository.createRecipe('Pasta');

      await mealPlanRepository.addRecipeToMeal(
        weekStartDate: monday,
        date: monday,
        mealType: 'Dinner',
        recipeId: recipe.id,
        servings: 2,
      );

      final entries = await mealPlanRepository.getMealPlanForWeek(monday);
      expect(entries.length, 1);
      expect(entries.first.mealType, 'Dinner');
      expect(entries.first.recipes.length, 1);
      expect(entries.first.recipes.first.recipe.name, 'Pasta');
      expect(entries.first.recipes.first.servings, 2);
    });

    test('updateServings updates the serving count', () async {
      final recipe = await recipeRepository.createRecipe('Pasta');
      await mealPlanRepository.addRecipeToMeal(
        weekStartDate: monday,
        date: monday,
        mealType: 'Dinner',
        recipeId: recipe.id,
        servings: 2,
      );

      final initialEntries = await mealPlanRepository.getMealPlanForWeek(
        monday,
      );
      final entryRecipeId = initialEntries.first.recipes.first.id;

      await mealPlanRepository.updateServings(entryRecipeId, 4);

      final updatedEntries = await mealPlanRepository.getMealPlanForWeek(
        monday,
      );
      expect(updatedEntries.first.recipes.first.servings, 4);
    });

    test('removeRecipeFromMeal removes the recipe', () async {
      final recipe = await recipeRepository.createRecipe('Pasta');
      await mealPlanRepository.addRecipeToMeal(
        weekStartDate: monday,
        date: monday,
        mealType: 'Dinner',
        recipeId: recipe.id,
        servings: 2,
      );

      final initialEntries = await mealPlanRepository.getMealPlanForWeek(
        monday,
      );
      final entryRecipeId = initialEntries.first.recipes.first.id;

      await mealPlanRepository.removeRecipeFromMeal(entryRecipeId);

      final updatedEntries = await mealPlanRepository.getMealPlanForWeek(
        monday,
      );
      expect(updatedEntries.first.recipes, isEmpty);
    });

    test('multiple recipes in one meal slot', () async {
      final main = await recipeRepository.createRecipe('Steak');
      final side = await recipeRepository.createRecipe('Salad');

      await mealPlanRepository.addRecipeToMeal(
        weekStartDate: monday,
        date: monday,
        mealType: 'Dinner',
        recipeId: main.id,
        servings: 1,
      );
      await mealPlanRepository.addRecipeToMeal(
        weekStartDate: monday,
        date: monday,
        mealType: 'Dinner',
        recipeId: side.id,
        servings: 1,
      );

      final entries = await mealPlanRepository.getMealPlanForWeek(monday);
      expect(entries.length, 1);
      expect(entries.first.recipes.length, 2);
      expect(
        entries.first.recipes.any((r) => r.recipe.name == 'Steak'),
        isTrue,
      );
      expect(
        entries.first.recipes.any((r) => r.recipe.name == 'Salad'),
        isTrue,
      );
    });
  });
}
