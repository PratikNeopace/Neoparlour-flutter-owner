import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/inventory_model.dart';
import 'package:neo_parlour_owner/data/services/inventory_service.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _service = InventoryService();

  List<InventoryResponse> _inventoryItems = [];
  List<StaffInventoryResponse> _staffAssignments = [];
  List<StaffInventoryResponse> _staffOwnInventory = [];
  List<InventorySwapRequestModel> _pendingSwapRequests = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAssignmentsLoading = false;
  int _currentPage = 0;
  int _totalPages = 0;

  List<InventoryResponse> get inventoryItems => _inventoryItems;
  List<StaffInventoryResponse> get staffAssignments => _staffAssignments;
  List<StaffInventoryResponse> get staffOwnInventory => _staffOwnInventory;
  List<InventorySwapRequestModel> get pendingSwapRequests => _pendingSwapRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAssignmentsLoading => _isAssignmentsLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;


  Future<void> fetchStaffAssignments(int inventoryId) async {
    _isAssignmentsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _staffAssignments = await _service.getStaffInventoryByInventoryId(inventoryId);
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isAssignmentsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStaffOwnInventory(int staffId) async {
    _isAssignmentsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _staffOwnInventory = await _service.getStaffInventoryByStaffId(staffId);
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isAssignmentsLoading = false;
      notifyListeners();
    }
  }

  Future<List<StaffOpenInventoryResponse>> fetchOpenedStaffInventory(int staffId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _service.getOpenedStaffInventory(staffId);
      return items;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInventory({int page = 0, int size = 15}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _inventoryItems = await _service.getAllInventory();
      _totalPages = (_inventoryItems.length / size).ceil();
      _currentPage = page;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addInventory(InventoryRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newItem = await _service.createInventory(request);
      _inventoryItems.add(newItem);
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInventory(int id, InventoryRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedItem = await _service.updateInventory(id, request);
      final index = _inventoryItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _inventoryItems[index] = updatedItem;
      }
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInventory(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteInventory(id);
      _inventoryItems.removeWhere((item) => item.id == id);
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStock(int id, int stock) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedItem = await _service.updateStock(id, stock);
      final index = _inventoryItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _inventoryItems[index] = updatedItem;
      }
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignInventory(StaffInventoryRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.assignInventoryToStaff(request);

      final index = _inventoryItems.indexWhere((item) => item.id == request.inventoryId);
      if (index != -1) {
        final oldItem = _inventoryItems[index];

        // Subtract allocated quantity from current stock to get new salon stock
        final newStock = (oldItem.currentStock - request.allocatedQuantity).toInt();

        _inventoryItems[index] = oldItem.copyWith(currentStock: newStock);
      }
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reassignInventory(
      int assignmentId, int inventoryId, double usedQuantity, double newAllocatedQuantity, String notes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.reassignStaffInventory(assignmentId, usedQuantity, newAllocatedQuantity, notes);
      await fetchStaffAssignments(inventoryId); // Refresh assignments list
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestInventorySwap({
    required int fromStaffInventoryId,
    required int toStaffId,
    required double quantity,
    required String notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.requestInventorySwap(
        fromStaffInventoryId: fromStaffInventoryId,
        toStaffId: toStaffId,
        quantity: quantity,
        notes: notes,
      );
      // Wait to fetch the updated state, we assume the server updates it
      await fetchStaffOwnInventory(toStaffId); // Optional: reload data
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPendingSwapRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pendingSwapRequests = await _service.getPendingSwapRequests();
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> approveSwapRequest(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final msg = await _service.approveSwapRequest(id);
      _pendingSwapRequests.removeWhere((req) => req.id == id);
      notifyListeners();
      await fetchPendingSwapRequests(); // Refresh in background
      return msg;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> rejectSwapRequest(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final msg = await _service.rejectSwapRequest(id);
      _pendingSwapRequests.removeWhere((req) => req.id == id);
      notifyListeners();
      await fetchPendingSwapRequests(); // Refresh in background
      return msg;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> openProduct(int staffInventoryId, double openQuantity, String? notes, int staffId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.openProduct(staffInventoryId, openQuantity, notes);
      await fetchStaffOwnInventory(staffId); // Refresh list
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<StaffOpenInventoryResponse>> fetchOpenedProductsCounts(int staffInventoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _service.getOpenedProductsCounts(staffInventoryId);
      return items;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      return [];
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
