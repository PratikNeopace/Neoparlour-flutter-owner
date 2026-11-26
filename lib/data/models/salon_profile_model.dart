enum DiscountMode { NONE, WEEKDAY, CATEGORY }

class SalonProfileModel {
  final int salonId;
  final String? salonName;
  final String? salonCode;
  final String? phone;
  final String? email;
  final String? address;
  final String? specificAddress;
  final String? landmark;
  final String? area;
  final String? city;
  final String? openingTime;
  final String? closingTime;
  final String? weeklyOffDay;
  final double? homeServiceCharges;
  final double? weekdayDiscount;
  final double? morningDiscount;
  final double? afternoonDiscount;
  final double? eveningDiscount;
  final double? nightDiscount;
  final String? qrCodeBase64;
  final String? qrCodeUrl;
  final String? imageUrl;
  final List<dynamic>? salonImages;
  final bool? active;
  final List<dynamic>? holidays;
  final String? createdAt;
  final String? state;
  final bool includeGstInInvoice;
  final String? gstin;
  final double? latitude;
  final double? longitude;

  SalonProfileModel({
    required this.salonId,
    this.salonName,
    this.salonCode,
    this.phone,
    this.email,
    this.address,
    this.specificAddress,
    this.landmark,
    this.area,
    this.city,
    this.openingTime,
    this.closingTime,
    this.weeklyOffDay,
    this.homeServiceCharges,
    this.weekdayDiscount,
    this.morningDiscount,
    this.afternoonDiscount,
    this.eveningDiscount,
    this.nightDiscount,
    this.qrCodeBase64,
    this.qrCodeUrl,
    this.imageUrl,
    this.salonImages,
    this.active,
    this.holidays,
    this.createdAt,
    this.state,
    this.includeGstInInvoice = false,
    this.gstin,
    this.latitude,
    this.longitude,
  });

  DiscountMode get activeDiscountMode {
    if ((weekdayDiscount ?? 0) > 0) {
      return DiscountMode.WEEKDAY;
    } else if ((morningDiscount ?? 0) > 0 ||
        (afternoonDiscount ?? 0) > 0 ||
        (eveningDiscount ?? 0) > 0 ||
        (nightDiscount ?? 0) > 0) {
      return DiscountMode.CATEGORY;
    }
    return DiscountMode.NONE;
  }

  factory SalonProfileModel.fromJson(Map<String, dynamic> json) {
    return SalonProfileModel(
      salonId: json['salonId'] ?? 0,
      salonName: json['salonName'],
      salonCode: json['salonCode'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      specificAddress: json['specificAddress'],
      landmark: json['landmark'],
      area: json['area'] ?? json['areaName'],
      city: json['city'] ?? json['cityName'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      weeklyOffDay: json['weeklyOffDay'],
      homeServiceCharges: (json['homeServiceCharges'] as num?)?.toDouble(),
      weekdayDiscount: (json['weekdayDiscount'] as num?)?.toDouble(),
      morningDiscount: (json['morningDiscount'] as num?)?.toDouble(),
      afternoonDiscount: (json['afternoonDiscount'] as num?)?.toDouble(),
      eveningDiscount: (json['eveningDiscount'] as num?)?.toDouble(),
      nightDiscount: (json['nightDiscount'] as num?)?.toDouble(),
      qrCodeBase64: json['qrCodeBase64'],
      qrCodeUrl: json['qrCodeUrl'],
      imageUrl: json['imageUrl'] ?? json['logoUrl'] ?? json['applicationLogoUrl'],
      salonImages: json['salonImages'],
      active: json['active'],
      holidays: json['holidays'],
      createdAt: json['createdAt'],
      state: json['state'],
      includeGstInInvoice: json['includeGstInInvoice'] ?? false,
      gstin: json['gstin'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salonId': salonId,
      'salonName': salonName,
      'salonCode': salonCode,
      'phone': phone,
      'email': email,
      'address': address,
      'specificAddress': specificAddress,
      'landmark': landmark,
      'area': area,
      'city': city,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'weeklyOffDay': weeklyOffDay,
      'homeServiceCharges': homeServiceCharges,
      'weekdayDiscount': weekdayDiscount,
      'qrCodeBase64': qrCodeBase64,
      'qrCodeUrl': qrCodeUrl,
      'imageUrl': imageUrl,
      'salonImages': salonImages,
      'active': active,
      'holidays': holidays,
      'createdAt': createdAt,
      'state': state,
      'includeGstInInvoice': includeGstInInvoice,
      'gstin': (gstin != null && gstin!.isNotEmpty) ? gstin!.trim().toUpperCase() : null,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
