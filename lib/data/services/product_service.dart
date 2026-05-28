import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/product_model.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final response = await _apiClient.post(
        'products',
        data: product.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          return ProductModel.fromJson(data[0]);
        }
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = ApiClient.handleDioError(e);
      throw Exception('API Error: $message');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _apiClient.get('products');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => ProductModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch products');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final response = await _apiClient.put(
        'products/${product.id}',
        data: product.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          return ProductModel.fromJson(data[0]);
        }
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await _apiClient.delete('products/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleProductStatus(int id, bool active) async {
    try {
      final response = await _apiClient.put(
        'products/$id/toggle',
        queryParameters: {'active': active},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update product status');
      }
    } catch (e) {
      rethrow;
    }
  }
}
