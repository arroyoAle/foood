import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foood/partials/top_bar.dart';

void main() {
  testWidgets('TopBarPartial displays title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(appBar: TopBarPartial(title: 'Test Title')),
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
  });

  testWidgets('TopBarPartial displays actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: TopBarPartial(
            title: 'Test Actions',
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
