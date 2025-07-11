class AppConstants {
  static const String appName = 'Delivery Customer';
  static const String serverUrl = 'http://192.168.1.115:8000';
  static String baseUrl = '$serverUrl/api';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/token/';
  static const String registerEndpoint = '/auth/register/';
  static const String forgotPasswordEndpoint = '/auth/forgot-password/';
  static const String restaurantsEndpoint = '/restaurants/list/';
  static const String categoriesEndpoint = '/restaurants/categories/';
  static const String ordersEndpoint = '/orders/';
  static const String menuEndpoint = '/restaurants/menus/'; // Note: Use restaurantsEndpoint + restaurantId + '/menu/' for specific restaurant menus
  static const String menuItemsEndpoint = '/restaurants/menu-items/';
  static const String searchEndpoint = '/search/';
  static const String promotionsEndpoint = '/promotions/';
  static const String reviewsEndpoint = '/restaurants/reviews/';
  static const String cartEndpoint = '/cart/';
  static const String profileEndpoint = '/auth/profile/';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_data';
  static const String addressKey = 'saved_addresses';
  static const String locationKey = 'user_location';
  static const String lastLocationUpdateKey = 'last_location_update';
  
  // App Settings
  static const int requestTimeout = 30000; // 30 seconds
  static const double defaultLatitude = 41.2995; // Tashkent
  static const double defaultLongitude = 69.2401;
  static const double searchRadius = 10.0; // km
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}