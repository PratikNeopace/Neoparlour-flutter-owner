class AppointmentServiceItem {
  final int id;
  final String serviceId;
  final String serviceName;
  final double price;
  final int duration;

  AppointmentServiceItem({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.duration,
  });

  factory AppointmentServiceItem.fromJson(Map<String, dynamic> json) {
    return AppointmentServiceItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'price': price,
      'duration': duration,
    };
  }
}

class Appointment {
  final int id;
  final int userId;
  final int? customerId;
  final int? salonId;
  final int? staffId;
  final String staffName;
  final String customerName;
  final String? customerMobile;
  final DateTime appointmentAt;
  final int? serviceDuration;
  final double totalPrice;
  final double? discountAmount;
  final double finalAmount;
  final double? homeCharge;
  final int? offerId;
  final String? offerName;
  final String? discountType;
  final double? discountValue;
  final int? packageId;
  final String? packageName;
  final String status;
  final String? cancelReason;
  final String? ownerRescheduleReason;
  final String? customerRescheduleReason;
  final bool homeService;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> serviceNames;
  final List<AppointmentServiceItem>? services;
  final List<int>? openedProductIds;

  Appointment({
    required this.id,
    required this.userId,
    this.customerId,
    this.salonId,
    this.staffId,
    required this.staffName,
    required this.customerName,
    this.customerMobile,
    required this.appointmentAt,
    this.serviceDuration,
    required this.totalPrice,
    this.discountAmount,
    required this.finalAmount,
    this.homeCharge,
    this.offerId,
    this.offerName,
    this.discountType,
    this.discountValue,
    this.packageId,
    this.packageName,
    required this.status,
    this.cancelReason,
    this.ownerRescheduleReason,
    this.customerRescheduleReason,
    required this.homeService,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
    required this.serviceNames,
    this.services,
    this.openedProductIds,
  });

