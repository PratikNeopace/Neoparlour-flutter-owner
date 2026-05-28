import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/salon_qr_model.dart';
import 'package:neo_parlour_owner/data/models/salon_profile_model.dart';

class SalonService {
  final ApiClient _apiClient = ApiClient();

  Future<void> updateHomeServiceCharges(double charges) async {
    try {
      await _apiClient.put(
        'salons/home-service-charges',
        queryParameters: {'charges': charges},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getHomeServiceCharges(int salonId) async {
    try {
      final response = await _apiClient.get('salons/$salonId/home-service-charges');
      if (response.data != null) {
        return double.tryParse(response.data.toString()) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setWeeklyOffDay(String day) async {
    try {
      await _apiClient.put(
        'salons/weekly-off',
        queryParameters: {'day': day},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<SalonQRCode> getSalonQRCode() async {
    try {
      final response = await _apiClient.get('salons/qr');
      return SalonQRCode.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<SalonProfileModel> getSalonProfile() async {
    try {
      final response = await _apiClient.get('salons/profile');
      if (response.statusCode == 200) {
        return SalonProfileModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch salon profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<SalonProfileModel> updateSalonProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('salons/profile', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SalonProfileModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update salon profile');
      }
    } catch (e) {
      rethrow;
    }
  }
}
