import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/helpers/shopping_list_manager.dart';
import 'package:foood/models/item.dart';
import 'package:foood/models/shopping_list.dart';
import 'package:foood/pages/lists.dart';
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
      home: ListsHomePage(manager: manager),
    ));
  }

  testWidgets('Shows loading indicator and then an empty list', (WidgetTester tester) async {
    when(mockManager.loadList(any)).thenAnswer((_) async => Future.value());
    when(mockManager.shoppingList).thenReturn(ShoppingList(id: Uuid().v4(),name: 'test', items: []));

    await pumpListsHomePage(tester, mockManager);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Displays a list of items after loading', (WidgetTester tester) async {
    final testItems = [
      Item(id: Uuid().v4(), name: 'Apples', units: 'kg', quantity: 2, selected: false),
      Item(id: Uuid().v4(), name: 'Milk', units: 'l', quantity: 1, selected: true),
    ];
    final testList = ShoppingList(id: Uuid().v4(), name: 'my_shopping_list', items: testItems);

    when(mockManager.loadList(testList.name)).thenAnswer((_) async => Future.value());
    when(mockManager.shoppingList).thenReturn(testList);

    await pumpListsHomePage(tester, mockManager);
    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('2 kg'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(2));
  });

  testWidgets('Tapping a checkbox calls saveList and updates UI', (WidgetTester tester) async {
    final testItems = [Item(id: Uuid().v4(), name: 'Bread', units: 'count', quantity: 1, selected: false)];
    final testList = ShoppingList(id: Uuid().v4(), name: 'my_shopping_list', items: testItems);

    when(mockManager.loadList(any)).thenAnswer((_) async => Future.value());
    when(mockManager.shoppingList).thenReturn(testList);
    when(mockManager.saveList()).thenAnswer((_) async => Future.value());

    await pumpListsHomePage(tester, mockManager);
    await tester.pumpAndSettle();

    expect(find.text('Bread'), findsOneWidget);
    final checkbox = find.byType(Checkbox);
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);

    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    verify(mockManager.saveList()).called(1);
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
  });
// test cancel closes the popup
// test adding a new item
// test empty fields errors when adding a new item
}

