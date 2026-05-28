import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/attendance_model.dart';
import 'package:neo_parlour_owner/data/services/attendance_service.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/data/models/leave_model.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceService _service = AttendanceService();
  StaffAttendance? _todayAttendance;
  List<LeaveRequestModel> _pendingLeaveRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  StaffAttendance? get todayAttendance => _todayAttendance;
  List<LeaveRequestModel> get pendingLeaveRequests => _pendingLeaveRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTodayAttendance(int staffId) async {
    _todayAttendance = null;
    _isLoading = true;
    notifyListeners();
    try {
      _todayAttendance = await _service.getTodayAttendance(staffId);
    } catch (e) {
      debugPrint("Error fetching today's attendance: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPendingLeaveRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.fetchLeaveRequests(status: 'PENDING');
      _pendingLeaveRequests = response.content;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> approveLeaveRequest(int leaveId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.approveLeave(leaveId);
      _pendingLeaveRequests.removeWhere((req) => req.id == leaveId);
      notifyListeners();
      await fetchPendingLeaveRequests(); // Refresh in background
      return "Leave request approved successfully";
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> rejectLeaveRequest(int leaveId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.rejectLeave(leaveId);
      _pendingLeaveRequests.removeWhere((req) => req.id == leaveId);
      notifyListeners();
      await fetchPendingLeaveRequests(); // Refresh in background
      return "Leave request rejected successfully";
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn(int staffId) async {
    debugPrint("DEBUG: AttendanceProvider.checkIn starting for staffId: $staffId");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _todayAttendance = await _service.checkIn(staffId);
      debugPrint("DEBUG: AttendanceProvider.checkIn success: ${_todayAttendance?.id}");
      notifyListeners();
      return true;
    } on DioException catch (e) {
      debugPrint("DEBUG: AttendanceProvider.checkIn error (DioException): $e");
      _errorMessage = ApiClient.handleDioError(e);
      return false;
    } catch (e) {
      debugPrint("DEBUG: AttendanceProvider.checkIn error: $e");
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkOut(int staffId) async {
    debugPrint("DEBUG: AttendanceProvider.checkOut starting for staffId: $staffId");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _todayAttendance = await _service.checkOut(staffId);
      debugPrint("DEBUG: AttendanceProvider.checkOut success: ${_todayAttendance?.id}");
      notifyListeners();
      return true;
    } on DioException catch (e) {
      debugPrint("DEBUG: AttendanceProvider.checkOut error (DioException): $e");
      _errorMessage = ApiClient.handleDioError(e);
      return false;
    } catch (e) {
      debugPrint("DEBUG: AttendanceProvider.checkOut error: $e");
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyLeave({
    required int staffId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    debugPrint("DEBUG: AttendanceProvider.applyLeave starting for staffId: $staffId");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.applyLeave(
        staffId: staffId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      debugPrint("DEBUG: AttendanceProvider.applyLeave success");
      return true;
    } on DioException catch (e) {
      debugPrint("DEBUG: AttendanceProvider.applyLeave error (DioException): $e");
      _errorMessage = ApiClient.handleDioError(e);
      return false;
    } catch (e) {
      debugPrint("DEBUG: AttendanceProvider.applyLeave error: $e");
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<StaffAttendance> _attendanceHistory = [];
  List<StaffAttendance> get attendanceHistory => _attendanceHistory;

  List<StaffAttendance> _monthlyAttendance = [];
  List<StaffAttendance> get monthlyAttendance => _monthlyAttendance;

  List<LeaveRequestModel> _staffLeaveRequests = [];
  List<LeaveRequestModel> get staffLeaveRequests => _staffLeaveRequests;

  Future<void> fetchAttendanceHistory({int? staffId, int page = 0}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getStaffAttendanceHistory(
        staffId: staffId,
        page: page,
      );
      _attendanceHistory = response.content;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyAttendance({required int staffId, required int month}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getMonthlyAttendance(
        staffId: staffId,
        month: month,
      );
      _monthlyAttendance = response.content;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _leaveCurrentPage = 0;
  int _leaveTotalPages = 1;

  int get leaveCurrentPage => _leaveCurrentPage;
  int get leaveTotalPages => _leaveTotalPages;

  Future<void> fetchStaffLeaveRequests({required int staffId, String? status, int page = 0}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.fetchLeaveRequests(staffId: staffId, status: status, page: page);
      _staffLeaveRequests = response.content;
      _leaveCurrentPage = page;
      _leaveTotalPages = response.totalPages;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
