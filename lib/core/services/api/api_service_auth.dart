import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../logger_service.dart';
import 'base_api_service.dart';

class AuthApiService extends BaseApiService {
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    try {
      final response = await dio.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'password_confirm': password,
          'full_name': fullName,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'customer_profile': {},
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String email) async {
    try {
      final response = await dio.post(
        AppConstants.forgotPasswordEndpoint,
        data: {
          'email': email,
        },
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await dio.get(AppConstants.profileEndpoint);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? fullName,
    String? phone,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      
      final response = await dio.patch(
        AppConstants.profileEndpoint,
        data: data,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfileImage({
    required XFile imageFile,
  }) async {
    try {
      final fileName = imageFile.name.isNotEmpty ? imageFile.name : 'profile_image.jpg';
      
      LoggerService.info('Uploading profile image', imageFile.path);
      LoggerService.debug('Upload file details', 'name: $fileName, size: ${await imageFile.length()} bytes');
      
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await dio.patch(
        AppConstants.profileEndpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      
      LoggerService.info('Profile image upload completed successfully');
      
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      LoggerService.error('Profile image upload failed', e);
      LoggerService.debug('Upload error details', 'status: ${e.response?.statusCode}, data: ${e.response?.data}');
      return ApiResponse.error(handleError(e));
    }
  }
}