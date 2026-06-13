class SalonProfileModel {
  final int salonId;
  final String? salonName;
  final String? salonCode;
  final String? phone;
  final String? email;
  final String? address;
  final String? area;
  final String? city;
  final String? openingTime;
  final String? closingTime;
  final String? weeklyOffDay;
  final double? homeServiceCharges;
  final String? qrCodeBase64;
  final String? qrCodeUrl;
  final String? imageUrl;
  final bool? active;
  final List<dynamic>? holidays;
  final String? createdAt;

  SalonProfileModel({
    required this.salonId,
    this.salonName,
    this.salonCode,
    this.phone,
    this.email,
    this.address,
    this.area,
    this.city,
    this.openingTime,
    this.closingTime,
    this.weeklyOffDay,
    this.homeServiceCharges,
    this.qrCodeBase64,
    this.qrCodeUrl,
    this.imageUrl,
    this.active,
    this.holidays,
    this.createdAt,
  });

  factory SalonProfileModel.fromJson(Map<String, dynamic> json) {
    return SalonProfileModel(
      salonId: json['salonId'] ?? 0,
      salonName: json['salonName'],
      salonCode: json['salonCode'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      area: json['area'],
      city: json['city'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      weeklyOffDay: json['weeklyOffDay'],
      homeServiceCharges: (json['homeServiceCharges'] as num?)?.toDouble(),
      qrCodeBase64: json['qrCodeBase64'],
      qrCodeUrl: json['qrCodeUrl'],
      imageUrl: json['imageUrl'] ?? json['logoUrl'] ?? json['applicationLogoUrl'],
      active: json['active'],
      holidays: json['holidays'],
      createdAt: json['createdAt'],
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
      'area': area,
      'city': city,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'weeklyOffDay': weeklyOffDay,
      'homeServiceCharges': homeServiceCharges,
      'qrCodeBase64': qrCodeBase64,
      'qrCodeUrl': qrCodeUrl,
      'imageUrl': imageUrl,
      'active': active,
      'holidays': holidays,
      'createdAt': createdAt,
    };
  }
}
