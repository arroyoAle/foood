import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/pages/home.dart';
import 'package:foood/pages/recipe.dart';
import 'package:foood/pages/shopping_lists/shopping_list_screen.dart';
import 'package:foood/providers/providers.dart';

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpHomePage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: const MyHomePage(),
          routes: {
            '/lists': (context) => const Scaffold(body: Text('All Lists Page')),
            '/recipes': (context) =>
                const Scaffold(body: Text('All Recipes Page')),
          },
        ),
      ),
    );
  }

  testWidgets('Shows empty states when no data exists', (
    WidgetTester tester,
  ) async {
    await pumpHomePage(tester);
    await tester.pumpAndSettle();

    expect(find.text('No lists'), findsOneWidget);
    expect(find.text('No recipes'), findsOneWidget);
    expect(find.text('Test meal 1'), findsOneWidget);
  });

  testWidgets('Displays shopping lists and recipes when data exists', (
    WidgetTester tester,
  ) async {
    // Add shopping lists
    await database.shoppingDao.createList('Weekly Groceries');

    // Add recipe (direct database insert since repository might be complex to mock/use)
    await database
        .into(database.recipes)
        .insert(db.RecipesCompanion.insert(id: 'r1', name: 'Pasta Carbonara'));

    await pumpHomePage(tester);
    await tester.pumpAndSettle();

    expect(find.text('Weekly Groceries'), findsOneWidget);
    expect(find.text('Pasta Carbonara'), findsOneWidget);
  });

  testWidgets('Tapping a shopping list navigates to ShoppingListScreen', (
    WidgetTester tester,
  ) async {
    await database.shoppingDao.createList('Weekly Groceries');

    await pumpHomePage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weekly Groceries'));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingListScreen), findsOneWidget);
  });

  testWidgets('Tapping a recipe navigates to RecipePage', (
    WidgetTester tester,
  ) async {
    await database
        .into(database.recipes)
        .insert(db.RecipesCompanion.insert(id: 'r1', name: 'Pasta Carbonara'));

    await pumpHomePage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pasta Carbonara'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipePage), findsOneWidget);
  });

  testWidgets('Dashboard cards navigate to their sections', (
    WidgetTester tester,
  ) async {
    await pumpHomePage(tester);
    await tester.pumpAndSettle();

    // Tap Quick Access card (title or icon)
    await tester.tap(find.text('Quick Access'));
    await tester.pumpAndSettle();
    expect(find.text('All Lists Page'), findsOneWidget);

    // Go back
    Navigator.of(tester.element(find.text('All Lists Page'))).pop();
    await tester.pumpAndSettle();

    // Tap Recent Recipes card
    await tester.tap(find.text('Recent Recipes'));
    await tester.pumpAndSettle();
    expect(find.text('All Recipes Page'), findsOneWidget);
  });
}
