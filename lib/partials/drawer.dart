// In file: lib/partials/drawer.dart

import 'package:flutter/material.dart';

class DrawerPartial extends StatelessWidget {
  final String currentPage;

  const DrawerPartial({
    super.key,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    // The Drawer widget is the standard way to create a navigation drawer.
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          // The DrawerHeader is a standard nice-looking header for your drawer.
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, // You can customize the color
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // ListTile is a great widget for menu items.
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            // Logic to highlight or disable the current page link
            selected: currentPage == 'home_page',
            onTap: () {
              // Close the drawer
              Navigator.pop(context);

              // If not already on the home page, navigate to it.
              // This check prevents navigating to the same page again.
              if (currentPage != 'home_page') {
                // Assuming you have a route named '/' for your home page
                Navigator.pushNamed(context, '/');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.change_circle),
            title: const Text('Spin Wheel'),
            selected: currentPage == 'spin_wheel_page',
            onTap: () {
              // Close the drawer
              Navigator.pop(context);

              if (currentPage != 'spin_wheel_page') {
                // Assuming you have a '/settings' route
                Navigator.pushNamed(context, '/spinWheel');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Lists'),
            selected: currentPage == 'lists_page',
            onTap: () {
              // Close the drawer
              Navigator.pop(context);

              if (currentPage != 'lists_page') {
                // Assuming you have an '/about' route
                Navigator.pushNamed(context, '/lists');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.fastfood),
            title: const Text('Recipes'),
            selected: currentPage == 'recipes_page',
            onTap: () {
              // Close the drawer
              Navigator.pop(context);

              if (currentPage != 'recipes_page') {
                // Assuming you have an '/about' route
                Navigator.pushNamed(context, '/recipes');
              }
            },
          ),
        ],
      ),
    );
  }
}