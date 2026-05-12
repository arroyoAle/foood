import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/pages/all_lists.dart';
import 'package:foood/providers/providers.dart';
import 'package:foood/pages/shopping_lists/shopping_list_screen.dart';

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpAllListsPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: MaterialApp(
          home: const AllListsPage(),
          routes: {
            '/list': (context) => const ShoppingListScreen(),
          },
        ),
      ),
    );
  }

  testWidgets('Shows empty state when no lists exist', (WidgetTester tester) async {
    await pumpAllListsPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('No lists found.'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Displays a list of shopping lists when data exists', (WidgetTester tester) async {
    await database.shoppingDao.createList('Groceries');
    await database.shoppingDao.createList('Weekend BBQ');

    await pumpAllListsPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Weekend BBQ'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
  });

  testWidgets('Tapping a list navigates to the list page', (WidgetTester tester) async {
    await database.shoppingDao.createList('Groceries');

    await pumpAllListsPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingListScreen), findsOneWidget);
    expect(find.text('Shopping List'), findsOneWidget); // AppBar title
  });

  testWidgets('Creating a new list updates the UI', (WidgetTester tester) async {
    await pumpAllListsPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Use a more specific finder for the dialog TextField if there are multiple TextFields
    final textField = find.ancestor(
      of: find.byType(TextField),
      matching: find.byType(AlertDialog),
    );
    await tester.enterText(textField, 'New List');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('New List'), findsOneWidget);
  });

  testWidgets('Searching lists filters the results', (WidgetTester tester) async {
    await database.shoppingDao.createList('Groceries');
    await database.shoppingDao.createList('Weekend BBQ');

    await pumpAllListsPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Weekend BBQ'), findsOneWidget);

    // Enter search text
    final searchField = find.ancestor(
      of: find.byType(TextField),
      matching: find.byType(Column), // The search field is in a Column, not the dialog
    );
    await tester.enterText(searchField, 'Groc');
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Weekend BBQ'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Weekend BBQ'), findsOneWidget);
  });
}
