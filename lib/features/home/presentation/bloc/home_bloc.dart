import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:delivery_customer/core/services/api/api_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/models.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeLoadRequested extends HomeEvent {}

class HomeRefreshRequested extends HomeEvent {}

class HomeLocationUpdateRequested extends HomeEvent {
  final double latitude;
  final double longitude;

  const HomeLocationUpdateRequested({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<dynamic> restaurants;
  final List<dynamic> featuredRestaurants;
  final List<Category> categories;
  final List<dynamic> promotions;
  final UserLocation? currentLocation;

  const HomeLoaded({
    required this.restaurants,
    required this.featuredRestaurants,
    required this.categories,
    required this.promotions,
    this.currentLocation,
  });

  @override
  List<Object> get props => [restaurants, featuredRestaurants, categories, promotions];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiService apiService;
  final LocationService locationService;

  HomeBloc({
    required this.apiService,
    required this.locationService,
  }) : super(HomeInitial()) {
    on<HomeLoadRequested>(_onHomeLoadRequested);
    on<HomeRefreshRequested>(_onHomeRefreshRequested);
    on<HomeLocationUpdateRequested>(_onHomeLocationUpdateRequested);
  }

  Future<void> _onHomeLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    await _loadHomeData(emit);
  }

  Future<void> _onHomeRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHomeData(emit);
  }

  Future<void> _onHomeLocationUpdateRequested(
    HomeLocationUpdateRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHomeData(emit, latitude: event.latitude, longitude: event.longitude);
  }

  Future<void> _loadHomeData(
    Emitter<HomeState> emit, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      UserLocation? currentLocation;
      
      // Get location if not provided
      if (latitude == null || longitude == null) {
        // Use the best available location (saved, GPS, or default)
        final locationResult = await locationService.getBestAvailableLocation();
        if (locationResult.success && locationResult.location != null) {
          currentLocation = locationResult.location!;
          latitude = currentLocation.latitude;
          longitude = currentLocation.longitude;
        } else {
          // Fallback to default location
          currentLocation = locationService.getDefaultLocation();
          latitude = currentLocation.latitude;
          longitude = currentLocation.longitude;
        }
      } else {
        currentLocation = UserLocation(
          latitude: latitude,
          longitude: longitude,
          accuracy: 0,
          timestamp: DateTime.now(),
        );
        
        // Save the provided location to storage
        await StorageService.setUserLocation(currentLocation.toJson());
      }

      // Load all data in parallel
      final results = await Future.wait([
        apiService.getRestaurants(
          latitude: latitude,
          longitude: longitude,
        ),
        apiService.getFeaturedRestaurants(
          latitude: latitude,
          longitude: longitude,
        ),
        apiService.getCategories(),
        apiService.getPromotions(),
      ]);

      final restaurantsResponse = results[0];
      final featuredRestaurantsResponse = results[1];
      final categoriesResponse = results[2];
      final promotionsResponse = results[3];

      if (restaurantsResponse.success && 
          featuredRestaurantsResponse.success &&
          categoriesResponse.success &&
          promotionsResponse.success) {
        emit(HomeLoaded(
          restaurants: restaurantsResponse.data ?? [],
          featuredRestaurants: featuredRestaurantsResponse.data ?? [],
          categories: (categoriesResponse.data ?? []).map<Category>((json) => Category.fromJson(json)).toList(),
          promotions: promotionsResponse.data ?? [],
          currentLocation: currentLocation,
        ));
      } else {
        final errorMessage = restaurantsResponse.error ?? 
                           featuredRestaurantsResponse.error ??
                           categoriesResponse.error ??
                           promotionsResponse.error ?? 
                           'Failed to load home data';
        emit(HomeError(message: errorMessage));
      }
    } catch (e) {
      emit(HomeError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }
}