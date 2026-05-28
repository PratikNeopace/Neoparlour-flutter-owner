import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/package_model.dart';

class PackagePaginatedResponse {
  final List<ServicePackage> content;
  final bool last;
  final int totalElements;
  final int totalPages;
  final int number;

  PackagePaginatedResponse({
    required this.content,
    required this.last,
    required this.totalElements,
    required this.totalPages,
    required this.number,
  });

  factory PackagePaginatedResponse.fromJson(Map<String, dynamic> json) {
    final pageInfo = json['page'] ?? {};
    int pageNum = pageInfo['number'] ?? json['number'] ?? 0;
    int totalPages = pageInfo['totalPages'] ?? json['totalPages'] ?? 0;
    
    return PackagePaginatedResponse(
      content: (json['content'] as List?)
          ?.map((i) => ServicePackage.fromJson(i))
          .toList() ?? [],
      last: totalPages == 0 ? true : pageNum >= totalPages - 1,
      totalElements: pageInfo['totalElements'] ?? json['totalElements'] ?? 0,
      totalPages: totalPages,
      number: pageNum,
    );
  }
}

class PackageService {
  final ApiClient _apiClient = ApiClient();

  Future<ServicePackage> addPackage(ServicePackage package) async {
    try {
      final response = await _apiClient.post(
        'packages',
        data: package.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          return ServicePackage.fromJson(data[0]);
        }
        return ServicePackage.fromJson(data);
      } else {
        throw Exception('Failed to add package: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = ApiClient.handleDioError(e);
      throw Exception('API Error: $message');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<PackagePaginatedResponse> fetchPackages({
    int page = 0,
    int size = 10,
    String? keyword,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      final response = await _apiClient.get(
        'packages/search',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return PackagePaginatedResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch packages');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ServicePackage> updatePackage(ServicePackage package) async {
    try {
      final response = await _apiClient.put(
        'packages/${package.id}',
        data: package.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          return ServicePackage.fromJson(data[0]);
        }
        return ServicePackage.fromJson(data);
      } else {
        throw Exception('Failed to update package');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePackage(int id) async {
    try {
      final response = await _apiClient.delete('packages/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete package');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> togglePackageStatus(int id, bool active) async {
    try {
      final response = await _apiClient.put(
        'packages/$id/toggle',
        queryParameters: {'active': active},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update package status');
      }
    } catch (e) {
      rethrow;
    }
  }
}
