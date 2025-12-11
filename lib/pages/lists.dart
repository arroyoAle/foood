import 'package:flutter/material.dart';
import 'package:foood/partials/drawer.dart';
import 'package:foood/partials/top_bar.dart';

class ListsHomePage extends StatefulWidget {
  const ListsHomePage({super.key});

  final String title = 'Lists Home Page';
  @override
  State<ListsHomePage> createState() => _ListsHomePageState();
}

class _ListsHomePageState extends State<ListsHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarPartial(title: widget.title),
      drawer: DrawerPartial(currentPage: 'lists_page'),
    );
  }
}