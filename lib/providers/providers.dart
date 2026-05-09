import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart' as db;
import '../models/list_item.dart';
import '../notifiers/all_lists_notifier.dart';
import '../notifiers/shopping_list_notifier.dart';
import '../repositories/shopping_list_repository.dart';

final databaseProvider = Provider<db.AppDatabase>((ref) {
  final database = db.AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository(ref.watch(databaseProvider));
});

final activeShoppingListIdProvider = StateProvider<String>((ref) => '');

final shoppingListProvider =
AsyncNotifierProvider<ShoppingListNotifier, List<ListItem>>(
  ShoppingListNotifier.new,
);

final allListsProvider =
AsyncNotifierProvider<AllListsNotifier, List<db.ShoppingList>>(
  AllListsNotifier.new,
);