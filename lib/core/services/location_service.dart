import 'package:geolocator/geolocator.dart';
import 'package:delivery_customer/core/constants/app_constants.dart';
import 'package:delivery_customer/core/services/storage_service.dart';

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

  Future<LocationResult> getCurrentLocation({bool saveToStorage = true}) async {
    try {
      final permissionResult = await checkAndRequestPermission();
      
      if (permissionResult != LocationPermissionResult.granted) {
        return LocationResult.error(_getPermissionErrorMessage(permissionResult));
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userLocation = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );

      // Save location to storage if requested
      if (saveToStorage) {
        await StorageService.setUserLocation(userLocation.toJson());
      }

      return LocationResult.success(userLocation);
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

  /// Gets the best available location from storage or GPS
  Future<LocationResult> getBestAvailableLocation() async {
    // First try to get saved location
    final savedLocation = getSavedLocation();
    
    // Check if saved location is recent (less than 30 minutes old)
    if (savedLocation != null && _isLocationRecent(savedLocation)) {
      return LocationResult.success(savedLocation);
    }

    // Try to get current GPS location
    final currentLocationResult = await getCurrentLocation(saveToStorage: true);
    
    if (currentLocationResult.success) {
      return currentLocationResult;
    }

    // Fall back to saved location if available
    if (savedLocation != null) {
      return LocationResult.success(savedLocation);
    }

    // Fall back to default location
    return LocationResult.success(getDefaultLocation());
  }

  /// Gets location from local storage
  UserLocation? getSavedLocation() {
    final locationData = StorageService.getUserLocation();
    if (locationData != null) {
      try {
        return UserLocation.fromJson(locationData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Checks if location is recent (less than 30 minutes old)
  bool _isLocationRecent(UserLocation location) {
    if (location.timestamp == null) return false;
    
    final now = DateTime.now();
    final locationTime = location.timestamp!;
    final difference = now.difference(locationTime);
    
    return difference.inMinutes < 30; // Location is recent if less than 30 minutes old
  }

  /// Forces location update and saves to storage
  Future<LocationResult> forceLocationUpdate() async {
    return await getCurrentLocation(saveToStorage: true);
  }

  /// Clears saved location from storage
  Future<void> clearSavedLocation() async {
    await StorageService.clearUserLocation();
  }

  /// Initializes location on app startup
  /// This should be called when the app starts to ensure we have user location ready
  Future<void> initializeLocationOnStartup() async {
    try {
      // First check if we have a recent saved location
      final savedLocation = getSavedLocation();
      
      if (savedLocation != null && _isLocationRecent(savedLocation)) {
        // We have a recent location, no need to fetch GPS immediately
        return;
      }

      // Try to get current location in background without blocking the UI
      final permissionResult = await checkAndRequestPermission();
      
      if (permissionResult == LocationPermissionResult.granted) {
        // Get location and save it, but don't wait for it to complete
        getCurrentLocation(saveToStorage: true).then((result) {
          if (!result.success) {
            // If GPS fails, at least we have the saved location or default
            print('Location initialization failed: ${result.error}');
          }
        }).catchError((error) {
          print('Location initialization error: $error');
        });
      }
    } catch (e) {
      // Silent fail for startup location initialization
      print('Location initialization error: $e');
    }
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