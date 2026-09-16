import 'dart:math' as math;

class HaltPoint {
  final String name;
  final double? latitude;
  final double? longitude;

  const HaltPoint({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class HaltGeofenceResult {
  final int currentHaltIndex;
  final bool haltReached;

  const HaltGeofenceResult({
    required this.currentHaltIndex,
    required this.haltReached,
  });
}

class HaltGeofenceService {
  static const double radiusMeters = 500;

  const HaltGeofenceService();

  HaltGeofenceResult evaluate({
    required double currentLatitude,
    required double currentLongitude,
    required List<HaltPoint> halts,
    required int? currentHaltIndex,
  }) {
    final safeIndex = _safeIndex(currentHaltIndex, halts.length);
    if (!_isValidCoordinate(currentLatitude, currentLongitude) ||
        safeIndex >= halts.length) {
      return HaltGeofenceResult(
        currentHaltIndex: safeIndex,
        haltReached: false,
      );
    }

    final nextHalt = halts[safeIndex];
    final latitude = nextHalt.latitude;
    final longitude = nextHalt.longitude;
    if (!_isValidCoordinate(latitude, longitude)) {
      return HaltGeofenceResult(
        currentHaltIndex: safeIndex,
        haltReached: false,
      );
    }

    final distanceMeters = _distanceInMeters(
      currentLatitude,
      currentLongitude,
      latitude!,
      longitude!,
    );
    final reached = distanceMeters <= radiusMeters;

    return HaltGeofenceResult(
      currentHaltIndex: reached ? safeIndex + 1 : safeIndex,
      haltReached: reached,
    );
  }

  int _safeIndex(int? index, int haltCount) {
    if (index == null || index < 0) return 0;
    if (index > haltCount) return haltCount;
    return index;
  }

  bool _isValidCoordinate(double? latitude, double? longitude) {
    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        !(latitude == 0 && longitude == 0);
  }

  double _distanceInMeters(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const earthRadiusMeters = 6371000.0;
    final latitudeDelta = _toRadians(latitude2 - latitude1);
    final longitudeDelta = _toRadians(longitude2 - longitude1);
    final firstLatitude = _toRadians(latitude1);
    final secondLatitude = _toRadians(latitude2);

    final haversine =
        _squareOfSine(latitudeDelta / 2) +
        _squareOfSine(longitudeDelta / 2) *
            _cosine(firstLatitude) *
            _cosine(secondLatitude);
    final centralAngle = 2 * _arcsine(_squareRoot(haversine));
    return earthRadiusMeters * centralAngle;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  double _squareOfSine(double value) => math.sin(value) * math.sin(value);

  double _cosine(double value) => math.cos(value);

  double _arcsine(double value) => math.asin(value);

  double _squareRoot(double value) => math.sqrt(value < 0 ? 0 : value);
}
