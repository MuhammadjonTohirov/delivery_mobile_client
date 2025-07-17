import 'package:dio/dio.dart';
import 'package:delivery_customer/core/constants/app_constants.dart';
import 'base_api_service.dart';

class OrderApiService extends BaseApiService {
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    String? notes,
    String? promoCode,
  }) async {
    try {
      final response = await dio.post(
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
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<List<dynamic>>> getOrders({int page = 1}) async {
    try {
      final response = await dio.get(
        AppConstants.ordersEndpoint,
        queryParameters: {'page': page},
      );
      return ApiResponse.success(response.data['results'] ?? response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getOrderDetails(dynamic orderId) async {
    try {
      final response = await dio.get('${AppConstants.ordersEndpoint}$orderId/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> trackOrder(String orderId) async {
    try {
      final response = await dio.get('${AppConstants.ordersEndpoint}$orderId/track/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }
}