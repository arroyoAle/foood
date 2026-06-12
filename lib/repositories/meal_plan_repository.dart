import 'package:uuid/uuid.dart';
import '../data/database.dart' as db;
import '../models/meal_plan.dart';
import 'recipe_repository.dart';

class MealPlanRepository {
  final db.AppDatabase _db;
  final RecipeRepository _recipeRepository;
  final _uuid = const Uuid();

  MealPlanRepository(this._db, this._recipeRepository);

  Future<List<MealPlanEntryModel>> getMealPlanForWeek(
    DateTime weekStartDate,
  ) async {
    // 1. Get or create MealPlan for this week
    var mealPlan = await _db.mealPlanDao.getMealPlanForWeek(weekStartDate);
    if (mealPlan == null) {
      final id = _uuid.v4();
      await _db.mealPlanDao.insertMealPlan(
        db.MealPlansCompanion.insert(id: id, weekStartDate: weekStartDate),
      );
      return [];
    }

    // 2. Get all entries for this plan
    final entries = await _db.mealPlanDao.getEntriesForMealPlan(mealPlan.id);
    final result = <MealPlanEntryModel>[];

    for (final entry in entries) {
      // 3. Get recipes for each entry
      final recipeResults = await _db.mealPlanDao.getRecipesForEntry(entry.id);
      final recipeModels = <MealPlanEntryRecipeModel>[];

      for (final res in recipeResults) {
        final entryRecipe = res.readTable(_db.mealPlanEntryRecipes);
        final recipeRow = res.readTable(_db.recipes);

        final fullRecipe = await _recipeRepository.hydrateRecipe(recipeRow);

        recipeModels.add(
          MealPlanEntryRecipeModel(
            id: entryRecipe.id,
            recipe: fullRecipe,
            servings: entryRecipe.servings,
          ),
        );
      }

      result.add(
        MealPlanEntryModel(
          id: entry.id,
          date: entry.date,
          mealType: entry.mealType,
          recipes: recipeModels,
        ),
      );
    }

    return result;
  }

  Future<void> addRecipeToMeal({
    required DateTime weekStartDate,
    required DateTime date,
    required String mealType,
    required String recipeId,
    required double servings,
  }) async {
    // 1. Get or create MealPlan for this week
    var mealPlan = await _db.mealPlanDao.getMealPlanForWeek(weekStartDate);
    if (mealPlan == null) {
      final id = _uuid.v4();
      await _db.mealPlanDao.insertMealPlan(
        db.MealPlansCompanion.insert(id: id, weekStartDate: weekStartDate),
      );
      mealPlan = await _db.mealPlanDao.getMealPlanForWeek(weekStartDate);
    }

    if (mealPlan == null) return;

    // 2. Find or create entry for this day and mealType
    final entries = await _db.mealPlanDao.getEntriesForMealPlan(mealPlan.id);
    var entry = entries
        .where((e) => e.date == date && e.mealType == mealType)
        .firstOrNull;

    if (entry == null) {
      final entryId = _uuid.v4();
      await _db.mealPlanDao.insertMealPlanEntry(
        db.MealPlanEntriesCompanion.insert(
          id: entryId,
          mealPlanId: mealPlan.id,
          date: date,
          mealType: mealType,
        ),
      );
      entry = (await _db.mealPlanDao.getEntriesForMealPlan(
        mealPlan.id,
      )).firstWhere((e) => e.id == entryId);
    }

    // 3. Add recipe to entry
    await _db.mealPlanDao.insertMealPlanEntryRecipe(
      db.MealPlanEntryRecipesCompanion.insert(
        id: _uuid.v4(),
        mealPlanEntryId: entry.id,
        recipeId: recipeId,
        servings: servings,
      ),
    );
  }

  Future<void> removeRecipeFromMeal(String entryRecipeId) async {
    await _db.mealPlanDao.deleteMealPlanEntryRecipe(entryRecipeId);
  }

  Future<void> updateServings(String entryRecipeId, double servings) async {
    await _db.mealPlanDao.updateMealPlanEntryRecipe(
      id: entryRecipeId,
      servings: servings,
    );
  }
}
