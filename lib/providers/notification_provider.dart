import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/notification_model.dart';
import 'package:neo_parlour_owner/data/services/notification_service.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _hasMore = true;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  List<NotificationModel> _birthdays = [];
  bool _isBirthdaysLoading = false;
  String? _birthdaysErrorMessage;
  int _birthdaysCurrentPage = 0;
  int _birthdaysTotalPages = 0;

  List<NotificationModel> get birthdays => _birthdays;
  bool get isBirthdaysLoading => _isBirthdaysLoading;
  String? get birthdaysErrorMessage => _birthdaysErrorMessage;
  int get birthdaysCurrentPage => _birthdaysCurrentPage;
  int get birthdaysTotalPages => _birthdaysTotalPages;

  Future<void> fetchNotifications({
    required int salonId,
    bool refresh = false,
    String? status,
    int size = 10,
  }) async {
    if (refresh) {
      _currentPage = 0;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _notificationService.fetchNotifications(
        salonId: salonId,
        status: status,
        page: _currentPage,
        size: size,
      );

      _notifications = result.content;
      _totalPages = result.totalPages;
      _currentPage = result.number;
      _hasMore = !_hasMore;
      
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> goToPage({
    required int page,
    required int salonId,
    String? status,
    int size = 10,
  }) async {
    _currentPage = page;
    await fetchNotifications(salonId: salonId, status: status, size: size);
  }

  Future<void> fetchBirthdays({
    required int salonId,
    bool refresh = false,
    int size = 10,
  }) async {
    if (refresh) {
      _birthdaysCurrentPage = 0;
    }

    _isBirthdaysLoading = true;
    _birthdaysErrorMessage = null;
    notifyListeners();

    try {
      final result = await _notificationService.fetchNotifications(
        salonId: salonId,
        type: 'BIRTHDAY',
        page: _birthdaysCurrentPage,
        size: size,
      );

      _birthdays = result.content;
      _birthdaysTotalPages = result.totalPages;
      _birthdaysCurrentPage = result.number;
      
    } catch (e) {
      _birthdaysErrorMessage = ErrorHandler.parseError(e);
    } finally {
      _isBirthdaysLoading = false;
      notifyListeners();
    }
  }

  Future<void> goToBirthdaysPage({
    required int page,
    required int salonId,
    int size = 10,
  }) async {
    _birthdaysCurrentPage = page;
    await fetchBirthdays(salonId: salonId, size: size);
  }

  void clearNotifications() {
    _notifications = [];
    _currentPage = 0;
    _totalPages = 0;
    _hasMore = true;
    
    _birthdays = [];
    _birthdaysCurrentPage = 0;
    _birthdaysTotalPages = 0;
    notifyListeners();
  }
}
