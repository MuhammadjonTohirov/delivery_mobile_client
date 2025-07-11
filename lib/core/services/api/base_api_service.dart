import 'dart:io';
import 'package:delivery_customer/core/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:delivery_customer/core/constants/app_constants.dart';
import '../logger_service.dart';

abstract class BaseApiService {
  late Dio _dio;
  
  BaseApiService() {
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
        
        LoggerService.apiRequest(
          options.method,
          options.path,
          headers: options.headers,
          data: options.data,
        );
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        LoggerService.apiResponse(
          response.statusCode ?? 0,
          response.requestOptions.path,
          data: response.data,
        );
        handler.next(response);
      },
      onError: (error, handler) {
        LoggerService.apiError(
          error.response?.statusCode,
          error.requestOptions.path,
          error.message ?? 'Unknown error',
          data: error.response?.data,
        );
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  String handleError(DioException error) {
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

  /// Helper method to handle list/paginated response formats
  List<dynamic> handleListResponse(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    } else if (responseData is Map<String, dynamic>) {
      final results = responseData['results'];
      if (results is List) {
        return results;
      } else {
        return [];
      }
    } else {
      return [];
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