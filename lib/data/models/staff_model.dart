class Staff {
  final int? id;
  final int? userId; // The user record ID
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool active;
  final String? salonName;
  final int? salonId; // Maps to salonId in backend
  final String? address;
  final String? cityName;
  final String? areaName;
  final String? birthdate;
  final String? openingTime;
  final String? closingTime;
  final double? latitude;
  final double? longitude;
  final String? createdAt;
  final String? updatedAt;
  final String? imageBase64;
  final String? imageUrl;
  final String? password;
  final String? gender; // Added gender field
  final String? fcmToken;

  Staff({
    this.id,
    this.userId,
    required this.name,
    required this.phone,
    required this.email,
    this.role = 'STAFF',
    this.active = true,
    this.salonName,
    this.salonId,
    this.address,
    this.cityName,
    this.areaName,
    this.birthdate,
    this.openingTime,
    this.closingTime,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.imageBase64,
    this.imageUrl,
    this.password,
    this.gender,
    this.fcmToken,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    final String? rawImg = json['imageBase64'] ?? json['imageAsBase64'] ?? json['image'];
    final bool isUrl = rawImg != null && rawImg.startsWith('http');
    return Staff(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? json['staffId']?.toString() ?? json['staff_id']?.toString() ?? ''),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? json['user_id']?.toString() ?? json['uid']?.toString() ?? ''),
      name: json['name'] ?? json['full_name'] ?? json['staffName'] ?? '',
      phone: json['phone'] ?? json['mobile'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'STAFF',
      active: json['active'] ?? (json['status'] == 'ACTIVE' || json['status'] == 'active' || json['active'] == 1 || json['active'] == 'true' || json['active'] == true),
      salonName: json['salonName'],
      salonId: json['salonId'] is int ? json['salonId'] : int.tryParse(json['salonId']?.toString() ?? ''),
      address: json['address'] ?? json['Address'] ?? json['permanentAddress'] ?? json['AddressLine1'] ?? json['location'],
      cityName: json['cityName'],
      areaName: json['areaName'],
      birthdate: json['birthdate'] ?? json['birthDate'] ?? json['birth_date'] ?? json['dob'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      imageBase64: isUrl ? null : rawImg,
      imageUrl: json['imageUrl'] ?? (isUrl ? rawImg : null),
      gender: json['gender'],
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    // Helper to ensure empty strings are sent as null
    String? nullIfEmpty(String? val) => (val == null || val.trim().isEmpty) ? null : val;

    final data = {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'active': active,
      'salonName': salonName,
      'salonId': salonId, 
      'dbName': salonId?.toString(),
      'address': nullIfEmpty(address),
      'cityName': nullIfEmpty(cityName),
      'areaName': nullIfEmpty(areaName),
      'birthdate': (birthdate != null && birthdate!.isNotEmpty) 
          ? (birthdate!.contains('T') ? birthdate : "${birthdate!}T00:00:00Z")
          : null,
      'openingTime': (openingTime != null && openingTime!.isNotEmpty) 
          ? (openingTime!.contains(':') && openingTime!.split(':').length == 2 ? "${openingTime!}:00" : openingTime)
          : "09:00:00",
      'closingTime': (closingTime != null && closingTime!.isNotEmpty) 
          ? (closingTime!.contains(':') && closingTime!.split(':').length == 2 ? "${closingTime!}:00" : closingTime)
          : "21:00:00",
      'latitude': latitude,
      'longitude': longitude,
      'gender': gender ?? 'MALE',
    };
    
    if (id != null) data['id'] = id!;
    if (userId != null) data['userId'] = userId!;
    if (password != null && password!.isNotEmpty) data['password'] = password!;
    if (imageBase64 != null) data['imageBase64'] = imageBase64!;
    if (fcmToken != null) data['fcmToken'] = fcmToken!;
    
    return data;
  }

  Map<String, dynamic> toParentDbUpdateJson() {
    final data = {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'active': active,
      'tenantName': salonId?.toString() ?? salonName ?? '',
      'address': address,
      'birthdate': birthdate != null && birthdate!.isNotEmpty 
          ? birthdate!.split('T')[0] 
          : null,
    };
    if (password != null && password!.isNotEmpty) {
      data['password'] = password!;
    }
    if (imageBase64 != null) {
      data['imageBase64'] = imageBase64!;
    }
    return data;
  }
  Staff copyWith({
    int? id,
    int? userId,
    String? name,
    String? phone,
    String? email,
    String? role,
    bool? active,
    String? salonName,
    int? salonId,
    String? address,
    String? cityName,
    String? areaName,
    String? birthdate,
    String? openingTime,
    String? closingTime,
    double? latitude,
    double? longitude,
    String? createdAt,
    String? updatedAt,
    String? imageBase64,
    String? imageUrl,
    String? password,
    String? gender,
    String? fcmToken,
  }) {
    return Staff(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      active: active ?? this.active,
      salonName: salonName ?? this.salonName,
      salonId: salonId ?? this.salonId,
      address: address ?? this.address,
      cityName: cityName ?? this.cityName,
      areaName: areaName ?? this.areaName,
      birthdate: birthdate ?? this.birthdate,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageBase64: imageBase64 ?? this.imageBase64,
      imageUrl: imageUrl ?? this.imageUrl,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
