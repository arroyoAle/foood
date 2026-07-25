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
    final utcWeekStart = DateTime.utc(
      weekStartDate.year,
      weekStartDate.month,
      weekStartDate.day,
    );
    // 1. Get or create MealPlan for this week
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
      final allRecipeModels = <MealPlanEntryRecipeModel>[];

      for (final res in recipeResults) {
        final entryRecipe = res.readTable(_db.mealPlanEntryRecipes);
        final recipeRow = res.readTable(_db.recipes);

        final fullRecipe = await _recipeRepository.hydrateRecipe(recipeRow);

        allRecipeModels.add(
          MealPlanEntryRecipeModel(
            id: entryRecipe.id,
            recipe: fullRecipe,
            servings: entryRecipe.servings,
            parentId: entryRecipe.parentId,
          ),
        );
      }

      // Build hierarchy (1 level: Mains -> Sides)
      final mains = allRecipeModels.where((r) => r.parentId == null).toList();
      final hierarchicalModels = mains.map((main) {
        final sides = allRecipeModels
            .where((r) => r.parentId == main.id)
            .toList();
        return MealPlanEntryRecipeModel(
          id: main.id,
          recipe: main.recipe,
          servings: main.servings,
          sides: sides,
        );
      }).toList();

      result.add(
        MealPlanEntryModel(
          id: entry.id,
          date: entry.date,
          mealType: entry.mealType,
          recipes: hierarchicalModels,
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
    String? parentId,
  }) async {
    final utcWeekStart = DateTime.utc(
      weekStartDate.year,
      weekStartDate.month,
      weekStartDate.day,
    );
    final utcDate = DateTime.utc(date.year, date.month, date.day);

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
        .where(
          (e) =>
              e.date.year == utcDate.year &&
              e.date.month == utcDate.month &&
              e.date.day == utcDate.day &&
              e.mealType == mealType,
        )
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

    // Find next ordering
    final existing = await _db.mealPlanDao.getRecipesForEntry(entry.id);
    final sameLevelCount = existing.where((r) {
      final row = r.readTable(_db.mealPlanEntryRecipes);
      return row.parentId == parentId;
    }).length;

    await _db.mealPlanDao.insertMealPlanEntryRecipe(
      db.MealPlanEntryRecipesCompanion.insert(
        id: _uuid.v4(),
        mealPlanEntryId: entry.id,
        recipeId: recipeId,
        servings: servings,
        parentId: Value(parentId),
        ordering: Value(sameLevelCount),
      ),
    );
  }

  Future<void> addMealWithSides({
    required DateTime weekStartDate,
    required DateTime date,
    required String mealType,
    required String mainRecipeId,
    required int mainServings,
    required List<({String recipeId, int servings})> sides,
  }) async {
    final utcWeekStart = DateTime.utc(
      weekStartDate.year,
      weekStartDate.month,
      weekStartDate.day,
    );
    final utcDate = DateTime.utc(date.year, date.month, date.day);

    // 1. Ensure Plan and Entry exist
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
        .where(
          (e) =>
              e.date.year == utcDate.year &&
              e.date.month == utcDate.month &&
              e.date.day == utcDate.day &&
              e.mealType == mealType,
        )
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

    // 2. Insert Main
    final mainId = _uuid.v4();
    await _db.mealPlanDao.insertMealPlanEntryRecipe(
      db.MealPlanEntryRecipesCompanion.insert(
        id: mainId,
        mealPlanEntryId: entry.id,
        recipeId: mainRecipeId,
        servings: mainServings,
        ordering: const Value(0),
      ),
    );

    // 3. Insert Sides
    for (int i = 0; i < sides.length; i++) {
      await _db.mealPlanDao.insertMealPlanEntryRecipe(
        db.MealPlanEntryRecipesCompanion.insert(
          id: _uuid.v4(),
          mealPlanEntryId: entry.id,
          recipeId: sides[i].recipeId,
          servings: sides[i].servings,
          parentId: Value(mainId),
          ordering: Value(i + 1),
        ),
      );
    }
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
