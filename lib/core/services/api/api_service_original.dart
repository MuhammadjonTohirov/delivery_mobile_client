import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class ApiService {
  late Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.requestTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.requestTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await StorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        if (kDebugMode) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          print('Headers: ${options.headers}');
          if (options.data != null) {
            print('Data: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          print('Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('Message: ${error.message}');
          print('Data: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'password_confirm': password,
          'full_name': fullName,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'customer_profile': {},
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        AppConstants.forgotPasswordEndpoint,
        data: {
          'email': email,
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await _dio.get(AppConstants.profileEndpoint);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? fullName,
    String? phone,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      
      final response = await _dio.patch(
        AppConstants.profileEndpoint,
        data: data,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfileImage({
    required XFile imageFile,
  }) async {
    try {
      final fileName = imageFile.name.isNotEmpty ? imageFile.name : 'profile_image.jpg';
      
      if (kDebugMode) {
        print('Uploading profile image: ${imageFile.path}');
        print('File name: $fileName');
        print('File size: ${await imageFile.length()} bytes');
      }
      
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.patch(
        AppConstants.profileEndpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      
      if (kDebugMode) {
        print('Profile image upload response: ${response.data}');
      }
      
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Profile image upload error: ${e.message}');
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
      }
      return ApiResponse.error(_handleError(e));
    }
  }

  // Restaurant endpoints
  Future<ApiResponse<List<dynamic>>> getRestaurants({
    double? latitude,
    double? longitude,
    String? search,
    String? category,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
      };

      final response = await _dio.get(
        AppConstants.restaurantsEndpoint,
        queryParameters: queryParams,
      );
      
      // Handle different response formats
      if (response.data is List) {
        return ApiResponse.success(response.data);
      } else if (response.data is Map<String, dynamic>) {
        final results = response.data['results'];
        if (results is List) {
          return ApiResponse.success(results);
        } else {
          return ApiResponse.success([]);
        }
      } else {
        return ApiResponse.success([]);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<dynamic>>> getFeaturedRestaurants({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'featured': 'true',
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
      };

      final response = await _dio.get(
        AppConstants.restaurantsEndpoint,
        queryParameters: queryParams,
      );
      
      // Handle different response formats
      if (response.data is List) {
        return ApiResponse.success(response.data);
      } else if (response.data is Map<String, dynamic>) {
        final results = response.data['results'];
        if (results is List) {
          return ApiResponse.success(results);
        } else {
          return ApiResponse.success([]);
        }
      } else {
        return ApiResponse.success([]);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<dynamic>>> getCategories() async {
    try {
      final response = await _dio.get(AppConstants.categoriesEndpoint);
      
      // Handle different response formats
      if (response.data is List) {
        return ApiResponse.success(response.data);
      } else if (response.data is Map<String, dynamic>) {
        final results = response.data['results'];
        if (results is List) {
          return ApiResponse.success(results);
        } else {
          return ApiResponse.success([]);
        }
      } else {
        return ApiResponse.success([]);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getRestaurantDetails(String restaurantId) async {
    try {
      final response = await _dio.get('${AppConstants.restaurantsEndpoint}$restaurantId/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<dynamic>>> getRestaurantMenu(String restaurantId) async {
    try {
      final response = await _dio.get('${AppConstants.restaurantsEndpoint}$restaurantId/menu/');
      
      // Handle different response formats
      if (response.data is List) {
        return ApiResponse.success(response.data);
      } else if (response.data is Map<String, dynamic>) {
        final results = response.data['results'];
        if (results is List) {
          return ApiResponse.success(results);
        } else {
          return ApiResponse.success([]);
        }
      } else {
        return ApiResponse.success([]);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Search endpoints
  Future<ApiResponse<Map<String, dynamic>>> search(String query, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
      };

      final response = await _dio.get(
        AppConstants.searchEndpoint,
        queryParameters: queryParams,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getMenuItems({
    String? restaurantId,
    String? query,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (restaurantId != null) 'restaurant': restaurantId,
        if (query != null && query.isNotEmpty) 'search': query,
        if (category != null && category.isNotEmpty) 'category': category,
        'is_available': 'true',
      };

      final response = await _dio.get(
        AppConstants.menuItemsEndpoint,
        queryParameters: queryParams,
      );
      
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> searchMenuItems({
    String? query,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    return getMenuItems(
      query: query,
      category: category,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getMenuItemDetails(String itemId) async {
    try {
      final response = await _dio.get('${AppConstants.menuItemsEndpoint}$itemId/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Cart endpoints
  Future<ApiResponse<Map<String, dynamic>>> getCart() async {
    try {
      final response = await _dio.get(AppConstants.cartEndpoint);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> addToCart({
    required String menuItemId,
    required int quantity,
    String? notes,
    List<String>? selectedOptions,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConstants.cartEndpoint}add/',
        data: {
          'menu_item_id': menuItemId,
          'quantity': quantity,
          if (notes != null) 'notes': notes,
          if (selectedOptions != null) 'selected_options': selectedOptions,
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCartItem({
    required String cartItemId,
    required int quantity,
    String? notes,
    List<String>? selectedOptions,
  }) async {
    try {
      final response = await _dio.patch(
        '${AppConstants.cartEndpoint}$cartItemId/',
        data: {
          'quantity': quantity,
          if (notes != null) 'notes': notes,
          if (selectedOptions != null) 'selected_options': selectedOptions,
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> removeFromCart(String cartItemId) async {
    try {
      final response = await _dio.delete('${AppConstants.cartEndpoint}$cartItemId/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> clearCart() async {
    try {
      final response = await _dio.delete('${AppConstants.cartEndpoint}clear/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Order endpoints
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    String? notes,
    String? promoCode,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.ordersEndpoint,
        data: {
          'restaurant_id': restaurantId,
          'items': items,
          'delivery_address': deliveryAddress,
          if (notes != null) 'notes': notes,
          if (promoCode != null) 'promo_code': promoCode,
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<dynamic>>> getOrders({int page = 1}) async {
    try {
      final response = await _dio.get(
        AppConstants.ordersEndpoint,
        queryParameters: {'page': page},
      );
      return ApiResponse.success(response.data['results'] ?? response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getOrderDetails(dynamic orderId) async {
    try {
      final response = await _dio.get('${AppConstants.ordersEndpoint}$orderId/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> trackOrder(String orderId) async {
    try {
      final response = await _dio.get('${AppConstants.ordersEndpoint}$orderId/track/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Promotions endpoints
  Future<ApiResponse<List<dynamic>>> getPromotions() async {
    try {
      final response = await _dio.get(AppConstants.promotionsEndpoint);
      
      // Handle different response formats
      if (response.data is List) {
        return ApiResponse.success(response.data);
      } else if (response.data is Map<String, dynamic>) {
        final results = response.data['results'];
        if (results is List) {
          return ApiResponse.success(results);
        } else {
          return ApiResponse.success([]);
        }
      } else {
        return ApiResponse.success([]);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> validatePromoCode(String code) async {
    try {
      final response = await _dio.post(
        '${AppConstants.promotionsEndpoint}validate/',
        data: {'code': code},
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Reviews endpoints
  Future<ApiResponse<List<dynamic>>> getRestaurantReviews(
    String restaurantId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'restaurant': restaurantId,
        'page': page,
        'page_size': pageSize,
      };

      final response = await _dio.get(
        AppConstants.reviewsEndpoint,
        queryParameters: queryParams,
      );
      
      // Handle different response formats
      if (response.data is List) {
        return ApiResponse.success(response.data);
      } else if (response.data is Map<String, dynamic>) {
        final results = response.data['results'];
        if (results is List) {
          return ApiResponse.success(results);
        } else {
          return ApiResponse.success([]);
        }
      } else {
        return ApiResponse.success([]);
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> submitReview({
    required int restaurantId,
    required int orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.reviewsEndpoint,
        data: {
          'restaurant_id': restaurantId,
          'order_id': orderId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (error.response?.statusCode == 404) {
          return 'Resource not found.';
        } else if (error.response?.statusCode == 500) {
          return 'Server error. Please try again later.';
        } else {
          final data = error.response?.data;
          if (data is Map<String, dynamic>) {
            if (data.containsKey('detail')) {
              return data['detail'].toString();
            } else if (data.containsKey('message')) {
              return data['message'].toString();
            } else if (data.containsKey('error')) {
              return data['error'].toString();
            }
          }
          return 'An error occurred. Please try again.';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No internet connection. Please check your network.';
        }
        return 'An unexpected error occurred.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data) : success = true, error = null;
  ApiResponse.error(this.error) : success = false, data = null;
}