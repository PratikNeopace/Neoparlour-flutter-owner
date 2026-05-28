import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/inventory_model.dart';

class InventoryService {
  final ApiClient _apiClient = ApiClient();

  // Helper method to extract meaningful error messages using central ApiClient logic
  Exception _handleError(DioException e) {
    return Exception(ApiClient.handleDioError(e));
  }


  Future<InventoryResponse> createInventory(InventoryRequest request) async {
    try {
      final response = await _apiClient.post(
        'inventory',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return InventoryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to create inventory');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryResponse> updateInventory(
      int id, InventoryRequest request) async {
    try {
      final response = await _apiClient.put(
        'inventory/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return InventoryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update inventory');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryResponse> getInventoryById(int id) async {
    try {
      final response = await _apiClient.get('inventory/$id');
      if (response.statusCode == 200) {
        return InventoryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch inventory item');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InventoryResponse>> getAllInventory() async {
    try {
      final response = await _apiClient.get('inventory');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => InventoryResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch inventory');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InventoryResponse>> getInventoryByCategory(
      String category) async {
    try {
      final response = await _apiClient.get('inventory/category/$category');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => InventoryResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch inventory by category');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InventoryResponse>> getLowStockItems() async {
    try {
      final response = await _apiClient.get('inventory/low-stock');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => InventoryResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch low stock items');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteInventory(int id) async {
    try {
      final response = await _apiClient.delete('inventory/$id');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete inventory item');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryResponse> updateStock(int id, int stock) async {
    try {
      final response = await _apiClient.put(
        'inventory/$id/stock',
        queryParameters: {'stock': stock},
      );
      if (response.statusCode == 200) {
        return InventoryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update stock');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<StaffInventoryResponse> assignInventoryToStaff(
      StaffInventoryRequest request) async {
    try {
      final response = await _apiClient.post(
        'staff-inventory/assign',
        data: request.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return StaffInventoryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to assign inventory to staff');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StaffInventoryResponse>> getStaffInventoryByInventoryId(
      int inventoryId) async {
    try {
      final response =
          await _apiClient.get('staff-inventory/inventory/$inventoryId');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => StaffInventoryResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch staff inventory assignments');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StaffInventoryResponse>> getStaffInventoryByStaffId(
      int staffId) async {
    try {
      final response = await _apiClient.get('staff-inventory/staff/$staffId');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => StaffInventoryResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch my inventory assignments');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<StaffInventoryResponse> reassignStaffInventory(int assignmentId,
      double usedQuantity, double newAllocatedQuantity, String notes) async {
    try {
      final response = await _apiClient.put(
        'staff-inventory/$assignmentId/reassign',
        queryParameters: {'quantity': usedQuantity},
        data: {
          'newAllocatedQuantity': newAllocatedQuantity,
          'notes': notes,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StaffInventoryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to reassign inventory');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> requestInventorySwap({
    required int fromStaffInventoryId,
    required int toStaffId,
    required double quantity,
    required String notes,
  }) async {
    try {
      final response = await _apiClient.post(
        'staff-inventory/request',
        queryParameters: {
          'fromStaffInventoryId': fromStaffInventoryId,
          'toStaffId': toStaffId,
          'quantity': quantity,
          'notes': notes,
        },
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to request inventory swap');
      }
      final rawData = response.data?.toString() ?? "Swap request submitted";
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map && (decoded.containsKey('message') || decoded.containsKey('msg'))) {
          return (decoded['message'] ?? decoded['msg']).toString();
        }
      } catch (_) {}
      return rawData;
    } on DioException catch (e) {
      if (e.response != null && (e.response!.statusCode == 200 || e.response!.statusCode == 201)) {
        return e.response!.data?.toString() ?? "Swap request submitted";
      }
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }


  Future<List<InventorySwapRequestModel>> getPendingSwapRequests() async {
    try {
      final response = await _apiClient.get('staff-inventory/search?status=PENDING');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => InventorySwapRequestModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch pending swap requests');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> approveSwapRequest(int id) async {
    try {
      final response = await _apiClient.post(
        'staff-inventory/$id/approve',
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204 && response.statusCode != 202) {
        throw Exception('Failed to approve request');
      }
      final rawData = response.data?.toString() ?? "Swap approved successfully";
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map && (decoded.containsKey('message') || decoded.containsKey('msg'))) {
          return (decoded['message'] ?? decoded['msg']).toString();
        }
      } catch (_) {}
      return rawData;
    } on DioException catch (e) {
      if (e.response != null && (e.response!.statusCode == 200 || e.response!.statusCode == 201 || e.response!.statusCode == 204 || e.response!.statusCode == 202)) {
        return e.response!.data?.toString() ?? "Swap approved successfully";
      }
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> rejectSwapRequest(int id) async {
    try {
      final response = await _apiClient.post(
        'staff-inventory/$id/reject',
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204 && response.statusCode != 202) {
        throw Exception('Failed to reject request');
      }
      final rawData = response.data?.toString() ?? "Swap rejected";
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map && (decoded.containsKey('message') || decoded.containsKey('msg'))) {
          return (decoded['message'] ?? decoded['msg']).toString();
        }
      } catch (_) {}
      return rawData;
    } on DioException catch (e) {
      if (e.response != null && (e.response!.statusCode == 200 || e.response!.statusCode == 201 || e.response!.statusCode == 204 || e.response!.statusCode == 202)) {
        return e.response!.data?.toString() ?? "Swap rejected";
      }
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StaffOpenInventoryResponse>> getOpenedStaffInventory(int staffId) async {
    try {
      final response = await _apiClient.get('staff-inventory/opened/$staffId');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => StaffOpenInventoryResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch opened staff inventory');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }
  Future<StaffOpenInventoryResponse> openProduct(int staffInventoryId, double openQuantity, String? notes) async {
    try {
      final response = await _apiClient.post(
        'staff-inventory/$staffInventoryId/open',
        queryParameters: {
          'openQuantity': openQuantity,
          if (notes != null) 'notes': notes,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return StaffOpenInventoryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to open product');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StaffOpenInventoryResponse>> getOpenedProductsCounts(int staffInventoryId) async {
    try {
      final response = await _apiClient.get('staff-inventory/$staffInventoryId/opened-products-counts');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => StaffOpenInventoryResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch opened products counts');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }
}
