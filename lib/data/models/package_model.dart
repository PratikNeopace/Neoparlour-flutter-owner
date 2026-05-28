import 'package:neo_parlour_owner/data/models/service_model.dart';

class ServicePackage {
  final int? id;
  final int? salonId;
  final String name;
  final String? description;
  final double packagePrice;
  final bool active;
  final List<NeoService> services;
  final int? usageLimitPerCustomer;
  final int? totalUsageLimit;
  final int usedCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServicePackage({
    this.id,
    this.salonId,
    required this.name,
    this.description,
    required this.packagePrice,
    this.active = true,
    this.services = const [],
    this.usageLimitPerCustomer,
    this.totalUsageLimit,
    this.usedCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    return ServicePackage(
      id: json['id'],
      salonId: json['salonId'],
      name: json['name'] ?? '',
      description: json['description'],
      packagePrice: (json['packagePrice'] as num?)?.toDouble() ?? 0.0,
      active: json['active'] ?? true,
      services: (json['services'] as List?)
              ?.map((s) => NeoService.fromJson(s))
              .toList() ??
          [],
      usageLimitPerCustomer: json['usageLimitPerCustomer'],
      totalUsageLimit: json['totalUsageLimit'],
      usedCount: json['usedCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'packagePrice': packagePrice,
      'active': active,
      'serviceIds': services.map((s) => s.id).whereType<int>().toList(),
    };

    if (id != null) data['id'] = id;
    if (description != null && description!.isNotEmpty) {
      data['description'] = description;
    }
    if (usageLimitPerCustomer != null) {
      data['usageLimitPerCustomer'] = usageLimitPerCustomer;
    }
    if (totalUsageLimit != null) {
      data['totalUsageLimit'] = totalUsageLimit;
    }

    return data;
  }
}
