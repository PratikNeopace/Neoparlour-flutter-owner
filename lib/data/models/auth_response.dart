class AuthResponse {
  final int id;
  final String token;
  final String name;
  final String phone;
  final String role;
  final String? tenantName; // salonName in some contexts
  final String? email;
  final String? gender;
  final String? birthdate;
  
  final int? staffId;
  final int? userId;
  final int? salonId;
  final String? salonName;
  final String? address;
  final String? cityName;
  final String? areaName;
  final String? imageBase64;
  final String? imageUrl;
  final double? homeServiceCharges;
  final String? fcmToken;
  final String? openingTime;
  final String? closingTime;
  final String? weeklyOffDay;
  final String? salonCode;
  final bool? active;
  final double? latitude;
  final double? longitude;

  AuthResponse({
    required this.id,
    required this.token,
    required this.name,
    required this.phone,
    required this.role,
    this.tenantName,
    this.email,
    this.gender,
    this.birthdate,
    this.staffId,
    this.userId,
    this.salonId,
    this.salonName,
    this.address,
    this.cityName,
    this.areaName,
    this.imageBase64,
    this.imageUrl,
    this.homeServiceCharges,
    this.fcmToken,
    this.active,
    this.openingTime,
    this.closingTime,
    this.weeklyOffDay,
    this.salonCode,
    this.latitude,
    this.longitude,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final staffId = json['staffId'] ?? (json['role'] == 'STAFF' ? json['id'] : null);
    
    return AuthResponse(
      id: json['userId'] ?? json['id'] ?? 0,
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      tenantName: (json['salonName'] ?? json['tenantName'] ?? '').toString(),
      email: json['email'],
      gender: json['gender'],
      birthdate: json['birthdate'],
      staffId: staffId is int ? staffId : int.tryParse(staffId?.toString() ?? ''),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      salonId: json['salonId'],
      salonName: json['salonName'],
      address: json['address'],
      cityName: json['cityName'],
      areaName: json['areaName'],
      imageBase64: json['imageBase64'],
      imageUrl: json['imageUrl'],
      homeServiceCharges: (json['homeServiceCharges'] as num?)?.toDouble(),
      fcmToken: json['fcmToken'],
      active: json['active'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      weeklyOffDay: json['weeklyOffDay'],
      salonCode: json['salonCode'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  AuthResponse copyWith({
    int? id,
    String? token,
    String? name,
    String? phone,
    String? role,
    String? tenantName,
    String? email,
    String? gender,
    String? birthdate,
    int? staffId,
    int? userId,
    int? salonId,
    String? salonName,
    String? address,
    String? cityName,
    String? areaName,
    String? imageBase64,
    String? imageUrl,
    double? homeServiceCharges,
    String? fcmToken,
    bool? active,
    String? openingTime,
    String? closingTime,
    String? weeklyOffDay,
    String? salonCode,
    double? latitude,
    double? longitude,
  }) {
    return AuthResponse(
      id: id ?? this.id,
      token: token ?? this.token,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      tenantName: tenantName ?? this.tenantName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      staffId: staffId ?? this.staffId,
      userId: userId ?? this.userId,
      salonId: salonId ?? this.salonId,
      salonName: salonName ?? this.salonName,
      address: address ?? this.address,
      cityName: cityName ?? this.cityName,
      areaName: areaName ?? this.areaName,
      imageBase64: imageBase64 ?? this.imageBase64,
      imageUrl: imageUrl ?? this.imageUrl,
      homeServiceCharges: homeServiceCharges ?? this.homeServiceCharges,
      fcmToken: fcmToken ?? this.fcmToken,
      active: active ?? this.active,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      weeklyOffDay: weeklyOffDay ?? this.weeklyOffDay,
      salonCode: salonCode ?? this.salonCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'name': name,
      'phone': phone,
      'role': role,
      'tenantName': tenantName,
      'salonName': salonName,
      'email': email,
      'gender': gender,
      'birthdate': birthdate,
      'salonId': salonId,
      'address': address,
      'cityName': cityName,
      'areaName': areaName,
      'imageBase64': imageBase64,
      'imageUrl': imageUrl,
      'homeServiceCharges': homeServiceCharges,
      'fcmToken': fcmToken,
      'active': active,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'weeklyOffDay': weeklyOffDay,
      'salonCode': salonCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
