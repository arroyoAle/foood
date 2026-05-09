import 'package:drift/drift.dart';
import 'unit_tests/shopping_repository_test.dart' as shopping_repo_tests;
import 'unit_tests/recipe_repository_test.dart' as recipe_repo_tests;
import 'widget_test/drawer_widget_tests.dart' as drawer_tests;
import 'widget_test/lists_widget_tests.dart' as lists_tests;
import 'widget_test/all_lists_widget_tests.dart' as all_list_tests;

void main () {
  // Drift generates a warning if we create multiple database instances.
  // In tests, we do this intentionally (one per test).
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Unit Tests
  shopping_repo_tests.main();
  recipe_repo_tests.main();

  // Widget Tests
  drawer_tests.main();
  lists_tests.main();
  all_list_tests.main();

  // Integration Tests
}
