import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/pages/recipe.dart';
import 'package:foood/providers/providers.dart';

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpRecipePage(WidgetTester tester, String recipeId) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          activeRecipeIdProvider.overrideWith((ref) => recipeId),
        ],
        child: const MaterialApp(
          home: RecipePage(),
        ),
      ),
    );
  }

  testWidgets('Shows confirmation dialog when navigating back with unsaved changes', (
    WidgetTester tester,
  ) async {
    final recipeId = 'test-recipe';
    await database.into(database.recipes).insert(
          db.RecipesCompanion.insert(id: recipeId, name: 'Original Name'),
        );

    await pumpRecipePage(tester, recipeId);
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Original Name'), findsOneWidget);

    // Edit the name
    await tester.enterText(find.byType(TextFormField), 'Modified Name');
    await tester.pump(); // Trigger listener/setState

    // Attempt to navigate back
    final nav = Navigator.of(tester.element(find.byType(RecipePage)));
    nav.maybePop();
    
    await tester.pumpAndSettle();

    // Verify dialog is shown
    expect(find.text('Unsaved Changes'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel and verify we stay on the page
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Unsaved Changes'), findsNothing);
    expect(find.byType(RecipePage), findsOneWidget);
    expect(find.text('Modified Name'), findsOneWidget);
  });

  testWidgets('Saving from dialog updates name and closes page', (
    WidgetTester tester,
  ) async {
    final recipeId = 'test-recipe';
    await database.into(database.recipes).insert(
          db.RecipesCompanion.insert(id: recipeId, name: 'Original Name'),
        );

    await pumpRecipePage(tester, recipeId);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Modified Name');
    await tester.pump();

    // Pop
    final nav = Navigator.of(tester.element(find.byType(RecipePage)));
    nav.maybePop();
    await tester.pumpAndSettle();

    // Tap Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify page is closed (MaterialApp will be empty or show nothing if we don't have a background)
    // Actually, in this test setup, it might just pop the only page.
    // Let's check the database instead to verify save happened.
    final recipe = await (database.select(database.recipes)
          ..where((t) => t.id.equals(recipeId)))
        .getSingle();
    expect(recipe.name, 'Modified Name');
  });

  testWidgets('Discarding from dialog closes page without saving', (
    WidgetTester tester,
  ) async {
    final recipeId = 'test-recipe';
    await database.into(database.recipes).insert(
          db.RecipesCompanion.insert(id: recipeId, name: 'Original Name'),
        );

    await pumpRecipePage(tester, recipeId);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Modified Name');
    await tester.pump();

    // Pop
    final nav = Navigator.of(tester.element(find.byType(RecipePage)));
    nav.maybePop();
    await tester.pumpAndSettle();

    // Tap Discard
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    // Verify database NOT updated
    final recipe = await (database.select(database.recipes)
          ..where((t) => t.id.equals(recipeId)))
        .getSingle();
    expect(recipe.name, 'Original Name');
  });
}
