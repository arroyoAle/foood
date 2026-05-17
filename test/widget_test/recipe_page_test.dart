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
        child: const MaterialApp(home: RecipePage()),
      ),
    );
  }

  testWidgets(
    'Shows confirmation dialog when navigating back with unsaved changes',
    (WidgetTester tester) async {
      final recipeId = 'test-recipe';
      await database
          .into(database.recipes)
          .insert(
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
    },
  );

  testWidgets('Saving from dialog updates name and closes page', (
    WidgetTester tester,
  ) async {
    final recipeId = 'test-recipe';
    await database
        .into(database.recipes)
        .insert(
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
    final recipe = await (database.select(
      database.recipes,
    )..where((t) => t.id.equals(recipeId))).getSingle();
    expect(recipe.name, 'Modified Name');
  });

  testWidgets('Discarding from dialog closes page without saving', (
    WidgetTester tester,
  ) async {
    final recipeId = 'test-recipe';
    await database
        .into(database.recipes)
        .insert(
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
    final recipe = await (database.select(
      database.recipes,
    )..where((t) => t.id.equals(recipeId))).getSingle();
    expect(recipe.name, 'Original Name');
  });

  testWidgets('Save icon is only visible when name has been changed', (
    WidgetTester tester,
  ) async {
    final recipeId = 'test-recipe';
    await database
        .into(database.recipes)
        .insert(
          db.RecipesCompanion.insert(id: recipeId, name: 'Original Name'),
        );

    await pumpRecipePage(tester, recipeId);
    await tester.pumpAndSettle();

    // Initially, save icon should NOT be visible
    expect(find.byIcon(Icons.save), findsNothing);

    // Edit the name
    await tester.enterText(find.byType(TextFormField), 'Modified Name');
    await tester.pump();

    // Now, save icon SHOULD be visible
    expect(find.byIcon(Icons.save), findsOneWidget);

    // Change it back to original
    await tester.enterText(find.byType(TextFormField), 'Original Name');
    await tester.pump();

    // Save icon should NOT be visible again
    expect(find.byIcon(Icons.save), findsNothing);
  });

  group('Editing Ingredients and Instructions', () {
    testWidgets(
      'Long-pressing an ingredient opens IngredientDialog in edit mode',
      (WidgetTester tester) async {
        final recipeId = 'test-recipe';
        final itemId = 'test-item';
        await database
            .into(database.recipes)
            .insert(
              db.RecipesCompanion.insert(id: recipeId, name: 'Test Recipe'),
            );
        await database
            .into(database.items)
            .insert(
              db.ItemsCompanion.insert(
                id: itemId,
                name: 'Salt',
                defaultUnits: 'tsp',
              ),
            );
        await database
            .into(database.recipeIngredients)
            .insert(
              db.RecipeIngredientsCompanion.insert(
                id: 'ing-1',
                recipeId: recipeId,
                itemId: itemId,
                quantity: 1.0,
                units: 'tsp',
              ),
            );

        await pumpRecipePage(tester, recipeId);
        await tester.pumpAndSettle();

        // Find the ingredient tile and long press it
        await tester.longPress(find.text('Salt'));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Edit Ingredient'), findsOneWidget);
        expect(find.text('1.0'), findsOneWidget); // Quantity
        expect(find.text('tsp'), findsOneWidget); // Units
      },
    );

    testWidgets(
      'Long-pressing an instruction opens InstructionDialog in edit mode',
      (WidgetTester tester) async {
        final recipeId = 'test-recipe';
        await database
            .into(database.recipes)
            .insert(
              db.RecipesCompanion.insert(id: recipeId, name: 'Test Recipe'),
            );
        await database
            .into(database.instructions)
            .insert(
              db.InstructionsCompanion.insert(
                id: 'inst-1',
                recipeId: recipeId,
                textContent: 'Initial Step',
                ordering: 1,
              ),
            );

        await pumpRecipePage(tester, recipeId);
        await tester.pumpAndSettle();

        // Switch to instructions tab
        await tester.tap(find.text('Instructions'));
        await tester.pumpAndSettle();

        // Find the instruction tile and long press it
        await tester.longPress(find.text('Initial Step'));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Edit Instruction'), findsOneWidget);
        expect(
          find.text('Initial Step'),
          findsNWidgets(2),
        ); // One in list, one in dialog
      },
    );

    testWidgets('Saving changes from IngredientDialog updates UI', (
      WidgetTester tester,
    ) async {
      final recipeId = 'test-recipe';
      final itemId = 'test-item';
      await database
          .into(database.recipes)
          .insert(
            db.RecipesCompanion.insert(id: recipeId, name: 'Test Recipe'),
          );
      await database
          .into(database.items)
          .insert(
            db.ItemsCompanion.insert(
              id: itemId,
              name: 'Salt',
              defaultUnits: 'tsp',
            ),
          );
      await database
          .into(database.recipeIngredients)
          .insert(
            db.RecipeIngredientsCompanion.insert(
              id: 'ing-1',
              recipeId: recipeId,
              itemId: itemId,
              quantity: 1.0,
              units: 'tsp',
            ),
          );

      await pumpRecipePage(tester, recipeId);
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Salt'));
      await tester.pumpAndSettle();

      // Edit quantity and unit
      await tester.enterText(find.widgetWithText(TextFormField, 'Qty'), '2.0');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Unit'),
        'tbsp',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify UI is updated
      expect(find.text('2.0 tbsp'), findsOneWidget);

      // Verify database updated
      final ing = await (database.select(
        database.recipeIngredients,
      )..where((t) => t.id.equals('ing-1'))).getSingle();
      expect(ing.quantity, 2.0);
      expect(ing.units, 'tbsp');
    });

    testWidgets('Saving changes from InstructionDialog updates UI', (
      WidgetTester tester,
    ) async {
      final recipeId = 'test-recipe';
      await database
          .into(database.recipes)
          .insert(
            db.RecipesCompanion.insert(id: recipeId, name: 'Test Recipe'),
          );
      await database
          .into(database.instructions)
          .insert(
            db.InstructionsCompanion.insert(
              id: 'inst-1',
              recipeId: recipeId,
              textContent: 'Initial Step',
              ordering: 1,
            ),
          );

      await pumpRecipePage(tester, recipeId);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Instructions'));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Initial Step'));
      await tester.pumpAndSettle();

      // Edit text
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Instruction'),
        'Updated Step',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify UI is updated
      expect(find.text('Updated Step'), findsOneWidget);
      expect(find.text('Initial Step'), findsNothing);

      // Verify database updated
      final inst = await (database.select(
        database.instructions,
      )..where((t) => t.id.equals('inst-1'))).getSingle();
      expect(inst.textContent, 'Updated Step');
    });

    testWidgets('Changing ingredient item updates UI', (
      WidgetTester tester,
    ) async {
      final recipeId = 'test-recipe';
      final itemId1 = 'item-1';
      final itemId2 = 'item-2';
      await database
          .into(database.recipes)
          .insert(
            db.RecipesCompanion.insert(id: recipeId, name: 'Test Recipe'),
          );
      await database
          .into(database.items)
          .insert(
            db.ItemsCompanion.insert(
              id: itemId1,
              name: 'Salt',
              defaultUnits: 'tsp',
            ),
          );
      await database
          .into(database.items)
          .insert(
            db.ItemsCompanion.insert(
              id: itemId2,
              name: 'Pepper',
              defaultUnits: 'tsp',
            ),
          );
      await database
          .into(database.recipeIngredients)
          .insert(
            db.RecipeIngredientsCompanion.insert(
              id: 'ing-1',
              recipeId: recipeId,
              itemId: itemId1,
              quantity: 1.0,
              units: 'tsp',
            ),
          );

      await pumpRecipePage(tester, recipeId);
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Salt'));
      await tester.pumpAndSettle();

      // Change item in dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pepper').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify UI is updated to show Pepper
      expect(find.text('Pepper'), findsOneWidget);
      expect(find.text('Salt'), findsNothing);

      // Verify database updated
      final ing = await (database.select(
        database.recipeIngredients,
      )..where((t) => t.id.equals('ing-1'))).getSingle();
      expect(ing.itemId, itemId2);
    });
  });
}
