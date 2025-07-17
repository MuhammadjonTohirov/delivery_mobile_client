import 'package:dio/dio.dart';
import 'package:delivery_customer/core/constants/app_constants.dart';
import 'base_api_service.dart';

class SearchApiService extends BaseApiService {
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

      final response = await dio.get(
        AppConstants.searchEndpoint,
        queryParameters: queryParams,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> searchMenuItems({
    String? query,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (query != null && query.isNotEmpty) 'search': query,
        if (category != null && category.isNotEmpty) 'category': category,
        'is_available': 'true',
      };

      final response = await dio.get(
        AppConstants.menuItemsEndpoint,
        queryParameters: queryParams,
      );
      
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }
}