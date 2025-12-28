import 'package:flutter/material.dart';

class TopBarPartial extends StatelessWidget implements PreferredSizeWidget{
  const TopBarPartial({super.key, required this.title});
  
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu)
              );
            }
          ),
      );
  }
    @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}