import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/staff_model.dart';

class StaffService {
  final ApiClient _apiClient = ApiClient();

  Future<Staff> addStaff(Staff staff) async {
    try {
      final response = await _apiClient.post(
        'auth/staff',
        data: staff.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Staff.fromJson(response.data);
      } else {
        throw Exception('Failed to add staff: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Staff>> fetchStaff() async {
    try {
      // List staff specifically for the salon owner as per UserController
      final response = await _apiClient.get('staff');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => Staff.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch staff');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Staff>> getAvailableStaff({required String selectedTime, required int durationMinutes}) async {
    try {
      final queryParameters = {
        'selectedTime': selectedTime,
        'durationMinutes': durationMinutes,
      };

      final response = await _apiClient.get(
        'appointments/available-staff',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => Staff.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch available staff');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Staff> updateStaff(Staff staff) async {
    try {
      // Updating staff using the staff record ID
      final response = await _apiClient.put(
        'staff/${staff.id}',
        data: staff.toJson(),
      );

      if (response.statusCode == 200) {
        return Staff.fromJson(response.data);
      } else {
        throw Exception('Failed to update staff');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleStaffStatus(int id, bool active) async {
    try {
      final response = await _apiClient.put(
        'staff/$id/toggle',
        queryParameters: {'active': active},
      );
      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        throw Exception('Successfully updated staff status');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }
}
