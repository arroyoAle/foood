import 'package:drift/drift.dart';
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
    final utcWeekStart = weekStartDate.toUtc();
    var mealPlan = await _db.mealPlanDao.getMealPlanForWeek(utcWeekStart);
    if (mealPlan == null) {
      await _db.mealPlanDao.insertMealPlan(
        db.MealPlansCompanion.insert(weekStartDate: utcWeekStart),
      );
      // Refresh
      mealPlan = await _db.mealPlanDao.getMealPlanForWeek(utcWeekStart);
      if (mealPlan == null) return [];
    }

    final entries = await _db.mealPlanDao.getEntriesForMealPlan(utcWeekStart);
    final result = <MealPlanEntryModel>[];

    for (final entry in entries) {
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
    required int servings,
  }) async {
    final utcWeekStart = weekStartDate.toUtc();
    final utcDate = date.toUtc();

    var mealPlan = await _db.mealPlanDao.getMealPlanForWeek(utcWeekStart);
    if (mealPlan == null) {
      await _db
          .into(_db.mealPlans)
          .insert(
            db.MealPlansCompanion.insert(weekStartDate: utcWeekStart),
            mode: InsertMode.insertOrIgnore,
          );
      mealPlan = await _db.mealPlanDao.getMealPlanForWeek(utcWeekStart);
    }

    if (mealPlan == null) return;

    final entries = await _db.mealPlanDao.getEntriesForMealPlan(utcWeekStart);
    var entry = entries
        .where((e) => e.date.toUtc() == utcDate && e.mealType == mealType)
        .firstOrNull;

    if (entry == null) {
      final entryId = _uuid.v4();
      await _db.mealPlanDao.insertMealPlanEntry(
        db.MealPlanEntriesCompanion.insert(
          id: entryId,
          weekStartDate: utcWeekStart,
          date: utcDate,
          mealType: mealType,
        ),
      );
      entry = (await _db.mealPlanDao.getEntriesForMealPlan(
        utcWeekStart,
      )).firstWhere((e) => e.id == entryId);
    }

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

  Future<void> updateServings(String entryRecipeId, int servings) async {
    await _db.mealPlanDao.updateMealPlanEntryRecipe(
      id: entryRecipeId,
      servings: servings,
    );
  }
}
