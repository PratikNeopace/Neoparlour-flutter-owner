class NeoService {
  final int? id;
  final String name;
  final int duration;
  final double price;
  final String? image;
  final String? imageUrl;
  final String? pdfUrl;
  final String category;
  final bool active;
  final int popularityCount;
  final int? displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NeoService({
    this.id,
    required this.name,
    required this.duration,
    required this.price,
    this.image,
    this.imageUrl,
    this.pdfUrl,
    required this.category,
    this.active = true,
    this.popularityCount = 0,
    this.displayOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory NeoService.fromJson(Map<String, dynamic> json) {
    final String? imgField = json['image'];
    final bool isUrl = imgField != null && imgField.startsWith('http');
    
    return NeoService(
      id: json['id'],
      name: json['name'] ?? '',
      duration: json['duration'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: isUrl ? null : imgField,
      imageUrl: isUrl ? imgField : json['imageUrl'],
      pdfUrl: json['pdfUrl'],
      category: json['category'] ?? '',
      active: json['active'] ?? true,
      popularityCount: json['popularityCount'] ?? 0,
      displayOrder: json['displayOrder'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'duration': duration,
      'price': price,
      'pdfUrl': pdfUrl,
      'category': category,
      'active': active,
      'popularityCount': popularityCount,
      'displayOrder': displayOrder,
    };
    
    if (id != null) {
      data['id'] = id;
    }
    
    if (image != null && !image!.startsWith('assets/')) {
      data['image'] = image;
    }
    
    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }
    
    return data;
  }
}
