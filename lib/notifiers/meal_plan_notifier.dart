import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_plan.dart';
import '../providers/providers.dart';

class MealPlanNotifier extends AsyncNotifier<List<MealPlanEntryModel>> {
  @override
  Future<List<MealPlanEntryModel>> build() async {
    final selectedWeek = ref.watch(selectedWeekProvider);
    return ref
        .read(mealPlanRepositoryProvider)
        .getMealPlanForWeek(selectedWeek);
  }

  Future<void> addRecipeToMeal({
    required DateTime date,
    required String mealType,
    required String recipeId,
    int servings = 1,
  }) async {
    state = const AsyncLoading<List<MealPlanEntryModel>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() async {
      final weekStartDate = ref.read(selectedWeekProvider);
      await ref
          .read(mealPlanRepositoryProvider)
          .addRecipeToMeal(
            weekStartDate: weekStartDate,
            date: date,
            mealType: mealType,
            recipeId: recipeId,
            servings: servings,
          );
      return ref
          .read(mealPlanRepositoryProvider)
          .getMealPlanForWeek(weekStartDate);
    });
  }

  Future<void> addMealWithSides({
    required DateTime date,
    required String mealType,
    required String mainRecipeId,
    required int mainServings,
    required List<({String recipeId, int servings})> sides,
  }) async {
    state = const AsyncLoading<List<MealPlanEntryModel>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() async {
      final weekStartDate = ref.read(selectedWeekProvider);
      await ref
          .read(mealPlanRepositoryProvider)
          .addMealWithSides(
            weekStartDate: weekStartDate,
            date: date,
            mealType: mealType,
            mainRecipeId: mainRecipeId,
            mainServings: mainServings,
            sides: sides,
          );
      return ref
          .read(mealPlanRepositoryProvider)
          .getMealPlanForWeek(weekStartDate);
    });
  }

  Future<void> removeRecipeFromMeal(String entryRecipeId) async {
    state = const AsyncLoading<List<MealPlanEntryModel>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() async {
      final weekStartDate = ref.read(selectedWeekProvider);
      await ref
          .read(mealPlanRepositoryProvider)
          .removeRecipeFromMeal(entryRecipeId);
      return ref
          .read(mealPlanRepositoryProvider)
          .getMealPlanForWeek(weekStartDate);
    });
  }

  Future<void> updateServings(String entryRecipeId, int servings) async {
    state = const AsyncLoading<List<MealPlanEntryModel>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() async {
      final weekStartDate = ref.read(selectedWeekProvider);
      await ref
          .read(mealPlanRepositoryProvider)
          .updateServings(entryRecipeId, servings);
      return ref
          .read(mealPlanRepositoryProvider)
          .getMealPlanForWeek(weekStartDate);
    });
  }
}
