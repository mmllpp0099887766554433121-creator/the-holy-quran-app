import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Build a simple MaterialApp for testing
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Test App')),
          body: Center(child: Text('Hello World')),
        ),
      ),
    );

    // Verify that the app starts
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
  });
}