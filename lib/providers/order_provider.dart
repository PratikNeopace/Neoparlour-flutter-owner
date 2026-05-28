import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/order_model.dart';
import 'package:neo_parlour_owner/data/services/order_service.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _hasMore = true;
  String _mobileQuery = '';
  String _selectedStatus = 'all';

  List<OrderModel> get orders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get mobileQuery => _mobileQuery;
  String get selectedStatus => _selectedStatus;

  Future<void> fetchOrders({
    required int salonId,
    bool refresh = false,
    int size = 10,
  }) async {
    if (refresh) {
      _currentPage = 0;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _orderService.fetchOrders(
        salonId: salonId,
        page: _currentPage,
        size: size,
        mobile: _mobileQuery.isEmpty ? null : _mobileQuery,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );

      _orders = result.content;
      _totalPages = result.totalPages;
      _currentPage = result.number;
      _hasMore = !_hasMore;

      _applyLocalFilter();
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
    int size = 10,
  }) async {
    _currentPage = page;
    await fetchOrders(salonId: salonId, size: size);
  }

  void setMobileQuery(String query, int salonId) {
    _mobileQuery = query;
    _applyLocalFilter();
    fetchOrders(salonId: salonId, refresh: true);
  }

  void setStatusFilter(String status, int salonId) {
    _selectedStatus = status;
    _applyLocalFilter();
    fetchOrders(salonId: salonId, refresh: true);
  }

  void _applyLocalFilter() {
    _filteredOrders = _orders.where((order) {
      bool matchesMobile = true;
      if (_mobileQuery.isNotEmpty) {
        matchesMobile = order.customerMobile.contains(_mobileQuery);
      }
      bool matchesStatus = true;
      if (_selectedStatus != 'all') {
        matchesStatus = order.status.toLowerCase() == _selectedStatus.toLowerCase();
      }
      return matchesMobile && matchesStatus;
    }).toList();
    notifyListeners();
  }

  Future<String> approveOrder(int id) async {
    try {
      await _orderService.updateOrderStatus(id, 'completed');
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        await fetchOrders(salonId: _orders[index].salonId, refresh: true);
      }
      return "Order approved successfully";
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      throw Exception(_errorMessage);
    }
  }

  Future<String> rejectOrder(int id) async {
    try {
      await _orderService.updateOrderStatus(id, 'cancelled');
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        await fetchOrders(salonId: _orders[index].salonId, refresh: true);
      }
      return "Order rejected successfully";
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      throw Exception(_errorMessage);
    }
  }
}
