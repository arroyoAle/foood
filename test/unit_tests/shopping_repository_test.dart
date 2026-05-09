import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
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

  group('ShoppingRepository', () {
    test('findOrCreateItem creates a new item if it does not exist', () async {
      const name = 'Apples';
      const units = 'kg';
      
      final item = await repository.findOrCreateItem(name: name, units: units);
      
      expect(item.name, name);
      expect(item.defaultUnits, units);
      
      final itemsInDb = await database.select(database.items).get();
      expect(itemsInDb.length, 1);
      expect(itemsInDb.first.name, name);
    });

    test('findOrCreateItem returns existing item if it exists', () async {
      const name = 'Apples';
      await repository.findOrCreateItem(name: name, units: 'kg');
      
      final item = await repository.findOrCreateItem(name: name, units: 'lbs');
      
      expect(item.name, name);
      expect(item.defaultUnits, 'kg'); // Should not change units of existing item
      
      final itemsInDb = await database.select(database.items).get();
      expect(itemsInDb.length, 1);
    });

    test('addManualItem adds item to shopping list', () async {
      final list = await database.shoppingDao.createList('Test List');
      
      final listItem = await repository.addManualItem(
        shoppingListId: list.id,
        name: 'Milk',
        quantity: 2.0,
        units: 'L',
      );
      
      expect(listItem.item.name, 'Milk');
      expect(listItem.quantityRequired, 2.0);
      
      final itemsInList = await repository.getList(list.id);
      expect(itemsInList.length, 1);
      expect(itemsInList.first.id, listItem.id);
    });

    test('updateSelected updates item selection status', () async {
      final list = await database.shoppingDao.createList('Test List');
      final listItem = await repository.addManualItem(
        shoppingListId: list.id,
        name: 'Milk',
        quantity: 2.0,
        units: 'L',
      );
      
      await repository.updateSelected(listItem.id, true);
      
      final itemsInList = await repository.getList(list.id);
      expect(itemsInList.first.selected, isTrue);
    });
  });
}
