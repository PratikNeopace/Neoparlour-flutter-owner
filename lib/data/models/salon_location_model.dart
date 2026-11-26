class SalonLocationDetails {
  final double? latitude;
  final double? longitude;
  final String shopOrFlatNo;
  final String buildingName;
  final String landmark;
  final String areaName;
  final String cityName;
  final String state;
  final String? pincode;
  final List<String> nearbyLandmarks;

  SalonLocationDetails({
    this.latitude,
    this.longitude,
    this.shopOrFlatNo = '',
    this.buildingName = '',
    this.landmark = '',
    this.areaName = '',
    this.cityName = '',
    this.state = '',
    this.pincode,
    this.nearbyLandmarks = const [],
  });

  bool get isLocationCaptured =>
      latitude != null &&
      longitude != null &&
      latitude != 0.0 &&
      longitude != 0.0 &&
      latitude!.isFinite &&
      longitude!.isFinite;

  /// Combined shop/building address (e.g. "Shop 4, 1st Floor, ABC Complex")
  String get specificAddress {
    final parts = [shopOrFlatNo.trim(), buildingName.trim()]
        .where((p) => p.isNotEmpty);
    return parts.join(', ');
  }

  /// Full formatted preview address matching Web UI (e.g. "near Subway, Kothrud, Pune, Maharashtra")
  String get formattedAddress {
    final components = <String>[];
    if (specificAddress.isNotEmpty) components.add(specificAddress);
    if (landmark.trim().isNotEmpty) components.add('near ${landmark.trim()}');
    if (areaName.trim().isNotEmpty) components.add(areaName.trim());
    if (cityName.trim().isNotEmpty) components.add(cityName.trim());
    if (state.trim().isNotEmpty) components.add(state.trim());
    return components.join(', ');
  }

  SalonLocationDetails copyWith({
    double? latitude,
    double? longitude,
    String? shopOrFlatNo,
    String? buildingName,
    String? landmark,
    String? areaName,
    String? cityName,
    String? state,
    String? pincode,
    List<String>? nearbyLandmarks,
  }) {
    return SalonLocationDetails(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      shopOrFlatNo: shopOrFlatNo ?? this.shopOrFlatNo,
      buildingName: buildingName ?? this.buildingName,
      landmark: landmark ?? this.landmark,
      areaName: areaName ?? this.areaName,
      cityName: cityName ?? this.cityName,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      nearbyLandmarks: nearbyLandmarks ?? this.nearbyLandmarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'shopOrFlatNo': shopOrFlatNo,
      'buildingName': buildingName,
      'landmark': landmark,
      'areaName': areaName,
      'cityName': cityName,
      'state': state,
      if (pincode != null) 'pincode': pincode,
      'specificAddress': specificAddress,
      'nearbyLandmarks': nearbyLandmarks,
    };
  }

  factory SalonLocationDetails.fromJson(Map<String, dynamic> json) {
    final specific = (json['specificAddress'] ?? '').toString();
    String shopNo = json['shopOrFlatNo'] ?? '';
    String building = json['buildingName'] ?? '';

    if (shopNo.isEmpty && building.isEmpty && specific.isNotEmpty) {
      if (specific.contains(',')) {
        final parts = specific.split(',');
        shopNo = parts[0].trim();
        building = parts.sublist(1).join(',').trim();
      } else {
        shopNo = specific;
      }
    }

    final landmarksList = <String>[];
    if (json['nearbyLandmarks'] is List) {
      for (final item in (json['nearbyLandmarks'] as List)) {
        if (item != null && item.toString().trim().isNotEmpty) {
          landmarksList.add(item.toString().trim());
        }
      }
    }

    return SalonLocationDetails(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      shopOrFlatNo: shopNo,
      buildingName: building,
      landmark: json['landmark'] ?? '',
      areaName: json['areaName'] ?? json['area'] ?? '',
      cityName: json['cityName'] ?? json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode']?.toString(),
      nearbyLandmarks: landmarksList,
    );
  }
}
