import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/service_model.dart';

class ServiceService {
  final ApiClient _apiClient = ApiClient();

  Future<NeoService> addService(NeoService service) async {
    try {
      final response = await _apiClient.post(
        'services',
        data: service.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NeoService.fromJson(response.data);
      } else {
        throw Exception('Failed to add service: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<NeoService>> fetchServices() async {
    try {
      final response = await _apiClient.get('services');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => NeoService.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch services');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reorderServices(List<String> serviceIds) async {
    try {
      final response = await _apiClient.put(
        'services/reorder',
        data: serviceIds,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to reorder services');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NeoService>> fetchActiveServices() async {
    try {
      final response = await _apiClient.get('services/active');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => NeoService.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch active services');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<NeoService> updateService(NeoService service) async {
    try {
      final response = await _apiClient.put(
        'services/${service.id}',
        data: service.toJson(),
      );

      if (response.statusCode == 200) {
        return NeoService.fromJson(response.data);
      } else {
        throw Exception('Failed to update service');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteService(int id) async {
    try {
      final response = await _apiClient.put(
        'services/$id/toggle',
        queryParameters: {'active': false},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to deactivate service');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleServiceStatus(int id, bool active) async {
    try {
      final response = await _apiClient.put(
        'services/$id/toggle',
        queryParameters: {'active': active},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update service status');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getCommonServicesNames() async {
    try {
      final response = await _apiClient.get('services/commonServices');
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else {
        throw Exception('Failed to fetch common services');
      }
    } catch (e) {
      rethrow;
    }
  }
}
