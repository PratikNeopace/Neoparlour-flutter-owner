import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/product_model.dart';
import 'package:neo_parlour_owner/data/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _productService.fetchProducts();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newProduct = await _productService.addProduct(product);
      _products.add(newProduct);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedProduct = await _productService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _productService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleProductStatus(int id, bool active) async {
    try {
      await _productService.toggleProductStatus(id, active);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = ProductModel(
          id: _products[index].id,
          salonId: _products[index].salonId,
          name: _products[index].name,
          description: _products[index].description,
          price: _products[index].price,
          discountPrice: _products[index].discountPrice,
          category: _products[index].category,
          stock: _products[index].stock,
          restockLevel: _products[index].restockLevel,
          productType: _products[index].productType,
          active: active,
          imageBase64: _products[index].imageBase64,
          additionalImagesBase64: _products[index].additionalImagesBase64,
          createdAt: _products[index].createdAt,
          updatedAt: _products[index].updatedAt,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling product status: $e');
      return false;
    }
  }

  ProductModel? _editingProduct;
  ProductModel? get editingProduct => _editingProduct;

  void setEditingProduct(ProductModel product) {
    _editingProduct = product;
    notifyListeners();
  }

  void clearEditingProduct() {
    _editingProduct = null;
    notifyListeners();
  }
}
