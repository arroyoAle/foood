import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/models/recipe.dart';
import 'package:foood/partials/drawer.dart';
import 'package:foood/pages/recipe.dart';
import '../providers/providers.dart';
import '../partials/top_bar.dart';

class AllRecipesPage extends ConsumerWidget {
  const AllRecipesPage({super.key});

  final String title = 'Recipes Home Page';

  void _openList(BuildContext context, WidgetRef ref, Recipe recipe) {
    ref.read(activeRecipeIdProvider.notifier).state = recipe.id;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecipePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: TopBarPartial(title: title),
      drawer: DrawerPartial(currentPage: 'recipes_page'),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(child: Text('No recipes yet'));
          }
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                title: Text(recipe.name),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _openList(context, ref, recipe),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nameController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('New Recipe'),
              content: TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Recipe name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      await ref.read(recipesProvider.notifier).createRecipe(nameController.text);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          );
        },
        tooltip: 'Add New Recipe',
        child: const Icon(Icons.add),
      ),
    );
  }
}
