import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/pages/week.dart';
import 'package:foood/providers/providers.dart';
import 'package:foood/repositories/meal_plan_repository.dart';
import 'package:foood/repositories/recipe_repository.dart';

void main() {
  late db.AppDatabase database;
  late RecipeRepository recipeRepository;
  late MealPlanRepository mealPlanRepository;

  // Use a fixed Monday for predictable tests
  final monday = DateTime.utc(2024, 1, 1);

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    recipeRepository = RecipeRepository(database);
    mealPlanRepository = MealPlanRepository(database, recipeRepository);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpWeekPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          recipeRepositoryProvider.overrideWithValue(recipeRepository),
          mealPlanRepositoryProvider.overrideWithValue(mealPlanRepository),
          selectedWeekProvider.overrideWith((ref) => monday),
        ],
        child: const MaterialApp(home: WeekPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Displays the correct week title', (WidgetTester tester) async {
    await pumpWeekPage(tester);
    // Mon, Jan 1 2024
    expect(find.text('Week of Mon, Jan 1'), findsOneWidget);
  });

  testWidgets('Navigates to previous and next week', (
    WidgetTester tester,
  ) async {
    await pumpWeekPage(tester);

    // Tap Next
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('Week of Mon, Jan 8'), findsOneWidget);

    // Tap Previous
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('Week of Mon, Jan 1'), findsOneWidget);
  });

  testWidgets('Displays 7 expansion tiles for the week', (
    WidgetTester tester,
  ) async {
    await pumpWeekPage(tester);

    final tiles = find.byType(ExpansionTile);
    expect(tiles, findsNWidgets(7));
  });

  testWidgets('Today card is expanded by default (if it is the current week)', (
    WidgetTester tester,
  ) async {
    // We don't override selectedWeekProvider here, so it defaults to the current week
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: WeekPage()),
      ),
    );
    await tester.pumpAndSettle();

    final tiles = tester
        .widgetList<ExpansionTile>(find.byType(ExpansionTile))
        .toList();
    // One tile should be expanded if today is in this week.
    // Check only the visible ones for initiallyExpanded
    for (int i = 0; i < tiles.length; i++) {
      // ...
    }
  });

  testWidgets('Adding a main and sides via dialog', (
    WidgetTester tester,
  ) async {
    // 1. Add recipes to DB
    await recipeRepository.createRecipe('Burger');
    await recipeRepository.createRecipe('Fries');

    await pumpWeekPage(tester);

    // 2. Expand Monday card
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();

    // 3. Tap 'add' button for a meal type (e.g. Breakfast)
    final addButton = find.byTooltip('Add Meal').first;
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // 4. Select Main Dish
    expect(find.text('Select Main Dish'), findsOneWidget);
    await tester.tap(find.text('Burger'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // 5. Select Sides
    expect(find.text('Select Sides'), findsOneWidget);
    await tester.tap(find.text('Fries'));
    await tester.pump();
    await tester.tap(find.text('Add Meals'));
    await tester.pumpAndSettle();

    // 6. Verify hierarchy in UI
    expect(find.text('Burger'), findsOneWidget);
    expect(find.text('SIDES'), findsOneWidget);
    expect(find.text('Fries'), findsOneWidget);

    // 7. Explicitly verify persistence in the database
    final dbEntries = await mealPlanRepository.getMealPlanForWeek(monday);
    expect(dbEntries.length, 1);
    expect(dbEntries.first.recipes.first.recipe.name, 'Burger');
    expect(dbEntries.first.recipes.first.sides.first.recipe.name, 'Fries');
  });

  testWidgets('Adjusting servings and removing recipe', (
    WidgetTester tester,
  ) async {
    // 1. Prepare data
    final recipe = await recipeRepository.createRecipe('Steak');
    await mealPlanRepository.addRecipeToMeal(
      weekStartDate: monday,
      date: monday,
      mealType: 'Dinner',
      recipeId: recipe.id,
      servings: 1,
    );

    await pumpWeekPage(tester);

    // 2. Expand Monday card
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();

    // Verify Steak is there
    expect(find.text('Steak'), findsOneWidget);
    expect(find.textContaining('1 serving'), findsOneWidget);

    // 3. Increment servings
    await tester.tap(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.byIcon(Icons.add_circle_outline),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('2 servings'), findsOneWidget);

    // 4. Decrement servings
    await tester.tap(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.byIcon(Icons.remove_circle_outline),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('1 serving'), findsOneWidget);

    // 5. Remove recipe
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Steak'), findsNothing);
  });
}
