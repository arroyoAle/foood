import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class RecipePickerDialog extends ConsumerStatefulWidget {
  const RecipePickerDialog({super.key});

  @override
  ConsumerState<RecipePickerDialog> createState() => _RecipePickerDialogState();
}

class _RecipePickerDialogState extends ConsumerState<RecipePickerDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);

    return AlertDialog(
      title: const Text('Pick a Recipe'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Flexible(
              child: recipesAsync.when(
                data: (recipes) {
                  final filteredRecipes = recipes
                      .where((r) => r.name.toLowerCase().contains(_searchQuery))
                      .toList();

                  if (filteredRecipes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No recipes found'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return ListTile(
                        title: Text(recipe.name),
                        onTap: () => Navigator.of(context).pop(recipe),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
