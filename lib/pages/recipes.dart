import 'package:flutter/material.dart';
import 'package:spin_wheel/partials/drawer.dart';
import 'package:spin_wheel/partials/top_bar.dart';

class RecipesHomePage extends StatefulWidget {
  const RecipesHomePage({super.key});

  final String title = 'Recipes Home Page';
  @override
  State<RecipesHomePage> createState() => _RecipesHomePageState();
}

class _RecipesHomePageState extends State<RecipesHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarPartial(title: widget.title),
      drawer: DrawerPartial(currentPage: 'spinPage'),
    );
  }
}