  Appointment copyWith({
    int? id,
    int? userId,
    int? customerId,
    int? salonId,
    int? staffId,
    String? staffName,
    String? customerName,
    String? customerMobile,
    DateTime? appointmentAt,
    int? serviceDuration,
    double? totalPrice,
    double? discountAmount,
    double? finalAmount,
    double? homeCharge,
    int? offerId,
    String? offerName,
    String? discountType,
    double? discountValue,
    int? packageId,
    String? packageName,
    String? status,
    String? cancelReason,
    String? ownerRescheduleReason,
    String? customerRescheduleReason,
    bool? homeService,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? serviceNames,
    List<AppointmentServiceItem>? services,
    List<int>? openedProductIds,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      salonId: salonId ?? this.salonId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      appointmentAt: appointmentAt ?? this.appointmentAt,
      serviceDuration: serviceDuration ?? this.serviceDuration,
      totalPrice: totalPrice ?? this.totalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      homeCharge: homeCharge ?? this.homeCharge,
      offerId: offerId ?? this.offerId,
      offerName: offerName ?? this.offerName,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      status: status ?? this.status,
      cancelReason: cancelReason ?? this.cancelReason,
      ownerRescheduleReason: ownerRescheduleReason ?? this.ownerRescheduleReason,
      customerRescheduleReason: customerRescheduleReason ?? this.customerRescheduleReason,
      homeService: homeService ?? this.homeService,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceNames: serviceNames ?? this.serviceNames,
      services: services ?? this.services,
      openedProductIds: openedProductIds ?? this.openedProductIds,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawServices = json['services'];
    final List<AppointmentServiceItem>? parsedServices = rawServices != null
        ? rawServices.map((s) => AppointmentServiceItem.fromJson(s)).toList()
        : null;

    // Derived values
    List<String> sNames = [];
    if (json['serviceNames'] != null) {
      if (json['serviceNames'] is List) {
        sNames =
            (json['serviceNames'] as List).map((e) => e.toString()).toList();
      }
    }

    if (sNames.isEmpty && parsedServices != null) {
      sNames = parsedServices.map((s) => s.serviceName).toList();
    }

    // Safer numeric parsing for userId
    int uId = (json['userId'] as num?)?.toInt() ?? 0;
    if (uId == 0 && json['customerDTO'] != null) {
      uId = (json['customerDTO']['id'] as num?)?.toInt() ?? 0;
    }

    return Appointment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: uId,
      customerId: (json['customerId'] as num?)?.toInt(),
      salonId: (json['salonId'] as num?)?.toInt(),
      staffId: (json['staffId'] as num?)?.toInt(),
      staffName: json['staffName']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerMobile: (json['customerNumber'] ?? json['customerMobile'])
          ?.toString(),
      appointmentAt: DateTime.parse(
          json['appointmentAt'] ?? DateTime.now().toIso8601String()),
      serviceDuration: (json['serviceDuration'] as num?)?.toInt(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
      homeCharge: (json['homeCharge'] as num?)?.toDouble(),
      offerId: (json['offerId'] as num?)?.toInt(),
      offerName: json['offerName']?.toString(),
      discountType: json['discountType']?.toString(),
      discountValue: (json['discountValue'] as num?)?.toDouble(),
      packageId: (json['packageId'] as num?)?.toInt(),
      packageName: json['packageName']?.toString(),
      status: json['status']?.toString() ?? '',
      cancelReason: json['cancelReason']?.toString(),
      ownerRescheduleReason: json['ownerRescheduleReason']?.toString(),
      customerRescheduleReason: json['customerRescheduleReason']?.toString(),
      homeService: json['homeService'] ?? false,
      address: json['address']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      serviceNames: sNames,
      services: parsedServices,
      openedProductIds: (json['openedProductIds'] as List<dynamic>?)?.map((e) =>
          (e as num).toInt()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'customerId': customerId,
      'salonId': salonId,
      'staffId': staffId,
      'staffName': staffName,
      'customerName': customerName,
      'customerNumber': customerMobile,
      'appointmentAt': appointmentAt.toIso8601String(),
      'serviceDuration': serviceDuration,
      'totalPrice': totalPrice,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'homeCharge': homeCharge,
      'offerId': offerId,
      'offerName': offerName,
      'discountType': discountType,
      'discountValue': discountValue,
      'packageId': packageId,
      'packageName': packageName,
      'status': status,
      'cancelReason': cancelReason,
      'ownerRescheduleReason': ownerRescheduleReason,
      'customerRescheduleReason': customerRescheduleReason,
      'homeService': homeService,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'serviceNames': serviceNames,
      if (services != null) 'services': services!.map((s) => s.toJson())
          .toList(),
      'openedProductIds': openedProductIds,
    };
  }
}

class PaginatedAppointments {
  final List<Appointment> content;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int size;
  final int number;

  PaginatedAppointments({
  required this.content,
  required this.totalElements,
  required this.totalPages,
  required this.last,
  required this.size,
  required this.number,
  });

  factory PaginatedAppointments.fromJson(dynamic json) {
  if (json is List) {
  return PaginatedAppointments(
  content: json.map((item) => Appointment.fromJson(item)).toList(),
  totalElements: json.length,
  totalPages: 1,
  last: true,
  size: json.length,
  number: 0,
  );
  }

    if (json is Map<String, dynamic>) {
      final List<dynamic>? contentList = json['content'];
      if (contentList != null) {
        final pageInfo = json['page'] as Map<String, dynamic>?;
        
        return PaginatedAppointments(
          content: contentList.map((item) => Appointment.fromJson(item)).toList(),
          totalElements: (pageInfo?['totalElements'] ?? json['totalElements'] as num?)?.toInt() ?? 0,
          totalPages: (pageInfo?['totalPages'] ?? pageInfo?['total_pages'] ?? json['totalPages'] ?? json['total_pages'] as num?)?.toInt() ?? 0,
          last: (pageInfo?['number'] != null && (pageInfo?['totalPages'] ?? pageInfo?['total_pages']) != null) 
              ? (pageInfo!['number'] >= (pageInfo['totalPages'] ?? pageInfo['total_pages']) - 1)
              : (json['last'] ?? true),
          size: (pageInfo?['size'] ?? json['size'] as num?)?.toInt() ?? 0,
          number: (pageInfo?['number'] ?? json['number'] as num?)?.toInt() ?? 0,
        );
      }

  if (json.containsKey('id')) {
  return PaginatedAppointments(
  content: [Appointment.fromJson(json)],
  totalElements: 1,
  totalPages: 1,
  last: true,
  size: 1,
  number: 0,
  );
  }
  }

  return PaginatedAppointments(
  content: [],
  totalElements: 0,
  totalPages: 0,
  last: true,
  size: 0,
  number: 0,
  );
  }
}