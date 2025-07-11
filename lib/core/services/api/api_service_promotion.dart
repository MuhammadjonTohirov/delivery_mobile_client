import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'base_api_service.dart';

class PromotionApiService extends BaseApiService {
  Future<ApiResponse<List<dynamic>>> getPromotions() async {
    try {
      final response = await dio.get(AppConstants.promotionsEndpoint);
      return ApiResponse.success(handleListResponse(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> validatePromoCode(String code) async {
    try {
      final response = await dio.post(
        '${AppConstants.promotionsEndpoint}validate/',
        data: {'code': code},
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }
}