import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/pages/recipe.dart';
import 'package:foood/pages/shopping_lists/shopping_list_screen.dart';
import 'package:foood/partials/drawer.dart';
import 'package:foood/partials/top_bar.dart';
import 'package:foood/partials/dashboard_card.dart';
import '../data/database.dart' as db;
import '../models/recipe.dart';
import '../providers/providers.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  final String title = 'Foood Home Page';

  void _openList(BuildContext context, WidgetRef ref, db.ShoppingList list) {
    ref.read(activeShoppingListIdProvider.notifier).state = list.id;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ShoppingListScreen(),
      ),
    );
  }

  void _openRecipe(BuildContext context, WidgetRef ref, Recipe recipe) {
    ref.read(activeRecipeIdProvider.notifier).state = recipe.id;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecipePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(allListsProvider);
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: TopBarPartial(title: title),
      drawer: DrawerPartial(currentPage: 'home_page'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            DashboardCard(
              title: "Next Meal",
              icon: Icons.restaurant,
              child: const Center(
                child: Text(
                  "Test meal 1",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              onTap: () => Navigator.of(context).pushNamed('/recipes'),
            ),
            DashboardCard(
              title: "Quick Access",
              icon: Icons.shopping_cart,
              onTap: () => Navigator.of(context).pushNamed('/lists'),
              child: listsAsync.when(
                data: (lists) => lists.isEmpty
                    ? const Center(child: Text("No lists", style: TextStyle(fontSize: 12)))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: lists.take(2).map((list) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () => _openList(context, ref, list),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                list.name,
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Center(child: Icon(Icons.error, size: 16)),
              ),
            ),
            DashboardCard(
              title: "Recent Recipes",
              icon: Icons.history,
              onTap: () => Navigator.of(context).pushNamed('/recipes'),
              child: recipesAsync.when(
                data: (recipes) => recipes.isEmpty
                    ? const Center(child: Text("No recipes", style: TextStyle(fontSize: 12)))
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: recipes.take(2).map((recipe) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () => _openRecipe(context, ref, recipe),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              recipe.name,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),

                // ListView.builder(
                //         shrinkWrap: true,
                //         physics: const NeverScrollableScrollPhysics(),
                //         itemCount: recipes.length > 2 ? 2 : recipes.length,
                //         itemBuilder: (context, index) => Text(
                //           "• ${recipes[index].name}",
                //           style: const TextStyle(fontSize: 12),
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       ),
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Center(child: Icon(Icons.error, size: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
