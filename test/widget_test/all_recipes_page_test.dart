import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/pages/all_recipes.dart';
import 'package:foood/providers/providers.dart';

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpAllRecipesPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(
          home: AllRecipesPage(),
        ),
      ),
    );
  }

  testWidgets('Shows list of recipes and navigates to creation', (
    WidgetTester tester,
  ) async {
    await database.into(database.recipes).insert(
          db.RecipesCompanion.insert(id: 'r1', name: 'Amatriciana'),
        );

    await pumpAllRecipesPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('Amatriciana'), findsOneWidget);

    // Tap FAB to add new recipe
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Recipe'), findsOneWidget);
    
    // Enter name and create
    await tester.enterText(find.byType(TextField), 'Pizza');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Pizza'), findsOneWidget);
  });
}
