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

  test('finds a valid route when source appears before destination', () {
    final routes = {
      'route11': {
        'halts': {
          'halt1': {'name': 'S.Kota'},
          'halt2': {'name': 'Boddam'},
          'halt3': {'name': 'Kothavalasa'},
          'halt4': {'name': 'Vizianagaram'},
        },
      },
      'route12': {
        'halts': {
          'halt1': {'name': 'S.Kota'},
          'halt2': {'name': 'Jami'},
          'halt3': {'name': 'Bheemasingi'},
          'halt4': {'name': 'Vizianagaram'},
        },
      },
    };

    final matches = findMatchingRoutes(
      source: 'S.Kota',
      destination: 'Vizianagaram',
      routesData: routes,
    );

    expect(matches.length, 2);
    expect(matches.first.routeName, 'route11');
    expect(matches.first.path, ['S.Kota', 'Boddam', 'Kothavalasa', 'Vizianagaram']);
    expect(matches.last.routeName, 'route12');
    expect(matches.last.path, ['S.Kota', 'Jami', 'Bheemasingi', 'Vizianagaram']);
  });

  test('returns no route when destination appears before source', () {
    final routes = {
      'route7': {
        'halts': {
          'halt1': {'name': 'Vizianagaram'},
          'halt2': {'name': 'Ayinada Junction'},
          'halt3': {'name': 'S.Kota'},
        },
      },
    };

    final matches = findMatchingRoutes(
      source: 'S.Kota',
      destination: 'Vizianagaram',
      routesData: routes,
    );

    expect(matches, isEmpty);
  });

  test('orders halts by numeric index even when map insertion order is shuffled', () {
    final routes = {
      'route15': {
        'halts': {
          'halt10': {'name': 'Midtown'},
          'halt2': {'name': 'Jami'},
          'halt1': {'name': 'S.Kota'},
          'halt15': {'name': 'Vizianagaram'},
          'halt3': {'name': 'Bheemasingi'},
          'halt4': {'name': 'Ayinada Junction'},
        },
      },
    };

    final matches = findMatchingRoutes(
      source: 'S.Kota',
      destination: 'Vizianagaram',
      routesData: routes,
    );

    expect(matches.length, 1);
    expect(
      matches.first.path,
      ['S.Kota', 'Jami', 'Bheemasingi', 'Ayinada Junction', 'Midtown', 'Vizianagaram'],
    );
  });
}
