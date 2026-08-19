// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ptts/main.dart';

void main() {
  testWidgets('shows loading logo then transport search form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PttsApp());

    expect(find.text('PTTS'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pumpAndSettle();

    expect(find.text('Search public transport services'), findsOneWidget);
    expect(find.text('Source location'), findsOneWidget);
    expect(find.text('Destination location'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('validates and submits locations', (WidgetTester tester) async {
    await tester.pumpWidget(const PttsApp());
    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Search'));
    await tester.pump();
    expect(find.text('Enter your starting location'), findsOneWidget);
    expect(find.text('Enter your destination'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Central Station');
    await tester.enterText(find.byType(TextFormField).at(1), 'City Museum');
    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(
      find.textContaining('Searching routes from Central Station'),
      findsOneWidget,
    );
  });

  testWidgets('switches between passenger and crew modes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PttsApp());
    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pumpAndSettle();

    expect(find.text('Passenger'), findsOneWidget);
    expect(find.text('Search public transport services'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Crew'), findsOneWidget);
    expect(find.text('Start journey'), findsNWidgets(2));
    expect(find.text('Search public transport services'), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Passenger'), findsOneWidget);
    expect(find.text('Search public transport services'), findsOneWidget);
  });
}
