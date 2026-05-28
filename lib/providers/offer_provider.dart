import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/offer_model.dart';
import 'package:neo_parlour_owner/data/services/offer_service.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class OfferProvider extends ChangeNotifier {
  final OfferService _service = OfferService();

  List<Offer> _offers = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 0;
  int _totalPages = 1;
  final int _pageSize = 10;

  List<Offer> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  Future<void> fetchOffers({int page = 0}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getAllOffers(page: page, size: _pageSize);
      _offers = response.content;
      _currentPage = response.number;
      _totalPages = response.totalPages;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      fetchOffers(page: page);
    }
  }

  Future<bool> addOffer(Offer offer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newOffer = await _service.createOffer(offer);
      _offers.add(newOffer);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOffer(Offer offer) async {
    if (offer.id == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedOffer = await _service.updateOffer(offer.id!, offer);
      final index = _offers.indexWhere((o) => o.id == offer.id);
      if (index != -1) {
        _offers[index] = updatedOffer;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteOffer(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteOffer(id);
      _offers.removeWhere((o) => o.id == id);
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
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
