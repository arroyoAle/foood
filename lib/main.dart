import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foood/pages/all_lists.dart';
import 'package:foood/pages/home.dart';
import 'package:foood/pages/all_recipes.dart';
import 'package:foood/pages/spin_wheel.dart';
import 'package:foood/partials/page_routes.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foood',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/spinWheel':
            page = const SpinWheelPage();
          case '/lists':
            page = const AllListsPage();
          case '/recipes':
            page = const AllRecipesPage();
          case '/':
          default:
            page = const MyHomePage();
        }
        return NoAnimationPageRoute(pageBuilder: (_, _, _) => page);
      },
    );
  }
}
