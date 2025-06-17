import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await _dio.get('/auth/profile/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
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
      
      return ApiResponse.success(response.data['results'] ?? response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getRestaurantDetails(int restaurantId) async {
    try {
      final response = await _dio.get('${AppConstants.restaurantsEndpoint}$restaurantId/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  Future<ApiResponse<List<dynamic>>> getRestaurantMenu(int restaurantId) async {
    try {
      final response = await _dio.get('${AppConstants.menuEndpoint}?restaurant=$restaurantId');
      return ApiResponse.success(response.data);
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

  Future<ApiResponse<Map<String, dynamic>>> getOrderDetails(int orderId) async {
    try {
      final response = await _dio.get('${AppConstants.ordersEndpoint}$orderId/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Promotions endpoints
  Future<ApiResponse<List<dynamic>>> getPromotions() async {
    try {
      final response = await _dio.get(AppConstants.promotionsEndpoint);
      return ApiResponse.success(response.data);
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