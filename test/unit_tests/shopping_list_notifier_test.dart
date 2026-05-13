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

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    shoppingRepository = ShoppingRepository(database);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        shoppingRepositoryProvider.overrideWithValue(shoppingRepository),
        activeShoppingListIdProvider.overrideWith((ref) => 'test-list'),
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
  });
}
