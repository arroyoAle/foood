import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/pages/shopping_lists/dialogs/item_dialog.dart';
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
}
