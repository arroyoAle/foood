import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/forms.dart';
import 'package:foood/partials/top_bar.dart';
import '../providers/providers.dart';

class RecipePage extends ConsumerStatefulWidget {
  const RecipePage({super.key});

  final String title = 'Recipe Page';

  @override
  ConsumerState<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends ConsumerState<RecipePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  Future<void> _addNewIngredient() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Dialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: IngredientForm(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addNewInstruction() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Dialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: InstructionForm(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = ref.watch(activeRecipeProvider);

    if (recipe == null) {
      return Scaffold(
        appBar: TopBarPartial(title: widget.title),
        body: const Center(child: Text('No recipe selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              initialValue: recipe.name,
              decoration: const InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                if (value.isNotEmpty) {
                  ref.read(recipeRepositoryProvider).updateRecipeName(recipe.id, value);
                }
              },
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Ingredients'),
              Tab(text: 'Instructions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIngredientsList(recipe),
                _buildInstructionsList(recipe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(recipe) {
    return ListView.builder(
      itemCount: recipe.ingredients.length + 1,
      itemBuilder: (context, index) {
        if (index < recipe.ingredients.length) {
          final ingredient = recipe.ingredients[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(ingredient.name),
              subtitle: Text('${ingredient.category} - ${ingredient.defaultUnits}'),
            ),
          );
        } else {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: const Text('Add new ingredient'),
              leading: const Icon(Icons.add),
              onTap: _addNewIngredient,
            ),
          );
        }
      },
    );
  }

  Widget _buildInstructionsList(recipe) {
    return ListView.builder(
      itemCount: recipe.instructions.length + 1,
      itemBuilder: (context, index) {
        if (index < recipe.instructions.length) {
          final instruction = recipe.instructions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(instruction),
            ),
          );
        } else {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: const Text('Add new instruction'),
              leading: const Icon(Icons.add),
              onTap: _addNewInstruction,
            ),
          );
        }
      },
    );
  }
}
