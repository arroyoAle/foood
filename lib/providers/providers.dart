import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart' as db;
import '../models/list_item.dart';
import '../models/item.dart';
import '../models/recipe.dart';
import '../notifiers/all_lists_notifier.dart';
import '../notifiers/shopping_list_notifier.dart';
import '../notifiers/item_notifier.dart';
import '../notifiers/recipe_notifier.dart';
import '../repositories/shopping_list_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/recipe_repository.dart';

final databaseProvider = Provider<db.AppDatabase>((ref) {
  final database = db.AppDatabase();
  ref.onDispose(database.close);
  return database;
});

// Shopping list providers
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

// Item providers
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(ref.watch(databaseProvider));
});

final itemsProvider = AsyncNotifierProvider<ItemNotifier, List<Item>>(
  ItemNotifier.new,
);

// Recipe providers
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.watch(databaseProvider));
});

final activeRecipeProvider = StateProvider<Recipe?>((ref) => null);

final recipesProvider = AsyncNotifierProvider<RecipeNotifier, List<Recipe>>(
  RecipeNotifier.new,
);
