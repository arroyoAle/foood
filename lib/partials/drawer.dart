import 'package:flutter/material.dart';
import 'package:spin_wheel/pages/home.dart';
import 'package:spin_wheel/pages/spin_wheel.dart';

class DrawerPartial extends StatefulWidget {
  const DrawerPartial({super.key, required this.currentPage});
  
  final String currentPage;

  @override
  State<DrawerPartial> createState() => _DrawerPartialState();
}

class _DrawerPartialState extends State<DrawerPartial> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page  = MyHomePage();
      case 1:
        page = SpinWheelPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');

    }

    return Drawer(
        child: NavigationRail(
          extended: true,
          destinations: [
            NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home Page')),
            NavigationRailDestination(icon: Icon(Icons.search), label: Text('Spin Wheel Page'))
          ],
        selectedIndex: selectedIndex,
        onDestinationSelected: (value){
          setState(() {
            selectedIndex = value;
          });
        },
        )
      );
  }
}

// ListView(
//   padding: EdgeInsets.zero,
//   children: [
//     const DrawerHeader(
//       decoration: BoxDecoration(color: Colors.blue),
//       child: Text('Drawer Header')
//       ),
//     ListTile(
//       selected: widget.currentPage == 'home_page' ? true : false,
//       selectedColor: Colors.blue,
//       title: const Text('Home'),
//       onTap: () {
//         Navigator.pop(context);
//       },
//     ),
//     ListTile(
//       selected: widget.currentPage == 'spin_page' ? true : false,
//       selectedColor: Colors.blue,
//       title: const Text('Spin Page'),
//       onTap: () {
//         Navigator.pop(context);
//       },
//     )
//   ],
// ),