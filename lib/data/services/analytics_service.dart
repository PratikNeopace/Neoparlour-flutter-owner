import 'package:intl/intl.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/revenue_model.dart';

class AnalyticsService {
  final ApiClient _apiClient = ApiClient();

  Future<List<RevenuePointDTO>> getRevenueGraph(
    String viewType, {
    int? salonId,
    DateTime? fromDate,
    DateTime? toDate,
    int? staffId,
    int? offerId,
    bool? onlyOffers,
  }) async {
    try {
      final queryParams = {
        'viewType': viewType,
        'salonId': ?salonId,
        'fromDate': ?(fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : null),
        'toDate': ?(toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : null),
        'staffId': ?staffId?.toString(),
        'offerId': ?offerId?.toString(),
        'onlyOffers': ?onlyOffers?.toString(),
      };

      final response = await _apiClient.get(
        'appointments/revenue/graph',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => RevenuePointDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch revenue graph data');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getTotalRevenue({
    DateTime? fromDate,
    int? salonId,
    DateTime? toDate,
    int? staffId,
    int? offerId,
    bool? onlyOffers,
  }) async {
    try {
      final queryParams = {
        'fromDate': ?(fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : null),
        'toDate': ?(toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : null),
        'salonId': ?salonId,
        'staffId': ?staffId?.toString(),
        'offerId': ?offerId?.toString(),
        'onlyOffers': ?onlyOffers?.toString(),
      };

      final response = await _apiClient.get(
        'appointments/revenue/total',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return (response.data as num).toDouble();
      } else {
        throw Exception('Failed to fetch total revenue');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getStaffAppointmentsBulk({
    String? viewType,
    DateTime? fromDate,
    DateTime? toDate,
    int? salonId,
  }) async {
    try {
      final queryParams = {
        'viewType': ?viewType,
        'fromDate': ?(fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : null),
        'toDate': ?(toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : null),
        'salonId': ?salonId,
      };

      final response = await _apiClient.get(
        'revenue/staff-appointments',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to fetch staff appointments');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getStaffRevenueBulk({
    String? viewType,
    DateTime? fromDate,
    DateTime? toDate,
    int? salonId,
  }) async {
    try {
      final queryParams = {
        'viewType': ?viewType,
        'fromDate': ?(fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : null),
        'toDate': ?(toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : null),
        'salonId': ?salonId,
      };

      final response = await _apiClient.get(
        'revenue/staff-revenue',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to fetch staff revenue');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DashboardResponse> getDashboardData({
    required String viewType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = {
        'viewType': viewType,
        'fromDate': ?(fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate) : null),
        'toDate': ?(toDate != null ? DateFormat('yyyy-MM-dd').format(toDate) : null),
      };

      final response = await _apiClient.get(
        'revenue/dashboard',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return DashboardResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch dashboard data');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OfferUsageLimit>> getOfferUsageLimits() async {
    try {
      final response = await _apiClient.get('revenue/offer-usage-limits');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => OfferUsageLimit.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch offer usage limits');
      }
    } catch (e) {
      rethrow;
    }
  }
}
