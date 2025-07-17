import 'package:delivery_customer/core/constants/app_constants.dart';
import 'package:dio/dio.dart';

import 'base_api_service.dart';

class CartApiService extends BaseApiService {
  Future<ApiResponse<Map<String, dynamic>>> getCart() async {
    try {
      final response = await dio.get(AppConstants.cartEndpoint);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> addToCart({
    required String menuItemId,
    required int quantity,
    String? notes,
    List<String>? selectedOptions,
  }) async {
    try {
      final response = await dio.post(
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
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCartItem({
    required String cartItemId,
    required int quantity,
    String? notes,
    List<String>? selectedOptions,
  }) async {
    try {
      final response = await dio.patch(
        '${AppConstants.cartEndpoint}$cartItemId/',
        data: {
          'quantity': quantity,
          if (notes != null) 'notes': notes,
          if (selectedOptions != null) 'selected_options': selectedOptions,
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> removeFromCart(String cartItemId) async {
    try {
      final response = await dio.delete('${AppConstants.cartEndpoint}$cartItemId/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> clearCart() async {
    try {
      final response = await dio.delete('${AppConstants.cartEndpoint}clear/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }
}