import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/models/shopping_list.dart';
import 'package:foood/pages/all_lists.dart';
import 'package:foood/pages/list.dart';
import 'package:mockito/mockito.dart';

import 'lists_widget_tests.mocks.dart';


void main() {
  late MockShoppingListManager mockManager;

  setUp(() {
    mockManager = MockShoppingListManager();
  });

  Future<void> pumpAllListsPage(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AllListsPage(manager: mockManager),
      routes: {
        '/list': (context) => ListPage(manager: mockManager),
      },
    ));
  }

  final testLists = [
    ShoppingList(id: '1', name: 'Groceries', items: []),
    ShoppingList(id: '2', name: 'Weekend BBQ', items: []),
  ];

  testWidgets('Shows CircularProgressIndicator while loading lists', (WidgetTester tester) async {
    when(mockManager.loadAllLists()).thenAnswer((_) async => Future.value());
    when(mockManager.allLists).thenReturn([]);

    await pumpAllListsPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Shows a message or empty state when no lists are loaded', (WidgetTester tester) async {
    when(mockManager.loadAllLists()).thenAnswer((_) async {});
    when(mockManager.allLists).thenReturn([]);

    await pumpAllListsPage(tester);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Displays a list of shopping lists when data is loaded', (WidgetTester tester) async {
    when(mockManager.loadAllLists()).thenAnswer((_) async {});
    when(mockManager.allLists).thenReturn(testLists);

    await pumpAllListsPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Weekend BBQ'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Tapping a list navigates to the list page', (WidgetTester tester) async {
    when(mockManager.loadAllLists()).thenAnswer((_) async {});
    when(mockManager.allLists).thenReturn(testLists);
    when(mockManager.setActiveList(any)).thenReturn(null);
    when(mockManager.activeList).thenReturn(testLists.first);

    await pumpAllListsPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    verify(mockManager.setActiveList(testLists.first)).called(1);
    expect(find.byType(AllListsPage), findsNothing);
    expect(find.byType(ListPage), findsOneWidget);
  });
}