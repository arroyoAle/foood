import 'package:flutter/material.dart';

class DrawerPartial extends StatelessWidget {
  final String currentPage;

  const DrawerPartial({
    super.key,
    required this.currentPage,
  });

  void _navigate(BuildContext context, String route, String page) {
    final navigator = Navigator.of(context);

    Navigator.pop(navigator.context);

    if (currentPage == page) {
      return;
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.popUntil(navigator.context, (route) => route.isFirst);
      if (page != 'home_page') {
        Navigator.pushNamed(navigator.context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            // Logic to highlight or disable the current page link
            selected: currentPage == 'home_page',
            onTap: () => _navigate(context, '/', 'home_page'),
          ),
          ListTile(
            leading: const Icon(Icons.change_circle),
            title: const Text('Spin Wheel'),
            selected: currentPage == 'spin_wheel_page',
            onTap: () => _navigate(context, '/spinWheel', 'spin_wheel_page'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Lists'),
            selected: currentPage == 'lists_page',
            onTap: () => _navigate(context, '/lists', 'lists_page'),
          ),
          ListTile(
            leading: const Icon(Icons.fastfood),
            title: const Text('Recipes'),
            selected: currentPage == 'recipes_page',
            onTap: () => _navigate(context, '/recipes', 'recipes_page'),
          ),
        ],
      ),
    );
  }
}