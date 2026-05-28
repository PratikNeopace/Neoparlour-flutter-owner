import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';

class SubscriptionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getPlans() async {
    try {
      final response = await _apiClient.get('subscriptions/plans');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to fetch plans: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<dynamic>> getSalonSubscriptions(int salonId) async {
    try {
      final response = await _apiClient.get('subscriptions/salon/$salonId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to fetch subscriptions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> createOrder({required String planCode, required int userId, String? couponCode}) async {
    try {
      final Map<String, dynamic> queryParameters = {'planCode': planCode, 'userId': userId};
      if (couponCode != null && couponCode.isNotEmpty) {
        queryParameters['couponCode'] = couponCode;
      }
      final response = await _apiClient.post(
        'subscriptions/create-order',
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int userId,
  }) async {
    try {
      final response = await _apiClient.post(
        'subscriptions/verify-payment',
        queryParameters: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
          'userId': userId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to verify payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
