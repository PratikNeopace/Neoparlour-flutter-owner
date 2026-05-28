import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/order_model.dart';

class OrderPaginatedResponse {
  final List<OrderModel> content;
  final bool last;
  final int totalElements;
  final int totalPages;
  final int number;

  OrderPaginatedResponse({
    required this.content,
    required this.last,
    required this.totalElements,
    required this.totalPages,
    required this.number,
  });

  factory OrderPaginatedResponse.fromJson(Map<String, dynamic> json) {
    final pageInfo = json['page'] ?? {};
    int pageNum = pageInfo['number'] ?? json['number'] ?? 0;
    int totalPages = pageInfo['totalPages'] ?? json['totalPages'] ?? 0;
    
    return OrderPaginatedResponse(
      content: (json['content'] as List?)
          ?.map((i) => OrderModel.fromJson(i))
          .toList() ?? [],
      last: totalPages == 0 ? true : pageNum >= totalPages - 1,
      totalElements: pageInfo['totalElements'] ?? json['totalElements'] ?? 0,
      totalPages: totalPages,
      number: pageNum,
    );
  }
}

class OrderService {
  final ApiClient _apiClient = ApiClient();

  Future<OrderPaginatedResponse> fetchOrders({
    required int salonId,
    int page = 0,
    int size = 10,
    String? mobile,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'salonId': salonId,
        'page': page,
        'size': size,
        'sort': 'createdAt,desc',
      };

      if (mobile != null && mobile.isNotEmpty) {
        queryParams['mobile'] = mobile;
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        'orders/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return OrderPaginatedResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch orders');
      }
    } on DioException catch (e) {
      final message = ApiClient.handleDioError(e);
      throw Exception('API Error: $message');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> updateOrderStatus(int id, String status) async {
    try {
      final response = await _apiClient.put(
        'orders/$id/status',
        queryParameters: {'status': status},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      rethrow;
    }
  }
}
