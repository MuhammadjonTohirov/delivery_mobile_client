import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';

class LocationService {
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  Future<LocationPermissionResult> checkAndRequestPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionResult.serviceDisabled;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionResult.denied;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionResult.deniedForever;
    }

    return LocationPermissionResult.granted;
  }

  Future<LocationResult> getCurrentLocation() async {
    try {
      final permissionResult = await checkAndRequestPermission();
      
      if (permissionResult != LocationPermissionResult.granted) {
        return LocationResult.error(_getPermissionErrorMessage(permissionResult));
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LocationResult.success(
        UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        ),
      );
    } catch (e) {
      return LocationResult.error('Failed to get current location: ${e.toString()}');
    }
  }

  Future<LocationResult> getLastKnownLocation() async {
    try {
      final permissionResult = await checkAndRequestPermission();
      
      if (permissionResult != LocationPermissionResult.granted) {
        return LocationResult.error(_getPermissionErrorMessage(permissionResult));
      }

      final position = await Geolocator.getLastKnownPosition();
      
      if (position == null) {
        // If no last known position, get current location
        return await getCurrentLocation();
      }

      return LocationResult.success(
        UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        ),
      );
    } catch (e) {
      return LocationResult.error('Failed to get last known location: ${e.toString()}');
    }
  }

  Stream<UserLocation> getLocationStream() {
    return Geolocator.getPositionStream(locationSettings: _locationSettings)
        .map((position) => UserLocation(
              latitude: position.latitude,
              longitude: position.longitude,
              accuracy: position.accuracy,
              timestamp: position.timestamp,
            ));
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  double calculateDistanceInKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    final distanceInMeters = calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return distanceInMeters / 1000;
  }

  bool isWithinRadius(
    double centerLatitude,
    double centerLongitude,
    double targetLatitude,
    double targetLongitude,
    double radiusInKm,
  ) {
    final distance = calculateDistanceInKm(
      centerLatitude,
      centerLongitude,
      targetLatitude,
      targetLongitude,
    );
    return distance <= radiusInKm;
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  UserLocation getDefaultLocation() {
    return UserLocation(
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      accuracy: 0,
      timestamp: DateTime.now(),
    );
  }

  String _getPermissionErrorMessage(LocationPermissionResult result) {
    switch (result) {
      case LocationPermissionResult.serviceDisabled:
        return 'Location services are disabled. Please enable location services.';
      case LocationPermissionResult.denied:
        return 'Location permission denied. Please grant location permission.';
      case LocationPermissionResult.deniedForever:
        return 'Location permission permanently denied. Please enable it in app settings.';
      case LocationPermissionResult.granted:
        return '';
    }
  }
}

class UserLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime? timestamp;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : null,
    );
  }

  @override
  String toString() {
    return 'UserLocation(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}

class LocationResult {
  final bool success;
  final UserLocation? location;
  final String? error;

  LocationResult.success(this.location) : success = true, error = null;
  LocationResult.error(this.error) : success = false, location = null;
}

enum LocationPermissionResult {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}