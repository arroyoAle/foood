import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/data/database.dart' as db;
import 'package:foood/main.dart';
import 'package:foood/providers/providers.dart';

void main() {
  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpMyApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const MyApp(),
      ),
    );
  }

  group('Navigation Drawer', () {
    testWidgets('Drawer opens', (WidgetTester tester) async {
      await pumpMyApp(tester);
      final menuIcon = find.byIcon(Icons.menu);

      expect(find.text('Foood Home Page'), findsOneWidget);
      expect(menuIcon, findsOneWidget);
      
      await tester.tap(menuIcon);
      await tester.pump();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Spin Wheel'), findsOneWidget);
      expect(find.text('Lists'), findsOneWidget);
      expect(find.text('Recipes'), findsOneWidget);
    });

    testWidgets('Drawer closes', (WidgetTester tester) async {
      await pumpMyApp(tester);
      final menuIcon = find.byIcon(Icons.menu);

      await tester.tap(menuIcon);
      await tester.pumpAndSettle();

      expect(find.text('Spin Wheel'), findsOneWidget);

      // Tap outside
      await tester.tapAt(const Offset(799, 100)); // Assuming 800 width
      await tester.pumpAndSettle();

      expect(find.text('Spin Wheel'), findsNothing);
    });

    testWidgets('Navigate to lists page', (WidgetTester tester) async {
      await pumpMyApp(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lists'));
      await tester.pumpAndSettle();

      expect(find.text('Lists Home Page'), findsOneWidget);
    });

    testWidgets('Navigate to recipes page', (WidgetTester tester) async {
      await pumpMyApp(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();

      expect(find.text('Recipes Home Page'), findsOneWidget);
    });

    testWidgets('Navigate to spin wheel page', (WidgetTester tester) async {
      await pumpMyApp(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spin Wheel'));
      await tester.pumpAndSettle();

      expect(find.text('Spin Wheel Page'), findsOneWidget);
    });
  });
}
