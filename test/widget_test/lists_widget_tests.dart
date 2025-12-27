import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/helpers/shopping_list_manager.dart';
import 'package:foood/models/item.dart';
import 'package:foood/models/shopping_list.dart';
import 'package:foood/pages/list.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'lists_widget_tests.mocks.dart';

@GenerateMocks([ShoppingListManager])
void main() {
  late MockShoppingListManager mockManager;

  setUp(() {
    mockManager = MockShoppingListManager();
  });

  Future<void> pumpListsHomePage(WidgetTester tester, ShoppingListManager manager) async {
    await tester.pumpWidget(MaterialApp(
      home: ListPage(manager: manager),
    ));
  }

  testWidgets('Shows an empty list', (WidgetTester tester) async {
    when(mockManager.activeList).thenReturn(ShoppingList(id: Uuid().v4(),name: 'test', items: []));

    await pumpListsHomePage(tester, mockManager);
    await tester.pumpAndSettle();
    expect(find.text("No items in this list. \n\nAdd a new item with the '+' button below."), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Displays a list of items after loading', (WidgetTester tester) async {
    final testItems = [
      Item(id: Uuid().v4(), name: 'Apples', units: 'kg', quantity: 2, selected: false, ordering: 1),
      Item(id: Uuid().v4(), name: 'Milk', units: 'l', quantity: 1, selected: true, ordering: 2),
    ];
    final testList = ShoppingList(id: Uuid().v4(), name: 'my_shopping_list', items: testItems);

    when(mockManager.activeList).thenReturn(testList);

    await pumpListsHomePage(tester, mockManager);
    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('2 kg'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(2));
  });

  testWidgets('Tapping a checkbox calls saveList and updates UI', (WidgetTester tester) async {
    final testItems = [Item(id: Uuid().v4(), name: 'Bread', units: 'count', quantity: 1, selected: false, ordering: 1)];
    final testList = ShoppingList(id: Uuid().v4(), name: 'my_shopping_list', items: testItems);

    when(mockManager.activeList).thenReturn(testList);
    when(mockManager.saveActiveList()).thenAnswer((_) async => Future.value());

    await pumpListsHomePage(tester, mockManager);
    await tester.pumpAndSettle();

    expect(find.text('Bread'), findsOneWidget);
    final checkbox = find.byType(Checkbox);
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);

    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    verify(mockManager.saveActiveList()).called(1);
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
  });

  testWidgets("Tapping '+' opens the popup to add a new item", (WidgetTester tester) async {
    final testList = ShoppingList(id: Uuid().v4(), name: 'my_shopping_list', items: []);

    when(mockManager.activeList).thenReturn(testList);

    await pumpListsHomePage(tester, mockManager);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });

  testWidgets("Tapping cancel closes the popup and does not add an item", (WidgetTester tester) async {
    final testList = ShoppingList(id: Uuid().v4(), name: 'my_shopping_list', items: []);

    when(mockManager.activeList).thenReturn(testList);

    await pumpListsHomePage(tester, mockManager);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Apples'), findsNothing);
  });

  testWidgets("Tapping add closes the popup and adds an item", (WidgetTester tester) async {
    final newItem = Item(id: Uuid().v4(), name: 'Bread', units: 'count', quantity: 1, selected: false, ordering: 1);
    final initialList = ShoppingList(id: Uuid().v4(), name: 'my_shopping_list', items: []);
    final updatedList = ShoppingList(id: initialList.id, name: initialList.name, items: [newItem]);

    when(mockManager.activeList).thenReturn(initialList);
    when(mockManager.addNewItemToActiveList(name: newItem.name, units: newItem.units, quantity: newItem.quantity)).thenAnswer((_) async => Future.value());
    when(mockManager.activeList).thenReturn(updatedList);

    await pumpListsHomePage(tester, mockManager);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, newItem.name);
    await tester.enterText(find.byType(TextField).last, newItem.quantity.toString());
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(newItem.units));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.text(newItem.name), findsOneWidget);
    expect(find.text('${newItem.quantity} ${newItem.units}'), findsOneWidget);
    verify(mockManager.addNewItemToActiveList(name: newItem.name, units: newItem.units, quantity: newItem.quantity)).called(1);
  });

  testWidgets("Tapping add displays errors when fields are empty", (WidgetTester tester) async {
    final testList = ShoppingList(id: Uuid().v4(), name: 'my_shopping_list', items: []);

    when(mockManager.activeList).thenReturn(testList);

    await pumpListsHomePage(tester, mockManager);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter some text'), findsOneWidget, reason: "Name field should have a validation error.");
    expect(find.text('Enter a quantity'), findsOneWidget, reason: "Quantity field should have a validation error.");
    expect(find.text('Select an option'), findsOneWidget, reason: "Units dropdown should have a validation error.");

    verifyNever(mockManager.addNewItemToActiveList(name: anyNamed('name'), units: anyNamed('units'), quantity: anyNamed('quantity')));

    expect(find.byType(Dialog), findsOneWidget);
  });
}

