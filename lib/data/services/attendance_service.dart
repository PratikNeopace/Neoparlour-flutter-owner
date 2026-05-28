import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/attendance_model.dart';

import 'package:neo_parlour_owner/data/models/leave_model.dart';

class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  Future<StaffAttendance> checkIn(int staffId) async {
    final response = await _apiClient.post(
      'staff-attendance/check-in',
      queryParameters: {'staffId': staffId},
    );
    return StaffAttendance.fromJson(response.data);
  }

  Future<StaffAttendance> checkOut(int staffId) async {
    final response = await _apiClient.post(
      'staff-attendance/check-out',
      queryParameters: {'staffId': staffId},
    );
    return StaffAttendance.fromJson(response.data);
  }

  Future<StaffAttendance?> getTodayAttendance(int staffId) async {
    try {
      final response = await _apiClient.get(
        'staff-attendance/today',
        queryParameters: {'staffId': staffId},
      );
      if (response.data != null) {
        return StaffAttendance.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<LeaveRequestResponse> applyLeave({
    required int staffId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final response = await _apiClient.post(
      'staff-attendance/leave/apply',
      queryParameters: {
        'staffId': staffId,
        'startDate': startDate,
        'endDate': endDate,
        'reason': reason,
      },
    );
    return LeaveRequestResponse.fromJson(response.data);
  }

  Future<LeaveResponseWrapper> fetchLeaveRequests({String? status, int? staffId, int page = 0}) async {
    final response = await _apiClient.get(
      'staff-attendance/leave/search',
      queryParameters: {
        if (status != null) 'status': status,
        if (staffId != null) 'staffId': staffId,
        'page': page,
        'size': 10,
        'sortBy': 'createdAt',
        'sortDir': 'desc',
      },
    );
    return LeaveResponseWrapper.fromJson(response.data);
  }

  Future<void> approveLeave(int leaveId) async {
    await _apiClient.post(
      'staff-attendance/leave/$leaveId/approve',
      options: Options(responseType: ResponseType.plain),
    );
  }

  Future<void> rejectLeave(int leaveId) async {
    await _apiClient.post(
      'staff-attendance/leave/$leaveId/reject',
      options: Options(responseType: ResponseType.plain),
    );
  }

  Future<StaffAttendanceResponseWrapper> getStaffAttendanceHistory({
    int? staffId,
    int page = 0,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      'staff-attendance/search',
      queryParameters: {
        if (staffId != null) 'staffId': staffId,
        'page': page,
        'size': size,
        'sortBy': 'attendanceDate',
        'sortDir': 'desc',
      },
    );
    return StaffAttendanceResponseWrapper.fromJson(response.data);
  }

  Future<StaffAttendanceResponseWrapper> getMonthlyAttendance({
    required int staffId,
    required int month,
  }) async {
    final response = await _apiClient.get(
      'staff-attendance/monthly',
      queryParameters: {
        'staffId': staffId,
        'month': month,
      },
    );
    return StaffAttendanceResponseWrapper.fromJson(response.data);
  }
}
