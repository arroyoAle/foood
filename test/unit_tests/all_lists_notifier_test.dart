import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/providers/providers.dart';
import 'package:drift/native.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late ProviderContainer container;
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AllListsNotifier', () {
    test('createList adds a new shopping list', () async {
      await container.read(allListsProvider.notifier).createList('Groceries');

      final lists = await container.read(allListsProvider.future);
      expect(lists.any((l) => l.name == 'Groceries'), isTrue);
    });

    test('createList throws exception if name already exists', () async {
      await container.read(allListsProvider.notifier).createList('Groceries');

      expect(
        () => container.read(allListsProvider.notifier).createList('Groceries'),
        throwsException,
      );
    });
  });
}
