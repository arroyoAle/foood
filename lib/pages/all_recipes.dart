import 'package:flutter/material.dart';
import 'package:foood/helpers/recipe_manager.dart';
import 'package:foood/models/recipe.dart';
import 'package:foood/partials/drawer.dart';
import 'package:foood/pages/recipe.dart';

import '../partials/top_bar.dart';

class AllRecipesPage extends StatefulWidget {
  const AllRecipesPage({super.key, this.manager});

  final String title = 'Recipes Home Page';
  final RecipeManager? manager;
  @override
  State<AllRecipesPage> createState() => _AllRecipesPageState();
}

class _AllRecipesPageState extends State<AllRecipesPage> {
  late final RecipeManager _manager;
  late Future<void> _loadingFuture;

  @override void initState() {
    super.initState();
    _manager = widget.manager ?? RecipeManager();
    _loadingFuture = _manager.loadRecipes();
  }

  void _refresh() {
    setState(() {
      _loadingFuture = _manager.loadRecipes();
    });
  }

  // void _navigateToDetail(Recipe recipe) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) =>
  //           RecipePage(
  //               manager: manager),
  //     ),
  //   ).then(() => _refresh()); // Refresh the list when returning.
  // }

  void _openList(Recipe recipe) {
    _manager.setActiveRecipe(recipe);
    Navigator.of(context).push(
      MaterialPageRoute(
        // builder: (context) => RecipePage(),
        builder: (context) => RecipePage(manager: _manager),
      ),
    ).then((_) {
      setState(() {
        _loadingFuture = _manager.loadRecipes();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarPartial(title: widget.title),
      drawer: DrawerPartial(currentPage: 'recipes_page'),
      body: FutureBuilder( future: _loadingFuture,
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)  {
          return const Center(child: CircularProgressIndicator( ) ) ;
        }

        final recipes = _manager.allRecipes;
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
              onTap: () => _openList(recipe),
            );
          },
        );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          _manager.createNewRecipe('test recipe').then((recipe) => _openList(recipe)),
          // _refresh()
          // ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(content: Text('Currently does nothing')))
          },
        tooltip: 'Add New Recipe',
        child: const Icon(Icons.add),
      ),
    );
  }
}