import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/pages/shopping_lists/shopping_list_screen.dart';
import 'package:foood/providers/providers.dart';
import 'package:foood/repositories/shopping_list_repository.dart';

void main() {
  late db.AppDatabase database;
  late ShoppingRepository repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = ShoppingRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpShoppingListScreen(
    WidgetTester tester,
    String listId,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          activeShoppingListIdProvider.overrideWith((ref) => listId),
        ],
        child: const MaterialApp(home: ShoppingListScreen()),
      ),
    );
  }

  testWidgets('Headers are not present if the list is completely empty', (
    WidgetTester tester,
  ) async {
    final list = await database.shoppingDao.createList('Test List');

    await pumpShoppingListScreen(tester, list.id);
    await tester.pumpAndSettle();

    // Verify "No items yet" message is shown
    expect(find.text('No items yet'), findsOneWidget);

    // Verify Section Headers are NOT present
    expect(find.text('To Buy'), findsNothing);
    expect(find.text('In Cart'), findsNothing);
  });

  testWidgets('Displays "To Buy" and "In Cart" sections correctly', (
    WidgetTester tester,
  ) async {
    final list = await database.shoppingDao.createList('Test List');

    // Add an unselected item
    await repository.addManualItem(
      shoppingListId: list.id,
      name: 'Apples',
      quantity: 1.0,
      units: 'kg',
      category: 'Produce',
    );

    // Add a selected item
    final milk = await repository.addManualItem(
      shoppingListId: list.id,
      name: 'Milk',
      quantity: 1.0,
      units: 'L',
      category: 'Dairy',
    );
    await repository.updateSelected(milk.id, true);

    await pumpShoppingListScreen(tester, list.id);
    await tester.pumpAndSettle();

    // Verify Section Headers
    expect(find.text('To Buy'), findsOneWidget);
    expect(find.text('In Cart'), findsOneWidget);

    // Verify Items are present
    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);

    // Verify Categories are present
    expect(find.text('Produce (1)'), findsOneWidget);
    expect(find.text('Dairy (1)'), findsOneWidget);
  });

  testWidgets('Moving item from "To Buy" to "In Cart" when selected', (
    WidgetTester tester,
  ) async {
    final list = await database.shoppingDao.createList('Test List');
    await repository.addManualItem(
      shoppingListId: list.id,
      name: 'Apples',
      quantity: 1.0,
      units: 'kg',
      category: 'Produce',
    );

    await pumpShoppingListScreen(tester, list.id);
    await tester.pumpAndSettle();

    // Initially "In Cart" should not exist as no items are selected
    // Note: In current implementation, header might still exist if list is empty or logic filters.
    // Looking at grouped_list.dart:
    // if (unselectedItems.isNotEmpty) ...[ _buildSectionHeader(context, 'To Buy'), ... ]
    // if (selectedItems.isNotEmpty) ...[ _buildSectionHeader(context, 'In Cart'), ... ]

    // Initially "In Cart" and "To Buy" should both exist
    expect(find.text('To Buy'), findsOneWidget);
    expect(find.text('In Cart'), findsOneWidget);

    // Apples is in "To Buy", so "In Cart" should show empty message
    expect(find.text('No items in cart'), findsOneWidget);
    expect(find.text('No items to buy'), findsNothing);

    // Tap checkbox for Apples
    final checkbox = find.byType(Checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Both headers should still exist
    expect(find.text('In Cart'), findsOneWidget);
    expect(find.text('To Buy'), findsOneWidget);

    // Apples moved to "In Cart", so "To Buy" should show empty message
    expect(find.text('No items to buy'), findsOneWidget);
    expect(find.text('No items in cart'), findsNothing);
  });

  testWidgets('Items are grouped by category within sections', (
    WidgetTester tester,
  ) async {
    final list = await database.shoppingDao.createList('Test List');

    await repository.addManualItem(
      shoppingListId: list.id,
      name: 'Apples',
      category: 'Produce',
      quantity: 1.0,
      units: 'kg',
    );
    await repository.addManualItem(
      shoppingListId: list.id,
      name: 'Bananas',
      category: 'Produce',
      quantity: 1.0,
      units: 'kg',
    );
    await repository.addManualItem(
      shoppingListId: list.id,
      name: 'Milk',
      category: 'Dairy',
      quantity: 1.0,
      units: 'L',
    );

    await pumpShoppingListScreen(tester, list.id);
    await tester.pumpAndSettle();

    expect(
      find.text('Produce (2)'),
      findsOneWidget,
    ); // Category header appears once
    expect(find.text('Dairy (1)'), findsOneWidget);

    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('Bananas'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
  });
}
