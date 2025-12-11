// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foood/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
  
  group('Navigation Drawer', () {

    testWidgets('Drawer opens', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
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
      await tester.pumpWidget(const MyApp());
      final menuIcon = find.byIcon(Icons.menu);

      await tester.tap(menuIcon);
      await tester.pumpAndSettle();

      expect(find.text('Spin Wheel'), findsOneWidget);

      await tester.tapAt(Offset(tester.getSize(find.byType(MyApp)).width - 1, 1.0));
      await tester.pumpAndSettle();

      expect(menuIcon, findsOneWidget);
      expect(find.text('Spin Wheel'), findsNothing);
      expect(find.text('Recipes'), findsNothing);
      expect(find.text('Menu'), findsNothing);
    });

    testWidgets('Navigate to lists page', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      final spinWheelLink = find.text('Lists');

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(spinWheelLink, findsOneWidget);

      await tester.tap(spinWheelLink);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Lists Home Page'), findsOneWidget);
      expect(find.text('Menu'), findsNothing);
    });

    testWidgets('Navigate to recipes page', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      final spinWheelLink = find.text('Recipes');

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(spinWheelLink, findsOneWidget);

      await tester.tap(spinWheelLink);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Recipes Home Page'), findsOneWidget);
      expect(find.text('Menu'), findsNothing);
    });

    testWidgets('Navigate to spin wheel page', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      final spinWheelLink = find.text('Spin Wheel');

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(spinWheelLink, findsOneWidget);

      await tester.tap(spinWheelLink);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Spin Wheel Page'), findsOneWidget);
      expect(find.text('Menu'), findsNothing);
    });

    testWidgets('Back action when not on home page always returns to home page', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spin Wheel'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Spin Wheel Page'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Foood Home Page'), findsOneWidget);
      expect(find.text('Spin Wheel'), findsNothing);
    });
  });
}
