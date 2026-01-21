import 'package:flutter/material.dart';
import 'package:foood/forms.dart';
import 'package:foood/partials/drawer.dart';
import 'package:foood/partials/top_bar.dart';
import 'package:foood/helpers/recipe_manager.dart' ;
import 'package:foood/models/recipe.dart' ;

class RecipePage extends StatefulWidget {
  const RecipePage({ super.key, required this.recipeManager });

  final RecipeManager recipeManager;
  final String title = 'Recipe Page';


  @override
  State<RecipePage> createState() => _RecipePageState() ;
}

class _RecipePageState extends State<RecipePage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late Recipe _editableRecipe;
  late TabController _tabController;
  late final RecipeManager recipeManager;

  @override
  void initState() {
    super.initState();
    recipeManager = widget.recipeManager;
    _editableRecipe = Recipe.fromJson(recipeManager.activeRecipe!.toJson());
    _tabController = TabController(vsync: this, length: 2);
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await recipeManager.saveActiveRecipe() ;
      if (mounted) {
        ScaffoldMessenger.of( context).showSnackBar(
          const SnackBar(content: Text('Recipe saved!')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _addNewIngredient() async {
    final bool? ingredientAdded = await _dialogBuilder(context, IngredientForm(recipeManager: recipeManager));
    if (ingredientAdded == true) {
      setState(() {

      });
    }

    //   Todo: add functionality can choose from existing items or create a new one
  }

  Future<void> _addNewInstruction() async {
    final bool? instructionAdded = await _dialogBuilder(context, InstructionForm(recipeManager: recipeManager));
    if (instructionAdded == true) {
      setState(() {

      });
    }
  //   Todo: add functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarPartial(title: widget.title),
      drawer: DrawerPartial(currentPage: 'recipes_page'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0) ,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: _editableRecipe.name,
              decoration: const InputDecoration(
                  labelText:  'Recipe Name',
                  border: OutlineInputBorder()
              ) ,
              validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
              onSaved: (value) => _editableRecipe.name = value!,
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Ingredients'),
                Tab(text: 'Instructions'),
              ]
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(5, 16, 5, 0),
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
                    itemCount: _editableRecipe.ingredients.length + 1,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) => (index != _editableRecipe.ingredients.length) ?
                    Card(
                      child: ListTile(
                        title: Text(_editableRecipe.ingredients[index].toString()),
                        //   todo: on tap show popup about ingredient
                      ),
                    ) :
                    Card(
                      child: ListTile(
                        // TODO: Change style
                        title: Text('Add new ingredient'),
                        leading: Icon(Icons.add),
                        onTap: _addNewIngredient,
                      ),
                    ),
                  ),
                  ListView.builder(
                    itemCount: _editableRecipe.instructions.length + 1,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) =>
                    (index != _editableRecipe.instructions.length) ?
                    Card(
                      child: ListTile(
                        title: Text(_editableRecipe.instructions[index]),
                        //   todo: on tap show popup about instruction
                      ),
                    ) :
                    Card(
                      child: ListTile(
                        // TODO: Change style
                        title: Text('Add new instruction'),
                        leading: Icon(Icons.add),
                        onTap: _addNewInstruction,
                      ),
                    ),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _dialogBuilder(BuildContext context, Widget form) {
    return showDialog(context: context, builder: (BuildContext context) {
      return Dialog(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(15),
            child: form,
          ),
        ),
      );
    });
  }
}