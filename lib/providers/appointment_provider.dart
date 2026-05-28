import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/core/utils/date_time_utils.dart';
import 'package:neo_parlour_owner/data/models/appointment_response.dart';
import 'package:neo_parlour_owner/data/services/appointment_service.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  List<Appointment> _appointments = [];
  List<Appointment> _analyticsAppointments = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _errorMessage;
  
  int _currentPage = 0;
  int _totalPages = 0;
  bool _hasMore = true;

  List<Appointment> get appointments => _appointments;
  List<Appointment> get analyticsAppointments => _analyticsAppointments;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // Staff Appointments (for AppointmentStaffScreen)
  List<Appointment> _staffAppointments = [];
  int _staffCurrentPage = 0;
  int _staffTotalPages = 0;

  List<Appointment> get staffAppointments => _staffAppointments;
  int get staffCurrentPage => _staffCurrentPage;
  int get staffTotalPages => _staffTotalPages;

  // Getters for analytics counts
  int get totalClientsCount => _analyticsAppointments.map((a) => a.userId).toSet().length;
  int get totalServicesCount => _analyticsAppointments.expand((a) => a.serviceNames).toSet().length;
  int get employeesCount => _analyticsAppointments.map((a) => a.staffName).toSet().length;
  int get totalAppointmentsCount => _analyticsAppointments.length;

  Future<void> fetchUpcomingAppointments({
    int? salonId,
    int? staffId,
    String? status = 'booked',
    int size = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();
 
    try {
      final fromDate = DateTimeUtils.nowIstIsoString();

      final response = await _service.fetchAppointments(
        salonId: salonId,
        staffId: staffId,
        status: status,
        fromDate: fromDate,
        page: _currentPage,
        size: size,
      );
      
      _appointments = response.content;
      _totalPages = response.totalPages;
      _hasMore = _currentPage < _totalPages - 1;
      
      _appointments.sort((a, b) => a.appointmentAt.compareTo(b.appointmentAt));
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreUpcomingAppointments({
    int? salonId,
    int? staffId,
    String? status = 'booked',
    int size = 10,
  }) async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final fromDate = DateTimeUtils.nowIstIsoString();

      final response = await _service.fetchAppointments(
        salonId: salonId,
        staffId: staffId,
        status: status,
        fromDate: fromDate,
        page: _currentPage,
        size: size,
      );

      _appointments.addAll(response.content);
      _totalPages = response.totalPages;
      _hasMore = _currentPage < _totalPages - 1;
      
      // Keep overall list sorted if needed, though append usually works for time-ordered data
      _appointments.sort((a, b) => a.appointmentAt.compareTo(b.appointmentAt));
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      _currentPage--; // Revert on failure
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnalyticsData({
    int? salonId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch a large page of appointments to calculate stats
      final response = await _service.fetchAppointments(
        salonId: salonId,
        size: 100, // Fetch more for analytics
      );
      _analyticsAppointments = response.content;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  Future<void> goToPage({
    required int page,
    int? salonId,
    int? staffId,
    String? status = 'booked',
    int size = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fromDate = DateTimeUtils.nowIstIsoString();
      final response = await _service.fetchAppointments(
        salonId: salonId,
        staffId: staffId,
        status: status,
        fromDate: fromDate,
        page: page,
        size: size,
      );

      _appointments = response.content;
      _currentPage = response.number;
      _totalPages = response.totalPages;
      _hasMore = _currentPage < _totalPages - 1;
      
      _appointments.sort((a, b) => a.appointmentAt.compareTo(b.appointmentAt));
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rescheduleAppointment({
    required int appointmentId,
    required DateTime newDateTime,
    required String reason,
    required int salonId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTimeIso = DateTimeUtils.toIstIsoString(newDateTime);
      await _service.rescheduleAppointment(appointmentId, newTimeIso, reason);
      
      void updateLocalList(List<Appointment> list) {
        final index = list.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          list[index] = list[index].copyWith(
            appointmentAt: newDateTime,
            status: 'RESCHEDULED',
          );
        }
      }

      updateLocalList(_appointments);
      updateLocalList(_scheduleAppointments);
      updateLocalList(_staffAppointments);
      updateLocalList(_historyAppointments);
      
      _appointments.sort((a, b) => a.appointmentAt.compareTo(b.appointmentAt));
      _scheduleAppointments.sort((a, b) => a.appointmentAt.compareTo(b.appointmentAt));
      _staffAppointments.sort((a, b) => b.appointmentAt.compareTo(a.appointmentAt));

      // Refresh data after successful reschedule
      await fetchAnalyticsData(salonId: salonId);
      await fetchUpcomingAppointments(salonId: salonId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelAppointment({
    required int appointmentId,
    required String reason,
    required int salonId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint("DEBUG: cancelAppointment started. appointmentId: $appointmentId");
      await _service.cancelAppointment(appointmentId, reason);
      
      void updateLocalList(List<Appointment> list) {
        final index = list.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          list[index] = list[index].copyWith(
            status: 'CANCELLED',
          );
        }
      }

      updateLocalList(_appointments);
      updateLocalList(_scheduleAppointments);
      updateLocalList(_staffAppointments);
      updateLocalList(_historyAppointments);

      // Refresh data
      await fetchAnalyticsData(salonId: salonId);
      await fetchUpcomingAppointments(salonId: salonId);
    } catch (e) {
      debugPrint("DEBUG: Error canceling appointment: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Appointment> _scheduleAppointments = [];
  int _scheduleCurrentPage = 0;
  int _scheduleTotalPages = 0;

  List<Appointment> get scheduleAppointments => _scheduleAppointments;
  int get scheduleCurrentPage => _scheduleCurrentPage;
  int get scheduleTotalPages => _scheduleTotalPages;

  Future<void> fetchSchedule({
    int? salonId,
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.fetchAppointments(
        salonId: salonId,
        status: status,
        page: page,
        size: size,
      );
      _scheduleAppointments = response.content;
      _scheduleCurrentPage = response.number;
      _scheduleTotalPages = response.totalPages;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchStaffAppointments({
    int? staffId,
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.fetchAppointments(
        staffId: staffId,
        status: status,
        page: page,
        size: size,
        sort: 'appointmentAt,desc',
      );
      _staffAppointments = response.content;
      _staffCurrentPage = response.number;
      _staffTotalPages = response.totalPages;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> staffGoToPage({
    required int page,
    int? staffId,
    String? status,
    int size = 10,
  }) async {
    await fetchStaffAppointments(
      staffId: staffId,
      status: status,
      page: page,
      size: size,
    );
  }

  List<Appointment> _historyAppointments = [];
  int _historyCurrentPage = 0;
  int _historyTotalPages = 0;

  List<Appointment> get historyAppointments => _historyAppointments;
  int get historyCurrentPage => _historyCurrentPage;
  int get historyTotalPages => _historyTotalPages;

  Future<void> fetchHistory(int userId, {int page = 0, int size = 15}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use advanced search with salonId and maybe userId if possible
      // But based on Service, fetchUserHistory is separate.
      // If fetchUserHistory is NOT paginated on backend, we can't do much without backend change.
      // However, the user asked for page numbers "on every screen".
      // I'll update fetchHistory to at least support the structure.
      
      // If we assume history might also become paginated or we want to show the UI:
      final history = await _service.fetchUserHistory(userId);
      _historyAppointments = history;
      _historyTotalPages = (history.length / size).ceil();
      _historyCurrentPage = page;
      
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignStaffToAppointment({
    required int appointmentId,
    required int newStaffId,
    required String newStaffName,
    required int? salonId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> requestData = {
        'staffId': newStaffId,
        'staffName': newStaffName,
      };

      await _service.assignStaff(appointmentId, requestData);
      
      void updateLocalList(List<Appointment> list) {
        final index = list.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          list[index] = list[index].copyWith(
            staffId: newStaffId,
            staffName: newStaffName,
          );
        }
      }

      updateLocalList(_appointments);
      updateLocalList(_scheduleAppointments);
      updateLocalList(_staffAppointments);
      updateLocalList(_historyAppointments);

      // Refresh data
      await fetchAnalyticsData(salonId: salonId);
      await fetchUpcomingAppointments(salonId: salonId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

   Future<void> completeAppointment({
    required int appointmentId,
    required Appointment appointment,
    List<Map<String, dynamic>>? openedProductUsages,
    int? salonId,
    int? staffId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.completeAppointment(appointmentId, appointment, openedProductUsages);
      
      // Refresh data
      if (salonId != null) {
        await fetchAnalyticsData(salonId: salonId);
      }
      // Refresh data with status: null to ensure the completed appointment is still fetched 
      // if the UI wants to show it with the new status
      await fetchUpcomingAppointments(salonId: salonId, staffId: staffId, status: null);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }
}
