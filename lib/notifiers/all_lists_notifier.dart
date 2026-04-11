import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../providers/providers.dart';

class AllListsNotifier extends AsyncNotifier<List<ShoppingList>> {
  @override
  Future<List<ShoppingList>> build() async {
    return ref.read(databaseProvider).shoppingDao.getAllLists();
  }

  Future<void> createList(String name) async {
    final db = ref.read(databaseProvider);

    if ((state.value ?? []).any((list) => list.name == name)) {
      throw Exception('A list with this name already exists.');
    }

    state = const AsyncLoading<List<ShoppingList>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await db.shoppingDao.createList(name);
      return db.shoppingDao.getAllLists();
    });
  }
}