class KycDocument {
  final String documentType;
  final String fileName;
  final String contentType;
  final String fileBase64;

  KycDocument({
    required this.documentType,
    required this.fileName,
    required this.contentType,
    required this.fileBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'fileName': fileName,
      'contentType': contentType,
      'fileBase64': fileBase64,
    };
  }
}

class UserRegistrationRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String? salonName;
  final String? cityName;
  final String? areaName;
  final String? openingTime; // Expected format "HH:mm"
  final String? closingTime; // Expected format "HH:mm"
  final String role;
  final String? fcmToken;
  final String? address;
  final String? birthdate; // Expected format "yyyy-MM-dd"
  final double? latitude;
  final double? longitude;
  final String? gender;
  final double? homeServiceCharges;
  final String? imageBase64; // Main Salon Image
  final List<String>? salonImagesBase64; // Salon Gallery Images
  final List<KycDocument>? kycDocuments;
  final bool? tncAccepted;
  final String? tncVersion;
  final String? tncAcceptedAt;

  UserRegistrationRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.salonName,
    this.cityName,
    this.areaName,
    this.openingTime,
    this.closingTime,
    this.role = 'SALON_OWNER',
    this.fcmToken,
    this.address,
    this.birthdate,
    this.latitude,
    this.longitude,
    this.gender,
    this.homeServiceCharges,
    this.imageBase64,
    this.salonImagesBase64,
    this.kycDocuments,
    this.tncAccepted,
    this.tncVersion,
    this.tncAcceptedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      if (salonName != null) 'salonName': salonName,
      if (cityName != null) 'cityName': cityName,
      if (areaName != null) 'areaName': areaName,
      if (openingTime != null) 'openingTime': openingTime,
      if (closingTime != null) 'closingTime': closingTime,
      'role': role,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (address != null) 'address': address,
      if (birthdate != null) 'birthdate': birthdate,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (gender != null) 'gender': gender,
      if (homeServiceCharges != null) 'homeServiceCharges': homeServiceCharges,
      if (imageBase64 != null) 'imageBase64': imageBase64,
      if (salonImagesBase64 != null) 'salonImagesBase64': salonImagesBase64,
      if (kycDocuments != null) 'kycDocuments': kycDocuments!.map((e) => e.toJson()).toList(),
      if (tncAccepted != null) 'tncAccepted': tncAccepted,
      if (tncVersion != null) 'tncVersion': tncVersion,
      if (tncAcceptedAt != null) 'tncAcceptedAt': tncAcceptedAt,
    };
  }
}
