import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/auth_response.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<AuthResponse> login(String username, String password, {String? fcmToken}) async {
    try {
      final response = await _apiClient.post('auth/login', data: {
        'username': username,
        'password': password,
        'fcmToken': ?fcmToken,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to login: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> getProfile(int id) async {
    try {
      final response = await _apiClient.get('auth/profile/$id');
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch profile');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> getStaffProfile(int id) async {
    try {
      final response = await _apiClient.get('staff/$id');
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch staff profile');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendForgotPasswordOtp(String mobile) async {
    try {
      final response = await _apiClient.post(
        'auth/forgot-password/send-otp',
        queryParameters: {'mobile': mobile},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send OTP');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String mobile,
    required String otp,
    required String newPassword,
    String? fullName,
  }) async {
    try {
      final queryParams = {
        'mobile': mobile,
        'otp': otp,
        'newPassword': newPassword,
      };
      if (fullName != null) queryParams['fullName'] = fullName;

      final response = await _apiClient.post(
        'auth/forgot-password/reset',
        queryParameters: queryParams,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to reset password');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendRegisterOtp(String mobile) async {
    try {
      final response = await _apiClient.post(
        'auth/register/send-otp',
        queryParameters: {'mobile': mobile},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send registration OTP');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerWithOtp(Map<String, dynamic> registerData, String otp) async {
    try {
      final response = await _apiClient.post(
        'auth/owner/register',
        data: registerData,
        queryParameters: {'otp': otp},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Registration failed during OTP verification');
      }
      if (response.data != null && response.data is Map) {
        final data = response.data as Map;
        if (data['success'] == false ||
            data['status'] == 'error' ||
            data['status'] == 'fail') {
          throw Exception(data['message'] ??
              data['msg'] ??
              'Registration failed during OTP verification');
        }
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> updateProfile(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('auth/users/$id', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> updateStaffProfile(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('staff/$id', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update staff profile');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      final response = await _apiClient.delete('auth/users/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete account');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> refreshToken() async {
    try {
      final response = await _apiClient.post('auth/refresh-token');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to refresh token');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final response = await _apiClient.post('auth/logout');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to logout');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }
}
