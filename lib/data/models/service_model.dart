class NeoService {
  final int? id;
  final String name;
  final int duration;
  final double price;
  final String? image;
  final String? pdfUrl;
  final String category;
  final bool active;
  final int popularityCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NeoService({
    this.id,
    required this.name,
    required this.duration,
    required this.price,
    this.image,
    this.pdfUrl,
    required this.category,
    this.active = true,
    this.popularityCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory NeoService.fromJson(Map<String, dynamic> json) {
    return NeoService(
      id: json['id'],
      name: json['name'] ?? '',
      duration: json['duration'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'],
      pdfUrl: json['pdfUrl'],
      category: json['category'] ?? '',
      active: json['active'] ?? true,
      popularityCount: json['popularityCount'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'duration': duration,
      'price': price,
      if (image != null && !image!.startsWith('assets/')) 'image': image,
      'pdfUrl': pdfUrl,
      'category': category,
      'active': active,
      'popularityCount': popularityCount,
    };
  }
}
