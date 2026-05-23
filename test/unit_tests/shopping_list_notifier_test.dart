import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/providers/providers.dart';
import 'package:drift/native.dart';
import 'package:foood/repositories/shopping_list_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late ProviderContainer container;
  late db.AppDatabase database;
  late ShoppingRepository shoppingRepository;

  setUp(() async {
    database = db.AppDatabase(NativeDatabase.memory());
    shoppingRepository = ShoppingRepository(database);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        shoppingRepositoryProvider.overrideWithValue(shoppingRepository),
        activeShoppingListIdProvider.overrideWith((ref) => 'test-list-1'),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ShoppingListNotifier', () {
    test('addManualItem adds item and refreshes state', () async {
      final list = await database.shoppingDao.createList('Test List');
      container.read(activeShoppingListIdProvider.notifier).state = list.id;

      await container
          .read(shoppingListProvider.notifier)
          .addManualItem(
            name: 'Milk',
            quantity: 2.0,
            units: 'L',
            category: 'Dairy',
          );

      final items = await container.read(shoppingListProvider.future);
      expect(items.any((i) => i.item.name == 'Milk'), isTrue);
      expect(
        items.firstWhere((i) => i.item.name == 'Milk').quantityRequired,
        2.0,
      );
    });

    test('toggleSelected updates item selected status', () async {
      final list = await database.shoppingDao.createList('Test List');
      container.read(activeShoppingListIdProvider.notifier).state = list.id;

      await container
          .read(shoppingListProvider.notifier)
          .addManualItem(name: 'Milk', quantity: 2.0, units: 'L');

      var items = await container.read(shoppingListProvider.future);
      final item = items.first;
      expect(item.selected, isFalse);

      await container.read(shoppingListProvider.notifier).toggleSelected(item);

      items = await container.read(shoppingListProvider.future);
      expect(items.first.selected, isTrue);
    });

    group('Undo/Redo', () {
      test(
        'toggleSelected adds to undo stack and enables Undo button',
        () async {
          final list = await database.shoppingDao.createList('Test List');
          container.read(activeShoppingListIdProvider.notifier).state = list.id;

          await container
              .read(shoppingListProvider.notifier)
              .addManualItem(name: 'Milk', quantity: 1.0, units: 'L');

          var items = await container.read(shoppingListProvider.future);
          var item = items.first;

          expect(container.read(shoppingListUndoProvider), isFalse);

          await container
              .read(shoppingListProvider.notifier)
              .toggleSelected(item);

          expect(container.read(shoppingListUndoProvider), isTrue);
          expect(container.read(shoppingListRedoProvider), isFalse);

          items = await container.read(shoppingListProvider.future);
          expect(items.first.selected, isTrue);
        },
      );

      test('undoLastToggle reverts toggle and enables Redo button', () async {
        final list = await database.shoppingDao.createList('Test List');
        container.read(activeShoppingListIdProvider.notifier).state = list.id;

        await container
            .read(shoppingListProvider.notifier)
            .addManualItem(name: 'Milk', quantity: 1.0, units: 'L');

        var items = await container.read(shoppingListProvider.future);
        var item = items.first;

        await container
            .read(shoppingListProvider.notifier)
            .toggleSelected(item);
        expect(container.read(shoppingListUndoProvider), isTrue);

        await container.read(shoppingListProvider.notifier).undoLastToggle();

        expect(container.read(shoppingListUndoProvider), isFalse);
        expect(container.read(shoppingListRedoProvider), isTrue);

        items = await container.read(shoppingListProvider.future);
        expect(items.first.selected, isFalse);
      });

      test('redoLastToggle re-applies toggle', () async {
        final list = await database.shoppingDao.createList('Test List');
        container.read(activeShoppingListIdProvider.notifier).state = list.id;

        await container
            .read(shoppingListProvider.notifier)
            .addManualItem(name: 'Milk', quantity: 1.0, units: 'L');

        var items = await container.read(shoppingListProvider.future);
        var item = items.first;

        await container
            .read(shoppingListProvider.notifier)
            .toggleSelected(item);
        await container.read(shoppingListProvider.notifier).undoLastToggle();

        expect(container.read(shoppingListRedoProvider), isTrue);

        await container.read(shoppingListProvider.notifier).redoLastToggle();

        expect(container.read(shoppingListUndoProvider), isTrue);
        expect(container.read(shoppingListRedoProvider), isFalse);

        items = await container.read(shoppingListProvider.future);
        expect(items.first.selected, isTrue);
      });

      test('new toggle clears redo stack', () async {
        final list = await database.shoppingDao.createList('Test List');
        container.read(activeShoppingListIdProvider.notifier).state = list.id;

        await container
            .read(shoppingListProvider.notifier)
            .addManualItem(name: 'Milk', quantity: 1.0, units: 'L');
        await container
            .read(shoppingListProvider.notifier)
            .addManualItem(name: 'Bread', quantity: 1.0, units: 'loaf');

        var items = await container.read(shoppingListProvider.future);
        var milk = items.firstWhere((i) => i.item.name == 'Milk');
        var bread = items.firstWhere((i) => i.item.name == 'Bread');

        await container
            .read(shoppingListProvider.notifier)
            .toggleSelected(milk);
        await container.read(shoppingListProvider.notifier).undoLastToggle();
        expect(container.read(shoppingListRedoProvider), isTrue);

        await container
            .read(shoppingListProvider.notifier)
            .toggleSelected(bread);
        expect(container.read(shoppingListRedoProvider), isFalse);
        expect(container.read(shoppingListUndoProvider), isTrue);
      });

      test('switching list ID clears both stacks', () async {
        final list1 = await database.shoppingDao.createList('List 1');
        final list2 = await database.shoppingDao.createList('List 2');

        container.read(activeShoppingListIdProvider.notifier).state = list1.id;
        await container
            .read(shoppingListProvider.notifier)
            .addManualItem(name: 'Milk', quantity: 1.0, units: 'L');

        var items = await container.read(shoppingListProvider.future);
        await container
            .read(shoppingListProvider.notifier)
            .toggleSelected(items.first);

        expect(container.read(shoppingListUndoProvider), isTrue);

        // Switch to list 2
        container.read(activeShoppingListIdProvider.notifier).state = list2.id;

        // Wait for build to complete and stack providers to update
        await container.read(shoppingListProvider.future);
        await pumpEventQueue();

        expect(container.read(shoppingListUndoProvider), isFalse);
        expect(container.read(shoppingListRedoProvider), isFalse);
      });

      group('Multiple toggles and undos', () {
        test('Multiple toggles and undos works sequentially', () async {
          final list = await database.shoppingDao.createList('Test List');
          container.read(activeShoppingListIdProvider.notifier).state = list.id;

          await container
              .read(shoppingListProvider.notifier)
              .addManualItem(name: 'A', quantity: 1, units: 'u');
          await container
              .read(shoppingListProvider.notifier)
              .addManualItem(name: 'B', quantity: 1, units: 'u');

          var items = await container.read(shoppingListProvider.future);
          var a = items.firstWhere((i) => i.item.name == 'A');
          var b = items.firstWhere((i) => i.item.name == 'B');

          await container.read(shoppingListProvider.notifier).toggleSelected(a);
          await container.read(shoppingListProvider.notifier).toggleSelected(b);

          expect(container.read(shoppingListUndoProvider), isTrue);

          await container
              .read(shoppingListProvider.notifier)
              .undoLastToggle(); // Undoes B
          items = await container.read(shoppingListProvider.future);
          expect(items.firstWhere((i) => i.item.name == 'A').selected, isTrue);
          expect(items.firstWhere((i) => i.item.name == 'B').selected, isFalse);

          await container
              .read(shoppingListProvider.notifier)
              .undoLastToggle(); // Undoes A
          items = await container.read(shoppingListProvider.future);
          expect(items.firstWhere((i) => i.item.name == 'A').selected, isFalse);
          expect(items.firstWhere((i) => i.item.name == 'B').selected, isFalse);

          expect(container.read(shoppingListUndoProvider), isFalse);
          expect(container.read(shoppingListRedoProvider), isTrue);
        });
      });
    });
  });
}
