import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
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
      
      if (kDebugMode) {
        print('Uploading profile image: ${imageFile.path}');
        print('File name: $fileName');
        print('File size: ${await imageFile.length()} bytes');
      }
      
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
      
      if (kDebugMode) {
        print('Profile image upload response: ${response.data}');
      }
      
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Profile image upload error: ${e.message}');
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
      }
      return ApiResponse.error(handleError(e));
    }
  }
}