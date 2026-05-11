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

  testWidgets('Displays items in the list and category headings with counts', (WidgetTester tester) async {
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

    // Check category headings with counts
    expect(find.text('Produce (2)'), findsOneWidget);
    expect(find.text('Dairy (1)'), findsOneWidget);
    
    // Check section headers
    expect(find.text('To Buy'), findsOneWidget);
    expect(find.text('In Cart'), findsOneWidget);
  });

  testWidgets('Tapping checkbox moves item to In Cart section', (WidgetTester tester) async {
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
    
    // And Produce (1) should still exist but under "In Cart"
    expect(find.text('Produce (1)'), findsOneWidget);
  });

  testWidgets('Floating toolbar contains jump buttons and reorder toggle', (WidgetTester tester) async {
    final list = await database.shoppingDao.createList('Test List');
    await pumpShoppingListScreen(tester, list.id);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    expect(find.byIcon(Icons.swap_vert), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Reorder mode shows movement arrows', (WidgetTester tester) async {
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

    // Movement arrows should NOT be present initially
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);

    // Toggle reorder mode
    await tester.tap(find.byIcon(Icons.swap_vert));
    await tester.pumpAndSettle();

    // Movement arrows SHOULD be present now
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    
    // Toggle back
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
  });
}
