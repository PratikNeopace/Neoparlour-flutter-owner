import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/salon_location_model.dart';

class OwnerGeoService {
  static final OwnerGeoService _instance = OwnerGeoService._internal();
  factory OwnerGeoService() => _instance;

  late final Dio _dio;

  OwnerGeoService._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 7),
      receiveTimeout: const Duration(seconds: 7),
      headers: {
        'User-Agent': 'NeoParlourOwnerApp/1.0 (contact: info@neoparlour.com)',
      },
    ));
  }

  static const String olaMapsApiKey = 'Y651BNZSS9cTEe2eImXHTV5TNHDQo6fZ8Upv6xdM';

  // In-memory caches to prevent redundant network queries
  final Map<String, List<Map<String, dynamic>>> _searchCache = {};
  final Map<String, SalonLocationDetails> _reverseCache = {};

  // Sliding window rate limiter for Ola Maps: max 4 calls per 1-minute window
  final List<DateTime> _olaCallTimestamps = [];
  static const int maxOlaCallsPerMinute = 4;
  static const Duration olaRateLimitWindow = Duration(minutes: 1);

  bool get canCallOlaMaps {
    final now = DateTime.now();
    _olaCallTimestamps.removeWhere((ts) => now.difference(ts) >= olaRateLimitWindow);
    return _olaCallTimestamps.length < maxOlaCallsPerMinute;
  }

  void recordOlaCall() {
    _olaCallTimestamps.add(DateTime.now());
  }

  /// 1. Pan-India Forward Geocoding / Area Search
  /// Allows the owner to search any area, road, or landmark across India
  Future<List<Map<String, dynamic>>> searchSalonArea(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    final cacheKey = cleanQuery.toLowerCase();
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    try {
      final response = await _dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': cleanQuery,
          'limit': 10,
          'countrycode': 'in', // Pan-India search
        },
      );

      final dynamic data = response.data;
      final features = (data is Map && data['features'] is List)
          ? data['features'] as List
          : [];
      final results = <Map<String, dynamic>>[];
      final Set<String> seen = {};

      for (final f in features) {
        if (f is! Map) continue;
        final props = f['properties'] as Map<String, dynamic>? ?? {};
        final geom = f['geometry'] as Map<String, dynamic>? ?? {};
        final coords = geom['coordinates'] as List? ?? [0.0, 0.0];

        if (coords.length < 2) continue;
        final lon = (coords[0] as num).toDouble();
        final lat = (coords[1] as num).toDouble();

        if (!lat.isFinite || !lon.isFinite || lat < -90.0 || lat > 90.0 || lon < -180.0 || lon > 180.0) {
          continue;
        }

        final name = (props['name'] ?? props['street'] ?? '').toString().trim();
        final area = (props['district'] ?? props['suburb'] ?? props['locality'] ?? '').toString().trim();
        final city = (props['city'] ?? props['county'] ?? props['town'] ?? '').toString().trim();
        final state = (props['state'] ?? '').toString().trim();

        if (name.isNotEmpty || area.isNotEmpty || city.isNotEmpty) {
          final uniqueKey = '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}_${name.toLowerCase()}';
          if (!seen.contains(uniqueKey)) {
            seen.add(uniqueKey);
            results.add({
              'name': name.isNotEmpty ? name : (area.isNotEmpty ? area : city),
              'area': area,
              'city': city,
              'state': state,
              'lat': lat,
              'lng': lon,
            });
          }
        }
      }

      _searchCache[cacheKey] = results;
      return results;
    } catch (e) {
      debugPrint('OwnerGeoService area search error: $e');
      return [];
    }
  }

  /// 2. Reverse Geocode (Lat/Long -> Structured Salon Location)
  /// Uses Ola Maps Reverse Geocoding with Photon fallback & 4 calls/min rate limiter
  Future<SalonLocationDetails> reverseGeocode(double lat, double lng) async {
    if (!lat.isFinite || !lng.isFinite) {
      return SalonLocationDetails(latitude: lat, longitude: lng);
    }

    final cacheKey = '${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)}';
    if (_reverseCache.containsKey(cacheKey)) {
      return _reverseCache[cacheKey]!;
    }

    // 1. Try Ola Maps if within rate limit
    if (canCallOlaMaps) {
      try {
        recordOlaCall();
        final olaResult = await _reverseGeocodeWithOlaMaps(lat, lng);
        if (olaResult != null) {
          _reverseCache[cacheKey] = olaResult;
          return olaResult;
        }
      } catch (e) {
        debugPrint('OwnerGeoService Ola Maps reverse geocode error: $e. Falling back to Photon.');
      }
    } else {
      debugPrint(
        'OwnerGeoService: Ola Maps rate limit reached ($maxOlaCallsPerMinute calls/min). Calling Photon API.',
      );
    }

    // 2. Fallback to Photon Komoot Reverse Geocode
    try {
      final photonResult = await _reverseGeocodeWithPhoton(lat, lng);
      if (photonResult != null) {
        _reverseCache[cacheKey] = photonResult;
        return photonResult;
      }
    } catch (e) {
      debugPrint('OwnerGeoService Photon reverse geocode error: $e');
    }

    // 3. Fallback if both fail
    return SalonLocationDetails(
      latitude: lat,
      longitude: lng,
      areaName: 'Selected Location',
    );
  }

  /// Reverse geocode via Ola Maps Places API
  Future<SalonLocationDetails?> _reverseGeocodeWithOlaMaps(double lat, double lng) async {
    final response = await _dio.get(
      'https://api.olamaps.io/places/v1/reverse-geocode',
      queryParameters: {
        'latlng': '$lat,$lng',
        'api_key': olaMapsApiKey,
      },
    );

    final dynamic data = response.data;
    final results = (data is Map && data['results'] is List)
        ? data['results'] as List
        : [];

    if (results.isEmpty || results.first is! Map) return null;

    final res = results.first as Map<String, dynamic>;
    final addressComponents = (res['address_components'] is List)
        ? res['address_components'] as List
        : [];

    String area = '';
    String city = '';
    String state = '';
    String pincode = '';
    String shopNo = '';
    String building = '';
    String landmark = '';
    final List<String> detectedLandmarks = [];

    for (final comp in addressComponents) {
      if (comp is! Map) continue;
      final types = (comp['types'] is List) ? comp['types'] as List : [];
      final longName = (comp['long_name'] ?? comp['short_name'] ?? '').toString().trim();
      if (longName.isEmpty) continue;

      if (types.contains('sublocality_level_1') || types.contains('sublocality')) {
        if (area.isEmpty) area = longName;
      } else if (types.contains('locality')) {
        city = longName;
      } else if (types.contains('administrative_area_level_2') && city.isEmpty) {
        city = longName;
      } else if (types.contains('administrative_area_level_1')) {
        state = longName;
      } else if (types.contains('postal_code')) {
        pincode = longName;
      } else if (types.contains('point_of_interest') || types.contains('establishment')) {
        landmark = longName;
        detectedLandmarks.add(longName);
      }
    }

    // Look at other results for additional landmark candidates
    for (int i = 1; i < results.length && detectedLandmarks.length < 5; i++) {
      final r = results[i];
      if (r is Map && r['name'] != null && r['name'].toString().trim().isNotEmpty) {
        final cand = r['name'].toString().trim();
        if (!detectedLandmarks.contains(cand) && cand != area && cand != city) {
          detectedLandmarks.add(cand);
        }
      }
    }

    if (area.isEmpty && results.length > 1) {
      final second = results[1] as Map<String, dynamic>;
      final name = second['name']?.toString() ?? '';
      if (name.isNotEmpty && name != city) {
        area = name;
      }
    }

    return SalonLocationDetails(
      latitude: lat,
      longitude: lng,
      shopOrFlatNo: shopNo,
      buildingName: building,
      landmark: landmark.isNotEmpty ? landmark : (detectedLandmarks.isNotEmpty ? detectedLandmarks.first : ''),
      areaName: area.isNotEmpty ? area : city,
      cityName: city,
      state: state,
      pincode: pincode.isNotEmpty ? pincode : null,
      nearbyLandmarks: detectedLandmarks,
    );
  }

  /// Reverse geocode via Photon Komoot API
  Future<SalonLocationDetails?> _reverseGeocodeWithPhoton(double lat, double lng) async {
    final response = await _dio.get(
      'https://photon.komoot.io/reverse',
      queryParameters: {'lat': lat, 'lon': lng},
    );

    final dynamic data = response.data;
    final features = (data is Map && data['features'] is List)
        ? data['features'] as List
        : [];

    if (features.isEmpty || features.first is! Map) return null;

    final props = features.first['properties'] as Map<String, dynamic>? ?? {};

    String cleanCity = (props['city'] ?? props['town'] ?? '').toString().trim();
    if (cleanCity.isEmpty) {
      final rawCounty = (props['county'] ?? props['state_district'] ?? props['district'] ?? '').toString();
      cleanCity = rawCounty
          .replaceAll(RegExp(r'\b(subdistrict|district|city|division|corporation|municipal)\b', caseSensitive: false), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }

    String cleanArea = (props['district'] ?? props['suburb'] ?? props['locality'] ?? '').toString().trim();
    final String state = (props['state'] ?? '').toString().trim();
    final String pincode = (props['postcode'] ?? '').toString().trim();
    final String name = (props['name'] ?? props['street'] ?? '').toString().trim();

    final List<String> detectedLandmarks = [];
    if (name.isNotEmpty && name != cleanArea && name != cleanCity) {
      detectedLandmarks.add(name);
    }

    // Collect additional landmark candidates from features
    for (int i = 1; i < features.length && detectedLandmarks.length < 5; i++) {
      final f = features[i];
      if (f is Map && f['properties'] is Map) {
        final p = f['properties'] as Map<String, dynamic>;
        final n = (p['name'] ?? p['street'] ?? '').toString().trim();
        if (n.isNotEmpty && !detectedLandmarks.contains(n) && n != cleanArea && n != cleanCity) {
          detectedLandmarks.add(n);
        }
      }
    }

    return SalonLocationDetails(
      latitude: lat,
      longitude: lng,
      shopOrFlatNo: '',
      buildingName: '',
      landmark: detectedLandmarks.isNotEmpty ? detectedLandmarks.first : '',
      areaName: cleanArea.isNotEmpty ? cleanArea : (name.isNotEmpty ? name : cleanCity),
      cityName: cleanCity,
      state: state,
      pincode: pincode.isNotEmpty ? pincode : null,
      nearbyLandmarks: detectedLandmarks,
    );
  }
}
