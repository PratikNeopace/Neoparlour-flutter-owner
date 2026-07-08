// ignore_for_file: constant_identifier_names
import 'package:neo_parlour_owner/core/utils/date_time_utils.dart';

enum DiscountType { FLAT, PERCENTAGE }

class Offer {
  final int? id;
  final String name;
  final String? description;
  final DiscountType discountType;
  final double discountValue;
  final DateTime validFrom;
  final DateTime validTo;
  final bool active;
  final List<int> applicableServiceIds;
  final List<String> serviceNames;
  final int? usageLimitPerCustomer;
  final int? totalUsageLimit;

  Offer({
    this.id,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.validFrom,
    required this.validTo,
    this.active = true,
    required this.applicableServiceIds,
    this.serviceNames = const [],
    this.usageLimitPerCustomer,
    this.totalUsageLimit,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      discountType: json['discountType'] == 'PERCENTAGE' 
          ? DiscountType.PERCENTAGE 
          : DiscountType.FLAT,
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 
                     (json['percentage'] as num?)?.toDouble() ?? 
                     (json['flatAmount'] as num?)?.toDouble() ?? 0.0,
      validFrom: DateTime.parse(json['validFrom']),
      validTo: DateTime.parse(json['validTo']),
      active: json['active'] ?? true,
      applicableServiceIds: (json['applicableServiceIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ?? 
              (json['applicableServices'] as List<dynamic>?)
              ?.map((e) => e['id'] as int)
              .toList() ?? [],
      serviceNames: (json['serviceNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? 
              (json['applicableServiceNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? 
              (json['applicableServices'] as List<dynamic>?)
              ?.map((e) => e['name'].toString())
              .toList() ?? [],
      usageLimitPerCustomer: json['usageLimitPerCustomer'],
      totalUsageLimit: json['totalUsageLimit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discountType': discountType == DiscountType.PERCENTAGE ? 'PERCENTAGE' : 'FLAT',
      'discountValue': discountValue,
      'validFrom': DateTimeUtils.toIstIsoString(validFrom),
      'validTo': DateTimeUtils.toIstIsoString(validTo),
      'active': active,
      'applicableServiceIds': applicableServiceIds,
      'usageLimitPerCustomer': usageLimitPerCustomer,
      'totalUsageLimit': totalUsageLimit,
    };
  }
  
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'description': description,
      'discountType': discountType == DiscountType.PERCENTAGE ? 'PERCENTAGE' : 'FLAT',
      'discountValue': discountValue,
      'validFrom': DateTimeUtils.toIstIsoString(validFrom),
      'validTo': DateTimeUtils.toIstIsoString(validTo),
      'active': active,
      'applicableServiceIds': applicableServiceIds,
      'usageLimitPerCustomer': usageLimitPerCustomer,
      'totalUsageLimit': totalUsageLimit,
    };
  }
}

class OfferPaginatedResponse {
  final List<Offer> content;
  final int totalPages;
  final int number;

  OfferPaginatedResponse({
    required this.content,
    required this.totalPages,
    required this.number,
  });

  factory OfferPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return OfferPaginatedResponse(
      content: (json['content'] as List?)?.map((i) => Offer.fromJson(i)).toList() ?? [],
      totalPages: json['page']?['totalPages'] ?? 1,
      number: json['page']?['number'] ?? 0,
    );
  }
}
