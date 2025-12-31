import 'package:flutter/material.dart';
import 'package:foood/partials/drawer.dart';
import 'package:foood/partials/top_bar.dart';
import 'package:foood/helpers/recipe_manager.dart' ;
import 'package:foood/models/recipe.dart' ;

class RecipePage extends StatefulWidget {
  const RecipePage({ super.key, required this.manager });

  final RecipeManager manager;
  // final Recipe recipe;
  final String title = 'Recipe Page';


  @override
  State<RecipePage> createState() => _RecipePageState( ) ;
}

class _RecipePageState extends State<RecipePage> {
  final _formKey = GlobalKey<FormState>();
  late Recipe _editableRecipe;


  @override
  void initState() {
    super.initState();
    _editableRecipe = Recipe.fromJson(widget.manager.activeRecipe!.toJson());
  }

  Future<void> _onSave() async {
    if (_formKey.currentState! . validate( ) )  {
      _formKey.currentState! . save( ) ;
      await widget.manager.saveActiveRecipe() ;
      if (mounted) {
        ScaffoldMessenger.of( context) . showSnackBar(
          const SnackBar(content: Text('Recipe saved!')), );
        Navigator.pop(context) ;
      }
    }
  }

  Future<void> _addNewInstruction() async {
  //   Todo: add functionality
  }

  Future<void> _addNewIngredient() async {
  //   Todo: add functionality can choose from existing items or create a new one
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarPartial(title: widget.title),
      drawer: DrawerPartial(currentPage: 'recipes_page'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0) ,
        child: Column(
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
            Text(
                'Ingredients',
                style: Theme.of(context).textTheme. titleLarge
            ),
            ListView.builder(
              itemCount: _editableRecipe.ingredients.length + 1,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => (index != _editableRecipe.ingredients.length)
                  ? Card(
                child: ListTile(
                  title: Text(_editableRecipe.ingredients[index].toString()),
                //   todo: on tap show popup about ingredient
                ),
              )
                  : Card(
                child: ListTile(
                  // TODO: Change style
                  title: Text('Add new ingredient'),
                  leading: Icon(Icons.add),
                  onTap: _addNewIngredient,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
                'Instructions',
                style: Theme.of(context).textTheme. titleLarge
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
          ],
        ),
        ),
    );
  }
}