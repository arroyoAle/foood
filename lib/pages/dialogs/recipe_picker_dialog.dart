import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe.dart';
import '../../providers/providers.dart';

typedef RecipePickerResult = ({Recipe main, List<Recipe> sides});

class RecipePickerDialog extends ConsumerStatefulWidget {
  const RecipePickerDialog({super.key});

  @override
  ConsumerState<RecipePickerDialog> createState() => _RecipePickerDialogState();
}

class _RecipePickerDialogState extends ConsumerState<RecipePickerDialog> {
  int _currentStep = 0;
  String _searchQuery = '';
  Recipe? _selectedMain;
  final Set<String> _selectedSideIds = {};

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);

    return AlertDialog(
      title: Text(_currentStep == 0 ? 'Select Main Dish' : 'Select Sides'),
      content: SizedBox(
        width: double.maxFinite,
        child: recipesAsync.when(
          data: (recipes) {
            final filteredRecipes = recipes
                .where((r) => r.name.toLowerCase().contains(_searchQuery))
                .toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];

                      if (_currentStep == 0) {
                        final isSelected = _selectedMain?.id == recipe.id;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(recipe.name),
                            leading: Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            selected: isSelected,
                            selectedTileColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            onTap: () => setState(() => _selectedMain = recipe),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      } else {
                        // Don't show main in sides list
                        if (recipe.id == _selectedMain?.id) {
                          return const SizedBox.shrink();
                        }

                        final isSelected = _selectedSideIds.contains(recipe.id);
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CheckboxListTile(
                            title: Text(recipe.name),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedSideIds.add(recipe.id);
                                } else {
                                  _selectedSideIds.remove(recipe.id);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_currentStep == 1)
          TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: const Text('Back'),
          ),
        FilledButton(
          onPressed: _selectedMain == null
              ? null
              : () {
                  if (_currentStep == 0) {
                    setState(() {
                      _currentStep = 1;
                      _searchQuery = ''; // Reset search for sides
                    });
                  } else {
                    final allRecipes = recipesAsync.value ?? [];
                    final selectedSides = allRecipes
                        .where((r) => _selectedSideIds.contains(r.id))
                        .toList();
                    Navigator.of(
                      context,
                    ).pop((main: _selectedMain!, sides: selectedSides));
                  }
                },
          child: Text(_currentStep == 0 ? 'Next' : 'Add Meals'),
        ),
      ],
    );
  }
}
