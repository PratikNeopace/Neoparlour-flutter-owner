import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/staff_model.dart';
import 'package:neo_parlour_owner/data/services/staff_service.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class StaffProvider extends ChangeNotifier {
  final StaffService _service = StaffService();

  List<Staff> _staffMembers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Staff> get staffMembers => _staffMembers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Staff? _editingStaff;
  Staff? get editingStaff => _editingStaff;

  void selectStaffForEdit(Staff staff) {
    _editingStaff = staff;
    notifyListeners();
  }

  void clearEditingStaff() {
    _editingStaff = null;
    notifyListeners();
  }

  void clearSelection() {
    // According to instructions, set selected staff null and hasUserSelected false.
    // However, since GuestBookingState handles selectedStaff, this might be a placeholder for future use or to clear selection states.
    notifyListeners();
  }

  Future<void> addStaff(Staff staff) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.addStaff(staff);
      await fetchStaff(); 
    } on DioException catch (e) {
      _errorMessage = ApiClient.handleDioError(e);
      rethrow;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStaff() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _staffMembers = await _service.fetchStaff();
    } on DioException catch (e) {
      _errorMessage = ApiClient.handleDioError(e);
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableStaff({required String selectedTime, required int durationMinutes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _staffMembers = await _service.getAvailableStaff(selectedTime: selectedTime, durationMinutes: durationMinutes);
    } on DioException catch (e) {
      _errorMessage = ApiClient.handleDioError(e);
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStaff(Staff staff) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateStaff(staff);
      await fetchStaff(); // Automatically refresh list
    } on DioException catch (e) {
      _errorMessage = ApiClient.handleDioError(e);
      rethrow;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> toggleStaffStatus(Staff staff, bool active) async {
    final id = staff.id;
    if (id == null) return "Error: Staff ID missing";
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Optimistic Update
    bool found = false;
    _staffMembers = _staffMembers.map((s) {
      if (s.id == id) {
        found = true;
        return s.copyWith(active: active);
      }
      return s;
    }).toList();

    if (found) {
      notifyListeners();
    }
 
    try {
      await _service.toggleStaffStatus(id, active);
      return "Staff is ${active ? 'active' : 'inactive'}";
    } on DioException catch (e) {
      // Revert on failure
      _staffMembers = _staffMembers.map((s) {
        if (s.id == id) {
          return s.copyWith(active: !active);
        }
        return s;
      }).toList();
      _errorMessage = ApiClient.handleDioError(e);
      rethrow;
    } catch (e) {
      // Revert on failure
      _staffMembers = _staffMembers.map((s) {
        if (s.id == id) {
          return s.copyWith(active: !active);
        }
        return s;
      }).toList();
      _errorMessage = ErrorHandler.parseError(e);
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
