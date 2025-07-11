import 'package:flutter/foundation.dart';

/// Centralized logging service for the application
class LoggerService {
  static const String _appName = 'DeliveryApp';

  /// Log debug information
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$_appName] 🐛 $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log information
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$_appName] ℹ️ $message');
      if (error != null) debugPrint('Info: $error');
    }
  }

  /// Log warnings
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$_appName] ⚠️ $message');
      if (error != null) debugPrint('Warning: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log errors
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[$_appName] ❌ $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }

  /// Log API requests (debug only)
  static void apiRequest(String method, String path, {Map<String, dynamic>? headers, dynamic data}) {
    if (kDebugMode) {
      debugPrint('[$_appName] 🚀 API REQUEST [$method] => $path');
      if (headers != null) debugPrint('Headers: $headers');
      if (data != null) debugPrint('Data: $data');
    }
  }

  /// Log API responses (debug only)
  static void apiResponse(int statusCode, String path, {dynamic data}) {
    if (kDebugMode) {
      debugPrint('[$_appName] 📥 API RESPONSE [$statusCode] => $path');
      if (data != null) debugPrint('Data: $data');
    }
  }

  /// Log API errors (debug only)
  static void apiError(int? statusCode, String path, String message, {dynamic data}) {
    debugPrint('[$_appName] ❌ API ERROR [$statusCode] => $path: $message');
    if (data != null) debugPrint('Error Data: $data');
  }

  /// Log cart operations (debug only)
  static void cart(String operation, {dynamic data}) {
    if (kDebugMode) {
      debugPrint('[$_appName] 🛒 CART: $operation');
      if (data != null) debugPrint('Data: $data');
    }
  }
}