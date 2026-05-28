import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/appointment_response.dart';

class AppointmentService {
  final ApiClient _apiClient = ApiClient();

  Future<PaginatedAppointments> fetchAppointments({
    String? mobile,
    String? staffName,
    String? status,
    int? salonId,
    String? fromDate,
    String? toDate,
    double? minAmount,
    double? maxAmount,
    int page = 0,
    int size = 20,
    String? sort,
    int? staffId,
  }) async {
    try {
      final queryParameters = {
        if (mobile != null) 'mobile': mobile,
        if (staffName != null) 'staffName': staffName,
        if (staffId != null) 'staffId': staffId,
        if (status != null) 'status': status,
        if (salonId != null) 'salonId': salonId,
        if (fromDate != null) 'fromDate': fromDate,
        if (toDate != null) 'toDate': toDate,
        if (minAmount != null) 'minAmount': minAmount,
        if (maxAmount != null) 'maxAmount': maxAmount,
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
      };

      final response = await _apiClient.get(
        'appointments/search/advanced',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return PaginatedAppointments.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch appointments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> rescheduleAppointment(
    int appointmentId,
    String newTime,
    String reason,
  ) async {
    try {
      final queryParameters = {'newTime': newTime};

      final response = await _apiClient.put(
        'appointments/$appointmentId/reschedule',
        queryParameters: queryParameters,
        data: reason,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to reschedule appointment: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> cancelAppointment(int appointmentId, String reason) async {
    try {
      final response = await _apiClient.put(
        'appointments/$appointmentId/cancel',
        data: reason,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to cancel appointment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Appointment>> fetchUserHistory(int userId) async {
    try {
      final response = await _apiClient.get(
        'appointments/search/advanced',
        queryParameters: {'customerId': userId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          final List<dynamic> content = data['content'] ?? [];
          return content.map((item) => Appointment.fromJson(item)).toList();
        } else if (data is List) {
          return data.map((item) => Appointment.fromJson(item)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch user history: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message;
      throw Exception('API Error: $message');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> assignStaff(int appointmentId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        'appointments/$appointmentId/change-staff',
        data: data,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to assign staff: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String message = e.message ?? 'Unknown error';
      final responseData = e.response?.data;
      if (responseData is Map && responseData.containsKey('message')) {
        message = responseData['message'].toString();
      } else if (responseData != null) {
        message = responseData.toString();
      }
      throw Exception('API Error: $message');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> approveAppointment(int appointmentId) async {
    try {
      final response = await _apiClient.put(
        'appointments/$appointmentId/complete',
        data: {},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to approve appointment: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Appointment> completeAppointment(
    int appointmentId,
    Appointment appointment,
    List<Map<String, dynamic>>? openedProductUsages,
  ) async {
    try {
      final queryParameters = <String, dynamic>{};

      // Merge openedProductUsages into the appointment body
      final requestData = appointment.toJson();
      requestData['openedProductUsages'] = openedProductUsages;

      final response = await _apiClient.put(
        'appointments/$appointmentId/complete',
        queryParameters: queryParameters,
        data: requestData,
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to complete appointment: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
