import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/feedback_model.dart';

class FeedbackService {
  final ApiClient _apiClient = ApiClient();

  Future<List<FeedbackModel>> getFeedbackByStaff(int staffId) async {
    try {
      final response = await _apiClient.get('feedback/staff/$staffId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FeedbackModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch staff feedback: $e');
    }
  }

  Future<double> getAverageStaffRating(int staffId) async {
    try {
      final response = await _apiClient.get('feedback/staff/$staffId/average');
      if (response.statusCode == 200) {
        return (response.data as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      throw Exception('Failed to fetch average rating: $e');
    }
  }

  Future<FeedbackModel> submitFeedback(FeedbackModel feedback) async {
    try {
      final response = await _apiClient.post(
        'feedback',
        data: feedback.toJson(),
      );
      if (response.statusCode == 201) {
        return FeedbackModel.fromJson(response.data);
      }
      throw Exception('Failed to submit feedback');
    } catch (e) {
      throw Exception('Error submitting feedback: $e');
    }
  }

  Future<List<FeedbackModel>> getPendingFeedback() async {
    try {
      final response = await _apiClient.get('feedback/pending');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FeedbackModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch pending feedback: $e');
    }
  }

  Future<void> approveFeedback(int feedbackId) async {
    try {
      final response = await _apiClient.put('feedback/$feedbackId/approve');
      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        throw Exception('Failed to approve feedback');
      }
    } catch (e) {
      throw Exception('Error approving feedback: $e');
    }
  }

  Future<void> rejectFeedback(int feedbackId) async {
    try {
      final response = await _apiClient.delete('feedback/$feedbackId/reject');
      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        throw Exception('Failed to reject feedback');
      }
    } catch (e) {
      throw Exception('Error rejecting feedback: $e');
    }
  }
  Future<List<FeedbackModel>> getApprovedFeedback() async {
    try {
      final response = await _apiClient.get('feedback/approved');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FeedbackModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch approved feedback: $e');
    }
  }
}
