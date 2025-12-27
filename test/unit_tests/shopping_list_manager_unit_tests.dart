import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:foood/helpers/shopping_list_manager.dart';
import 'package:foood/helpers/storage.dart';
import 'package:foood/models/item.dart';
import 'package:foood/models/shopping_list.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'shopping_list_manager_tests.mocks.dart';

@GenerateMocks([Storage, File])
void main() {
  late ShoppingListManager manager;
  late MockStorage mockStorage;
  late MockFile mockFile;

  setUp(() {
    mockStorage = MockStorage();
    mockFile = MockFile();
    manager = ShoppingListManager(storage: mockStorage);
  });

  group('ShoppingListManager', () {
    const listIndexFileName = 'shopping_lists';
    final shoppingList1 = ShoppingList(id: '1', name: 'Groceries', items: []);
    final shoppingList2 = ShoppingList(id: '2', name: 'Hardware Store', items: []);

    test('loadAllLists loads and parses multiple lists successfully', () async {
      when(mockStorage.read(listIndexFileName)).thenAnswer(
            (_) async => {'id-1': shoppingList1.name, 'id-2': shoppingList2.name},
      );
      when(mockStorage.read(shoppingList1.name)).thenAnswer(
            (_) async => shoppingList1.toJson(),
      );
      when(mockStorage.read(shoppingList2.name)).thenAnswer(
            (_) async => shoppingList2.toJson(),
      );

      await manager.loadAllLists();

      expect(manager.allLists.length, 2);
      expect(manager.allLists.first.name, 'Groceries');
      expect(manager.allLists.last.name, 'Hardware Store');
    });

    test('createNewList adds a new list and updates the index file', () async {
      when(mockStorage.read(listIndexFileName)).thenAnswer((_) async => {});

      when(mockStorage.write(any, any)).thenAnswer((_) async => mockFile);

      await manager.createNewList('New Test List');

      expect(manager.allLists.length, 1);
      expect(manager.allLists.first.name, 'New Test List');

      verify(mockStorage.write('New Test List', any)).called(1);

      verify(mockStorage.write(listIndexFileName, any)).called(1);
    });

    test('addNewItemToActiveList adds an item and saves the active list', () async {
      manager.setActiveList(shoppingList1);

      when(mockStorage.write(any, any)).thenAnswer((_) async => mockFile);

      await manager.addNewItemToActiveList(
        name: 'Apples',
        units: 'kg',
        quantity: 5,
      );

      expect(manager.activeList!.items.length, 1);
      expect(manager.activeList!.items.first.name, 'Apples');

      verify(mockStorage.write(shoppingList1.name, manager.activeList!.toJson())).called(1);
    });

    test('saveActiveList should call storage.write with correct data', () async {
      final item = Item(id: 'i1', name: 'Milk', units: 'l', quantity: 1, selected: true, ordering: 1);
      final listWithItem = ShoppingList(id: '1', name: 'Groceries', items: [item]);
      manager.setActiveList(listWithItem);

      when(mockStorage.write(any, any)).thenAnswer((_) async => mockFile);

      await manager.saveActiveList();

      verify(mockStorage.write(listWithItem.name, listWithItem.toJson())).called(1);
    });

    test('create list that clashes with name', () async {
      manager.allLists.add(shoppingList1);
      when(mockStorage.read(listIndexFileName)).thenAnswer((_) async => {'1': shoppingList1.name});

      expect(() => manager.createNewList('Groceries'), throwsA(isA<Exception>()));

      expect(manager.allLists.length, 1);
      expect(manager.allLists.first.name, 'Groceries');
      verifyNever(mockStorage.write(listIndexFileName, any));
      expect(manager.allLists.length, 1);
    });
  });
}