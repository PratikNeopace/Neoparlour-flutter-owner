import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/package_model.dart';
import 'package:neo_parlour_owner/data/services/package_service.dart';

class PackageProvider with ChangeNotifier {
  final PackageService _packageService = PackageService();
  List<ServicePackage> _packages = [];
  bool _isLoading = false;
  int _currentPage = 0;
  int _totalPages = 0;

  List<ServicePackage> get packages => _packages;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  Future<void> fetchPackages({
    bool refresh = false,
    int size = 10,
    String? keyword,
  }) async {
    if (refresh) {
      _currentPage = 0;
    }

    _isLoading = true;
    notifyListeners();
    try {
      final result = await _packageService.fetchPackages(
        page: _currentPage,
        size: size,
        keyword: keyword,
      );
      _packages = result.content;
      _totalPages = result.totalPages;
      _currentPage = result.number;
    } catch (e) {
      debugPrint('Error fetching packages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> goToPage({
    required int page,
    int size = 10,
    String? keyword,
  }) async {
    _currentPage = page;
    await fetchPackages(size: size, keyword: keyword);
  }

  Future<bool> addPackage(ServicePackage package) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newPackage = await _packageService.addPackage(package);
      _packages.add(newPackage);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding package: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePackage(ServicePackage package) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedPackage = await _packageService.updatePackage(package);
      final index = _packages.indexWhere((p) => p.id == updatedPackage.id);
      if (index != -1) {
        _packages[index] = updatedPackage;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating package: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePackage(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _packageService.deletePackage(id);
      _packages.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting package: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> togglePackageStatus(int id, bool active) async {
    try {
      await _packageService.togglePackageStatus(id, active);
      final index = _packages.indexWhere((p) => p.id == id);
      if (index != -1) {
        _packages[index] = ServicePackage(
          id: _packages[index].id,
          salonId: _packages[index].salonId,
          name: _packages[index].name,
          description: _packages[index].description,
          packagePrice: _packages[index].packagePrice,
          active: active,
          services: _packages[index].services,
          usageLimitPerCustomer: _packages[index].usageLimitPerCustomer,
          totalUsageLimit: _packages[index].totalUsageLimit,
          usedCount: _packages[index].usedCount,
          createdAt: _packages[index].createdAt,
          updatedAt: _packages[index].updatedAt,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling package status: $e');
      return false;
    }
  }
}
