class ProductModel {
  final int? id;
  final int? salonId;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String? category;
  final int? stock;
  final int? restockLevel;
  final String? productType;
  final bool active;
  final String? imageBase64;
  final List<String>? additionalImagesBase64;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    this.id,
    this.salonId,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    this.category,
    this.stock,
    this.restockLevel,
    this.productType,
    this.active = true,
    this.imageBase64,
    this.additionalImagesBase64,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      salonId: json['salonId'],
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      category: json['category'],
      stock: json['stock'],
      restockLevel: json['restockLevel'],
      productType: json['productType'],
      active: json['active'] ?? true,
      imageBase64: json['imageBase64'],
      additionalImagesBase64: (json['additionalImagesBase64'] as List?)?.map((e) => e as String).toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'price': price,
      'active': active,
    };
    if (id != null) data['id'] = id;
    if (salonId != null) data['salonId'] = salonId;
    if (description != null) data['description'] = description;
    if (discountPrice != null) data['discountPrice'] = discountPrice;
    if (category != null) data['category'] = category;
    if (stock != null) data['stock'] = stock;
    if (restockLevel != null) data['restockLevel'] = restockLevel;
    if (productType != null) data['productType'] = productType;
    if (imageBase64 != null) data['imageBase64'] = imageBase64;
    if (additionalImagesBase64 != null) data['additionalImagesBase64'] = additionalImagesBase64;
    
    return data;
  }
}
