import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/logger_service.dart';

/// Centralized error handling utility
class ErrorHandler {
  
  /// Handle and display errors consistently across the app
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    bool showSnackBar = true,
    VoidCallback? onRetry,
  }) {
    final errorMessage = getErrorMessage(error, customMessage);
    
    LoggerService.error('Error handled: $errorMessage', error);
    
    if (showSnackBar && context.mounted) {
      _showErrorSnackBar(context, errorMessage, onRetry);
    }
  }

  /// Get formatted error message from various error types
  static String getErrorMessage(dynamic error, [String? customMessage]) {
    if (customMessage != null) return customMessage;
    
    if (error is DioException) {
      return _getDioErrorMessage(error);
    }
    
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    
    return error?.toString() ?? 'An unexpected error occurred';
  }

  /// Handle Dio-specific errors
  static String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        switch (statusCode) {
          case 400:
            return _extractErrorFromData(data) ?? 'Invalid request. Please check your input.';
          case 401:
            return 'Your session has expired. Please login again.';
          case 403:
            return 'You don\'t have permission to perform this action.';
          case 404:
            return 'The requested resource was not found.';
          case 422:
            return _extractErrorFromData(data) ?? 'Validation error. Please check your input.';
          case 500:
            return 'Server error. Please try again later.';
          case 503:
            return 'Service temporarily unavailable. Please try again later.';
          default:
            return _extractErrorFromData(data) ?? 'An error occurred. Please try again.';
        }
      
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true) {
          return 'No internet connection. Please check your network.';
        }
        return 'Network error. Please check your connection.';
      
      default:
        return 'An unexpected error occurred.';
    }
  }

  /// Extract error message from response data
  static String? _extractErrorFromData(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Try common error message fields
      final fields = ['detail', 'message', 'error', 'errors'];
      
      for (final field in fields) {
        if (data.containsKey(field)) {
          final value = data[field];
          if (value is String) return value;
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value is Map && value.isNotEmpty) {
            return value.values.first.toString();
          }
        }
      }
    }
    return null;
  }

  /// Show error snackbar with optional retry action
  static void _showErrorSnackBar(
    BuildContext context,
    String message,
    VoidCallback? onRetry,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info message
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error dialog for critical errors
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}