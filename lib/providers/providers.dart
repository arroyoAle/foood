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

final isReorderModeProvider = StateProvider<bool>((ref) => false);

final allListsProvider =
AsyncNotifierProvider<AllListsNotifier, List<db.ShoppingList>>(
  AllListsNotifier.new,
);

final listSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAllListsProvider = Provider<AsyncValue<List<db.ShoppingList>>>((ref) {
  final allListsAsync = ref.watch(allListsProvider);
  final query = ref.watch(listSearchQueryProvider).toLowerCase();

  return allListsAsync.whenData((lists) {
    if (query.isEmpty) return lists;
    return lists.where((list) => list.name.toLowerCase().contains(query)).toList();
  });
});

// Item providers
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(ref.watch(databaseProvider));
});

final itemsProvider = AsyncNotifierProvider<ItemNotifier, List<Item>>(
  ItemNotifier.new,
);

final itemSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredShoppingListProvider = Provider<AsyncValue<List<ListItem>>>((ref) {
  final listAsync = ref.watch(shoppingListProvider);
  final query = ref.watch(itemSearchQueryProvider).toLowerCase();

  return listAsync.whenData((items) {
    if (query.isEmpty) return items;
    return items.where((item) => item.item.name.toLowerCase().contains(query)).toList();
  });
});

// Recipe providers
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.watch(databaseProvider));
});

final activeRecipeIdProvider = StateProvider<String>((ref) => '');

final recipesProvider = AsyncNotifierProvider<RecipeNotifier, List<Recipe>>(
  RecipeNotifier.new,
);

final selectedRecipeProvider = Provider<AsyncValue<Recipe?>>((ref) {
  final recipesAsync = ref.watch(recipesProvider);
  final activeId = ref.watch(activeRecipeIdProvider);

  return recipesAsync.whenData((recipes) {
    if (activeId.isEmpty) return null;
    try {
      return recipes.firstWhere((r) => r.id == activeId);
    } catch (_) {
      return null;
    }
  });
});
