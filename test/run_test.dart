import 'package:drift/drift.dart';
import 'unit_tests/shopping_repository_test.dart' as shopping_repo_test;
import 'unit_tests/recipe_repository_test.dart' as recipe_repo_test;
import 'unit_tests/all_lists_notifier_test.dart' as all_lists_notifier_test;
import 'unit_tests/recipe_notifier_test.dart' as recipe_notifier_test;
import 'unit_tests/shopping_list_notifier_test.dart' as shopping_notifier_test;

import 'widget_test/all_lists_widget_tests.dart' as all_list_test;
import 'widget_test/all_recipes_page_test.dart' as all_recipes_test;
import 'widget_test/drawer_widget_test.dart' as drawer_test;
import 'widget_test/home_page_test.dart' as home_page_test;
import 'widget_test/lists_widget_test.dart' as lists_test;
import 'widget_test/recipe_page_test.dart' as recipe_page_test;

void main() {
  // Drift generates a warning if we create multiple database instances.
  // In tests, we do this intentionally (one per test).
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Unit Tests
  shopping_repo_test.main();
  recipe_repo_test.main();
  all_lists_notifier_test.main();
  recipe_notifier_test.main();
  shopping_notifier_test.main();

  // Widget Tests
  all_list_test.main();
  all_recipes_test.main();
  drawer_test.main();
  home_page_test.main();
  lists_test.main();
  recipe_page_test.main();

  // Integration Tests
}
