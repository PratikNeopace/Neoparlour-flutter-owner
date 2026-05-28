import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/feedback_model.dart';
import 'package:neo_parlour_owner/data/services/feedback_service.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackService _service = FeedbackService();

  List<FeedbackModel> _feedbacks = [];
  double _averageRating = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  List<FeedbackModel> get feedbacks => _feedbacks;
  double get averageRating => _averageRating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFeedbackForStaff(int staffId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getFeedbackByStaff(staffId),
        _service.getAverageStaffRating(staffId),
      ]);
      
      _feedbacks = results[0] as List<FeedbackModel>;
      _averageRating = results[1] as double;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPendingFeedback() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _feedbacks = await _service.getPendingFeedback();
      _feedbacks.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchApprovedFeedback() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _feedbacks = await _service.getApprovedFeedback();
      _feedbacks.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveFeedback(int feedbackId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.approveFeedback(feedbackId);
      // Remove from list after approval
      _feedbacks.removeWhere((f) => f.id == feedbackId);
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectFeedback(int feedbackId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.rejectFeedback(feedbackId);
      // Remove from list after rejection
      _feedbacks.removeWhere((f) => f.id == feedbackId);
    } catch (e) {
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
