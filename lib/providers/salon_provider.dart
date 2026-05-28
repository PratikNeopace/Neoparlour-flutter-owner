import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/salon_qr_model.dart';
import 'package:neo_parlour_owner/data/models/salon_profile_model.dart';
import 'package:neo_parlour_owner/data/services/salon_service.dart';

class SalonProvider with ChangeNotifier {
  final SalonService _salonService = SalonService();
  bool _isLoading = false;
  String? _errorMessage;
  SalonQRCode? _qrCode;
  SalonProfileModel? _salonProfile;
  double? _homeServiceCharges;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SalonQRCode? get qrCode => _qrCode;
  SalonProfileModel? get salonProfile => _salonProfile;
  double? get homeServiceCharges => _homeServiceCharges;

  Future<void> fetchSalonQRCode() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _qrCode = await _salonService.getSalonQRCode();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSalonProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _salonProfile = await _salonService.getSalonProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHomeServiceCharges(int salonId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _homeServiceCharges = await _salonService.getHomeServiceCharges(salonId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateHomeServiceCharges(double charges) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _salonService.updateHomeServiceCharges(charges);
      _homeServiceCharges = charges;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> setWeeklyOffDay(String day) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _salonService.setWeeklyOffDay(day);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSalonProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _salonProfile = await _salonService.updateSalonProfile(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
