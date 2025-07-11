import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'base_api_service.dart';

class RestaurantApiService extends BaseApiService {
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

      final response = await dio.get(
        AppConstants.restaurantsEndpoint,
        queryParameters: queryParams,
      );
      
      return ApiResponse.success(handleListResponse(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
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

      final response = await dio.get(
        AppConstants.restaurantsEndpoint,
        queryParameters: queryParams,
      );
      
      return ApiResponse.success(handleListResponse(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<List<dynamic>>> getCategories() async {
    try {
      final response = await dio.get(AppConstants.categoriesEndpoint);
      return ApiResponse.success(handleListResponse(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getRestaurantDetails(String restaurantId) async {
    try {
      final response = await dio.get('${AppConstants.restaurantsEndpoint}$restaurantId/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<List<dynamic>>> getRestaurantMenu(String restaurantId) async {
    try {
      final response = await dio.get('${AppConstants.restaurantsEndpoint}$restaurantId/menu/');
      return ApiResponse.success(handleListResponse(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
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

      final response = await dio.get(
        AppConstants.menuItemsEndpoint,
        queryParameters: queryParams,
      );
      
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getMenuItemDetails(String itemId) async {
    try {
      final response = await dio.get('${AppConstants.menuItemsEndpoint}$itemId/');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }
}