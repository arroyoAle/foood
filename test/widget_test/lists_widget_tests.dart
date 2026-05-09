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

  Future<void> pumpShoppingListScreen(WidgetTester tester, String listId) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          activeShoppingListIdProvider.overrideWith((ref) => listId),
        ],
        child: const MaterialApp(
          home: ShoppingListScreen(),
        ),
      ),
    );
  }

  testWidgets('Shows empty state message when list is empty', (WidgetTester tester) async {
    final list = await database.shoppingDao.createList('Test List');
    
    await pumpShoppingListScreen(tester, list.id);
    await tester.pumpAndSettle();

    expect(find.text('No items yet'), findsOneWidget);
  });

  testWidgets('Displays items in the list', (WidgetTester tester) async {
    final list = await database.shoppingDao.createList('Test List');
    await repository.addManualItem(
      shoppingListId: list.id,
      name: 'Apples',
      quantity: 2.0,
      units: 'kg',
    );

    await pumpShoppingListScreen(tester, list.id);
    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('2.0 kg'), findsOneWidget);
  });

  testWidgets('Tapping checkbox updates selection', (WidgetTester tester) async {
    final list = await database.shoppingDao.createList('Test List');
    await repository.addManualItem(
      shoppingListId: list.id,
      name: 'Apples',
      quantity: 2.0,
      units: 'kg',
    );

    await pumpShoppingListScreen(tester, list.id);
    await tester.pumpAndSettle();

    final checkbox = find.byType(Checkbox);
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);

    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
  });
}
