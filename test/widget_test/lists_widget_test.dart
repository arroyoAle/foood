import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/pages/dialogs/item_dialog.dart';
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

  group('List Widget Tests', () {
    testWidgets('Shows empty state message when list is empty', (
      WidgetTester tester,
    ) async {
      final list = await database.shoppingDao.createList('Test List');

      await pumpShoppingListScreen(tester, list.id);
      await tester.pumpAndSettle();

      expect(find.text('No items yet'), findsOneWidget);
    });

    testWidgets(
      'Displays items in the list and category headings with counts',
      (WidgetTester tester) async {
        final list = await database.shoppingDao.createList('Test List');
        await repository.addManualItem(
          shoppingListId: list.id,
          name: 'Apples',
          quantity: 2.0,
          units: 'kg',
          category: 'Produce',
        );
        await repository.addManualItem(
          shoppingListId: list.id,
          name: 'Bananas',
          quantity: 1.0,
          units: 'bunch',
          category: 'Produce',
        );
        await repository.addManualItem(
          shoppingListId: list.id,
          name: 'Milk',
          quantity: 1.0,
          units: 'L',
          category: 'Dairy',
        );

        await pumpShoppingListScreen(tester, list.id);
        await tester.pumpAndSettle();

        expect(find.text('Apples'), findsOneWidget);
        expect(find.text('Bananas'), findsOneWidget);
        expect(find.text('Milk'), findsOneWidget);

        // Check category headings (counts should be hidden when expanded)
        expect(find.text('Produce'), findsOneWidget);
        expect(find.text('Dairy'), findsOneWidget);
        expect(find.text('Produce (2)'), findsNothing);
        expect(find.text('Dairy (1)'), findsNothing);

        // Check section headers
        expect(find.text('To Buy'), findsOneWidget);
        expect(find.text('In Cart'), findsOneWidget);
      },
    );

    testWidgets('Tapping checkbox moves item to In Cart section', (
      WidgetTester tester,
    ) async {
      final list = await database.shoppingDao.createList('Test List');
      await repository.addManualItem(
        shoppingListId: list.id,
        name: 'Apples',
        quantity: 2.0,
        units: 'kg',
        category: 'Produce',
      );

      await pumpShoppingListScreen(tester, list.id);
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(tester.widget<Checkbox>(checkbox).value, isFalse);

      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // After tapping, it should be selected
      expect(tester.widget<Checkbox>(checkbox).value, isTrue);

      // And Produce should still exist but under "In Cart" (count hidden when expanded)
      expect(find.text('Produce'), findsOneWidget);
      expect(find.text('Produce (1)'), findsNothing);
    });

    testWidgets('Floating toolbar contains jump buttons and reorder toggle', (
      WidgetTester tester,
    ) async {
      final list = await database.shoppingDao.createList('Test List');
      await pumpShoppingListScreen(tester, list.id);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.byIcon(Icons.swap_vert), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Reorder mode shows drag handle and hides checkboxes', (
      WidgetTester tester,
    ) async {
      final list = await database.shoppingDao.createList('Test List');
      await repository.addManualItem(
        shoppingListId: list.id,
        name: 'Apples',
        quantity: 2.0,
        units: 'kg',
        category: 'Produce',
      );

      await pumpShoppingListScreen(tester, list.id);
      await tester.pumpAndSettle();

      // Drag handle should NOT be present initially
      expect(find.byIcon(Icons.drag_handle), findsNothing);
      // Checkbox SHOULD be present initially
      expect(find.byType(Checkbox), findsOneWidget);

      // Toggle reorder mode
      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      // Drag handle SHOULD be present now
      expect(find.byIcon(Icons.drag_handle), findsOneWidget);
      // Checkbox SHOULD be hidden/disabled now
      final checkbox = tester.widget<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      expect(checkbox.enabled, isFalse);

      // Toggle back
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.drag_handle), findsNothing);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('Searching items filters the list', (
      WidgetTester tester,
    ) async {
      final list = await database.shoppingDao.createList('Test List');
      await repository.addManualItem(
        shoppingListId: list.id,
        name: 'Apples',
        quantity: 2.0,
        units: 'kg',
        category: 'Produce',
      );
      await repository.addManualItem(
        shoppingListId: list.id,
        name: 'Bananas',
        quantity: 1.0,
        units: 'bunch',
        category: 'Produce',
      );

      await pumpShoppingListScreen(tester, list.id);
      await tester.pumpAndSettle();

      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Bananas'), findsOneWidget);

      // Toggle search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Appl');
      await tester.pumpAndSettle();

      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Bananas'), findsNothing);

      // Close search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Bananas'), findsOneWidget);
    });
  });

  group('Grouped list', () {
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

      // Verify Categories are present (counts hidden when expanded)
      expect(find.text('Produce'), findsOneWidget);
      expect(find.text('Dairy'), findsOneWidget);
      expect(find.text('Produce (1)'), findsNothing);
      expect(find.text('Dairy (1)'), findsNothing);
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
        find.text('Produce'),
        findsOneWidget,
      ); // Category header appears once
      expect(find.text('Dairy'), findsOneWidget);
      expect(find.text('Produce (2)'), findsNothing);
      expect(find.text('Dairy (1)'), findsNothing);

      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('Bananas'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('Category count is only shown when collapsed', (
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

      await pumpShoppingListScreen(tester, list.id);
      await tester.pumpAndSettle();

      // Initially expanded: count hidden
      expect(find.text('Produce'), findsOneWidget);
      expect(find.text('Produce (2)'), findsNothing);

      // Tap to collapse
      await tester.tap(find.text('Produce'));
      await tester.pumpAndSettle();

      // Now collapsed: count shown
      expect(find.text('Produce (2)'), findsOneWidget);
      expect(find.text('Produce'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Produce (2)'));
      await tester.pumpAndSettle();

      // Expanded again: count hidden
      expect(find.text('Produce'), findsOneWidget);
      expect(find.text('Produce (2)'), findsNothing);
    });
  });

  group('Edit item dialog', () {
    testWidgets('Long pressing an item opens ItemDialog', (
      WidgetTester tester,
    ) async {
      final list = await database.shoppingDao.createList('Test List');
      await repository.addManualItem(
        shoppingListId: list.id,
        name: 'Apples',
        quantity: 2.0,
        units: 'kg',
      );

      await pumpShoppingListScreen(tester, list.id);
      await tester.pumpAndSettle();

      // Find the tile and long press it
      final tile = find.text('Apples');
      await tester.longPress(tile);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(ItemDialog), findsOneWidget);
      expect(find.text('Edit Item'), findsOneWidget);

      // Verify initial values in dialog
      expect(find.widgetWithText(TextField, 'Apples'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2.0'), findsOneWidget);
      expect(find.text('kg'), findsAtLeastNWidgets(1));
    });

    testWidgets('Saving changes in ItemDialog updates the list', (
      WidgetTester tester,
    ) async {
      final list = await database.shoppingDao.createList('Test List');
      await repository.addManualItem(
        shoppingListId: list.id,
        name: 'Apples',
        quantity: 2.0,
        units: 'kg',
      );

      await pumpShoppingListScreen(tester, list.id);
      await tester.pumpAndSettle();

      // Open dialog
      await tester.longPress(find.text('Apples'));
      await tester.pumpAndSettle();

      // Edit name
      final nameField = find.widgetWithText(TextField, 'Apples');
      await tester.enterText(nameField, 'Green Apples');

      // Edit quantity
      final quantityField = find.widgetWithText(TextField, '2.0');
      await tester.enterText(quantityField, '5.0');

      // Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(ItemDialog), findsNothing);

      // Verify list is updated
      expect(find.text('Green Apples'), findsOneWidget);
      expect(find.text('5.0 kg'), findsOneWidget);
    });
  });
}
