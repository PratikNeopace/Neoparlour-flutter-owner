import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/service_model.dart';
import 'package:neo_parlour_owner/data/services/service_service.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceService _service = ServiceService();

  List<NeoService> _services = [];
  List<String> _commonServices = [];
  NeoService? _editingService;
  bool _isLoading = false;
  String? _errorMessage;

  List<NeoService> get services => _services;
  List<String> get commonServices => _commonServices;
  NeoService? get editingService => _editingService;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> addService(NeoService service) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newService = await _service.addService(service);
      _services.add(newService);
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = await _service.fetchServices();
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = await _service.fetchActiveServices();
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCommonServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _commonServices = await _service.getCommonServicesNames();
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      if (_commonServices.isEmpty) {
        _commonServices = [
          "Hair Cut",
          "Coloring",
          "Hair Spa",
          "Hair Styling",
          "Shaving",
          "Hair Wash",
          "Straightning",
        ];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateService(NeoService service) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _service.updateService(service);
      final index = _services.indexWhere((s) => s.id == updated.id);
      if (index != -1) {
        _services[index] = updated;
      }
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteService(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteService(id);
      final index = _services.indexWhere((s) => s.id == id);
      if (index != -1) {
        _services[index] = NeoService(
          id: _services[index].id,
          name: _services[index].name,
          duration: _services[index].duration,
          price: _services[index].price,
          category: _services[index].category,
          image: _services[index].image,
          active: false,
          popularityCount: _services[index].popularityCount,
          createdAt: _services[index].createdAt,
          updatedAt: _services[index].updatedAt,
        );
      }
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleServiceStatus(int id, bool active) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.toggleServiceStatus(id, active);
      final index = _services.indexWhere((s) => s.id == id);
      if (index != -1) {
        // Create a new instance with the updated status
        final existing = _services[index];
        _services[index] = NeoService(
          id: existing.id,
          name: existing.name,
          duration: existing.duration,
          price: existing.price,
          category: existing.category,
          image: existing.image,
          active: active,
          popularityCount: existing.popularityCount,
          createdAt: existing.createdAt,
          updatedAt: existing.updatedAt,
        );
      }
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrors() {
    notifyListeners();
  }

  void setEditingService(NeoService service) {
    _editingService = service;
    notifyListeners();
  }

  void clearEditingService() {
    _editingService = null;
    notifyListeners();
  }
}
