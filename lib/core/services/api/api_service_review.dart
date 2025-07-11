import 'package:dio/dio.dart';
import 'package:delivery_customer/core/constants/app_constants.dart';
import 'base_api_service.dart';

class ReviewApiService extends BaseApiService {
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

      final response = await dio.get(
        AppConstants.reviewsEndpoint,
        queryParameters: queryParams,
      );
      
      return ApiResponse.success(handleListResponse(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> submitReview({
    required int restaurantId,
    required int orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await dio.post(
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
      return ApiResponse.error(handleError(e));
    }
  }
}