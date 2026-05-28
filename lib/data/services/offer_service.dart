import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/offer_model.dart';
import 'package:dio/dio.dart';

class OfferService {
  final ApiClient _apiClient = ApiClient();

  Future<OfferPaginatedResponse> getAllOffers({int page = 0, int size = 10}) async {
    try {
      final response = await _apiClient.get(
        'offers/search',
        queryParameters: {'page': page, 'size': size},
      );
      if (response.statusCode == 200) {
        return OfferPaginatedResponse.fromJson(response.data);
      }
      return OfferPaginatedResponse(content: [], totalPages: 1, number: 0);
    } catch (e) {
      throw Exception('Failed to fetch offers: $e');
    }
  }

  Future<Offer> createOffer(Offer offer) async {
    try {
      final response = await _apiClient.post(
        'offers',
        data: offer.toCreateJson(),
      );
      if (response.statusCode == 201) {
        return Offer.fromJson(response.data);
      }
      throw Exception('Failed to create offer');
    } catch (e) {
      if (e is DioException) {
         throw Exception(e.response?.data?['message'] ?? 'Failed to create offer');
      }
      throw Exception('Error creating offer: $e');
    }
  }

  Future<Offer> updateOffer(int id, Offer offer) async {
    try {
      final response = await _apiClient.put(
        'offers/$id',
        data: offer.toJson(),
      );
      if (response.statusCode == 200) {
        return Offer.fromJson(response.data);
      }
      throw Exception('Failed to update offer');
    } catch (e) {
      throw Exception('Error updating offer: $e');
    }
  }

  Future<void> deleteOffer(int id) async {
    try {
      final response = await _apiClient.delete('offers/$id');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete offer');
      }
    } catch (e) {
      throw Exception('Error deleting offer: $e');
    }
  }
}
