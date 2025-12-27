import 'unit_tests/storage_unit_tests.dart' as storage_tests;
import 'unit_tests/shopping_list_manager_tests.dart' as shopping_list_manager_tests;
import 'widget_test/drawer_widget_tests.dart' as drawer_tests;
import 'widget_test/lists_widget_tests.dart' as lists_tests;

void main () {
  // Unit Tests
  storage_tests.main();
  shopping_list_manager_tests.main();

  // Widget Tests
  drawer_tests.main();
  lists_tests.main();

  // Integration Tests
}