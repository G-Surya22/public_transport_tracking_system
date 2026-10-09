// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ptts/main.dart';
import 'package:ptts/services/halt_geofence_service.dart';

void main() {
  testWidgets('shows passenger search screen after loading', (
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

  testWidgets('navigates to registration form from crew login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PttsApp());
    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Crew? Register Here'));
    await tester.pumpAndSettle();

    expect(find.text('Create Crew Account'), findsNWidgets(2));
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('crew mode requires login before access', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PttsApp());
    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Crew Login'), findsNWidgets(2));
    expect(find.text('Email ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('New Crew? Register Here'), findsOneWidget);
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
    expect(matches.first.path, [
      'S.Kota',
      'Boddam',
      'Kothavalasa',
      'Vizianagaram',
    ]);
    expect(matches.last.routeName, 'route12');
    expect(matches.last.path, [
      'S.Kota',
      'Jami',
      'Bheemasingi',
      'Vizianagaram',
    ]);
  });

  test('extracts unique endpoint suggestions from route data', () {
    final routes = {
      'route11': {
        'source': 'S.Kota',
        'destination': 'Vizianagaram',
        'halts': {
          'halt1': {'name': 'Boddam'},
        },
      },
      'route12': {'source': 'S.Kota', 'destination': 'Vizianagaram'},
      'route13': {'source': 'Vizianagaram', 'destination': 'Visakhapatnam'},
    };

    expect(endpointSuggestionsFromRoutes(routesData: routes, source: true), [
      'S.Kota',
      'Vizianagaram',
    ]);
    expect(endpointSuggestionsFromRoutes(routesData: routes, source: false), [
      'Visakhapatnam',
      'Vizianagaram',
    ]);
    expect(
      endpointSuggestionsFromRoutes(routesData: routes, source: true),
      isNot(contains('Boddam')),
    );
  });

  test(
    'extracts passenger suggestions from endpoints and intermediate halts',
    () {
      final routes = {
        'route2': {
          'source': 'Vizianagaram',
          'destination': 'Cheepurupalli',
          'halts': {
            'halt1': {'name': 'Vizianagaram'},
            'halt2': {'name': 'Nellimarla'},
            'halt3': {'name': 'Garividi'},
          },
        },
      };

      expect(locationSuggestionsFromRoutes(routesData: routes), [
        'Cheepurupalli',
        'Garividi',
        'Nellimarla',
        'Vizianagaram',
      ]);
    },
  );

  test('finds only active journeys for matched route IDs', () {
    final journeys = findActiveJourneys(
      routeIds: {'route1'},
      journeysData: {
        'journey1': {
          'route_id': 'route1',
          'bus_number': 'AP 31 AB 1234',
          'status': 'active',
          'current_halt_index': 2,
          'current_location': {'latitude': 18.1, 'longitude': 83.4},
        },
        'journey2': {
          'route_id': 'route1',
          'bus_number': 'AP 31 CD 5678',
          'status': 'aborted',
        },
        'journey3': {
          'route_id': 'route2',
          'bus_number': 'AP 31 EF 9012',
          'status': 'active',
        },
      },
    );

    expect(journeys.length, 1);
    expect(journeys.single.journeyId, 'journey1');
    expect(journeys.single.busNumber, 'AP 31 AB 1234');
    expect(journeys.single.currentHaltIndex, 2);
    expect(journeys.single.currentLocation['latitude'], 18.1);
  });

  test('geofence advances only the next halt and stops at route length', () {
    const service = HaltGeofenceService();
    const halts = [
      HaltPoint(name: 'Source', latitude: 18.100, longitude: 83.100),
      HaltPoint(name: 'Next', latitude: 18.105, longitude: 83.105),
    ];

    final first = service.evaluate(
      currentLatitude: 18.105,
      currentLongitude: 83.105,
      halts: halts,
      currentHaltIndex: 0,
    );
    expect(first.haltReached, isFalse);
    expect(first.currentHaltIndex, 0);

    final next = service.evaluate(
      currentLatitude: 18.105,
      currentLongitude: 83.105,
      halts: halts,
      currentHaltIndex: 1,
    );
    expect(next.haltReached, isTrue);
    expect(next.currentHaltIndex, 2);

    final complete = service.evaluate(
      currentLatitude: 18.105,
      currentLongitude: 83.105,
      halts: halts,
      currentHaltIndex: next.currentHaltIndex,
    );
    expect(complete.haltReached, isFalse);
    expect(complete.currentHaltIndex, 2);
  });

  test('geofence safely ignores invalid halt coordinates', () {
    final result = const HaltGeofenceService().evaluate(
      currentLatitude: 18.105,
      currentLongitude: 83.105,
      halts: [HaltPoint(name: 'Unknown', latitude: null, longitude: null)],
      currentHaltIndex: null,
    );

    expect(result.haltReached, isFalse);
    expect(result.currentHaltIndex, 0);
  });

  test('rejects a search that goes against the route direction', () {
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

  test('returns only the route that serves the requested direction', () {
    final routes = {
      'forwardRoute': {
        'source': 'Cheepurupalli',
        'destination': 'Vizianagaram',
        'halts': {
          'halt1': {'name': 'Cheepurupalli'},
          'halt2': {'name': 'Garividi'},
          'halt3': {'name': 'Vizianagaram'},
        },
      },
      'reverseRoute': {
        'source': 'Vizianagaram',
        'destination': 'Cheepurupalli',
        'halts': {
          'halt1': {'name': 'Vizianagaram'},
          'halt2': {'name': 'Garividi'},
          'halt3': {'name': 'Cheepurupalli'},
        },
      },
    };

    final matches = findMatchingRoutes(
      source: 'Cheepurupalli',
      destination: 'Vizianagaram',
      routesData: routes,
    );

    expect(matches.length, 1);
    expect(matches.single.routeId, 'forwardRoute');
  });

  test('finds a route between intermediate halts in the route direction', () {
    final routes = {
      'route2': {
        'source': 'Vizianagaram',
        'destination': 'Cheepurupalli',
        'halts': {
          'halt1': {'name': 'Vizianagaram'},
          'halt2': {'name': 'Nellimarla'},
          'halt3': {'name': 'Gurla'},
          'halt4': {'name': 'Garividi'},
          'halt5': {'name': 'Cheepurupalli'},
        },
      },
    };

    final forwardMatches = findMatchingRoutes(
      source: 'Nellimarla',
      destination: 'Garividi',
      routesData: routes,
    );
    expect(forwardMatches.single.routeId, 'route2');
    expect(forwardMatches.single.path, ['Nellimarla', 'Gurla', 'Garividi']);

    expect(
      findMatchingRoutes(
        source: 'Garividi',
        destination: 'Nellimarla',
        routesData: routes,
      ),
      isEmpty,
    );
  });

  test(
    'orders halts by numeric index even when map insertion order is shuffled',
    () {
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
      expect(matches.first.path, [
        'S.Kota',
        'Jami',
        'Bheemasingi',
        'Ayinada Junction',
        'Midtown',
        'Vizianagaram',
      ]);
    },
  );
}
