import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SearchService {
  /// Search for locations using Komoot Photon Autocomplete geocoding API (OSM backed)
  Future<List<Map<String, dynamic>>> searchExternalLocations(
    String query, {
    String featureClass = '',
    String cityName = '',
    String stateName = '',
  }) async {
    if (query.trim().length < 2) return [];

    String normalizeCity(String name) {
      final lower = name.toLowerCase().trim();
      if (lower == 'bangalore' || lower == 'bengaluru') return 'bengaluru';
      if (lower == 'mumbai' || lower == 'bombay') return 'mumbai';
      if (lower == 'calcutta' || lower == 'kolkata') return 'kolkata';
      if (lower == 'madras' || lower == 'chennai') return 'chennai';
      return lower;
    }

    try {
      String searchQuery = query;
      if (featureClass == 'city' && stateName.isNotEmpty) {
        searchQuery = '$query $stateName';
      } else if (featureClass == 'area') {
        searchQuery = '$query';
        if (cityName.isNotEmpty) searchQuery += ' $cityName';
        if (stateName.isNotEmpty) searchQuery += ' $stateName';
      }

      final dioClient = Dio();
      dioClient.options.headers['User-Agent'] =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

      final response = await dioClient.get(
        'https://photon.komoot.io/api',
        queryParameters: {
          'q': searchQuery,
          'countrycode': 'in',
          'limit': 15,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }
      final List<dynamic> features = responseData['features'] ?? [];
      final List<Map<String, dynamic>> results = [];
      final Set<String> seen = {};

      for (final feature in features) {
        final Map<String, dynamic> props = feature['properties'] ?? {};

        if (stateName.isNotEmpty) {
          final String featureState = props['state'] ?? '';
          if (featureState.toLowerCase() != stateName.toLowerCase() && !featureState.toLowerCase().contains(stateName.toLowerCase())) {
            continue;
          }
        }

        final String city = props['city'] ?? props['town'] ?? props['district'] ?? props['state_district'] ?? props['county'] ?? '';
        final String rawName = props['name'] ?? '';
        final String cleanName = rawName.split(',').first.trim();

        if (featureClass == 'city') {
          final String matchedCity = props['city'] ?? ((props['osm_value'] == 'city' || props['osm_value'] == 'town') ? props['name'] : '');
          if (matchedCity.isNotEmpty && !seen.contains(matchedCity.toLowerCase())) {
            final normCity = matchedCity.toLowerCase();
            final normQuery = query.toLowerCase().trim();

            if (normCity.contains(normQuery)) {
              seen.add(matchedCity.toLowerCase());
              results.add({'name': matchedCity, 'type': 'city'});
            }
          }
        } else if (featureClass == 'area') {
          final normSelectedCity = normalizeCity(cityName);

          final List<String?> checkList = [
            props['city'],
            props['town'],
            props['district'],
            props['state_district'],
            props['county'],
            props['state'],
            rawName,
          ];
          final bool matchesCity = cityName.isEmpty || checkList.any((val) => val != null && normalizeCity(val).contains(normSelectedCity));

          if (cleanName.toLowerCase() == cityName.toLowerCase()) {
            continue;
          }

          if (cleanName.isNotEmpty && matchesCity) {
            final String subLocality = props['district'] ?? props['locality'] ?? props['suburb'] ?? '';
            final String parentCity = city.isNotEmpty && normalizeCity(city) != normSelectedCity ? '$city, $cityName' : (city.isNotEmpty ? city : cityName);
            final String displayCity = subLocality.isNotEmpty ? '$subLocality, $parentCity' : parentCity;

            final uniqueKey = '${cleanName.toLowerCase()}_${displayCity.toLowerCase()}';
            if (!seen.contains(uniqueKey)) {
              seen.add(uniqueKey);
              results.add({
                'name': cleanName,
                'city': displayCity,
                'district': subLocality,
                'type': 'area',
              });
            }
          }
        } else {
          if (cleanName.isNotEmpty) {
            final String label = city.isNotEmpty ? '$cleanName, $city' : cleanName;
            if (!seen.contains(label.toLowerCase())) {
              seen.add(label.toLowerCase());
              results.add({'label': label, 'city': city, 'area': cleanName});
            }
          }
        }
      }

      final String lowerQuery = query.toLowerCase().trim();
      results.sort((a, b) {
        final String nameA = ((a['name'] ?? a['label'] ?? '') as String).toLowerCase();
        final String nameB = ((b['name'] ?? b['label'] ?? '') as String).toLowerCase();

        final bool startsA = nameA.startsWith(lowerQuery);
        final bool startsB = nameB.startsWith(lowerQuery);

        if (startsA && !startsB) return -1;
        if (!startsA && startsB) return 1;

        final bool containsA = nameA.contains(lowerQuery);
        final bool containsB = nameB.contains(lowerQuery);

        if (containsA && !containsB) return -1;
        if (!containsA && containsB) return 1;

        return 0;
      });

      return results;
    } catch (error) {
      debugPrint('Error searching external locations via Photon: $error');
      return [];
    }
  }

  /// Search for landmarks using a multi-pass parallel strategy
  Future<List<Map<String, dynamic>>> searchLandmarks(
    String query, {
    required String cityName,
    required String stateName,
    required String areaName,
    String districtName = '',
  }) async {
    if (query.trim().length < 2) return [];

    try {
      final dioClient = Dio();
      dioClient.options.headers['User-Agent'] = 'NeoParlourApp/1.0';

      String combinedArea = areaName;
      if (districtName.isNotEmpty && districtName.toLowerCase() != areaName.toLowerCase()) {
        combinedArea = '$areaName $districtName';
      }

      final queries = [
        '$query $combinedArea $cityName $stateName'.trim().replaceAll(RegExp(r'\s+'), ' '),
        '$query $cityName $stateName'.trim().replaceAll(RegExp(r'\s+'), ' '),
      ];

      final futures = queries.map((q) => dioClient.get(
            'https://photon.komoot.io/api',
            queryParameters: {
              'q': q,
              'countrycode': 'in',
              'limit': 15,
            },
          ));

      final responses = await Future.wait(futures);
      final List<Map<String, dynamic>> results = [];
      final Set<String> seen = {};

      for (var response in responses) {
        var data = response.data;
        if (data is String) data = jsonDecode(data);
        final features = data['features'] ?? [];
        
        for (final feature in features) {
          final props = feature['properties'] ?? {};
          
          if (stateName.isNotEmpty) {
            final String featureState = props['state'] ?? '';
            if (featureState.toLowerCase() != stateName.toLowerCase() && !featureState.toLowerCase().contains(stateName.toLowerCase())) {
              continue;
            }
          }

          final rawName = props['name'] ?? '';
          if (rawName.isEmpty) continue;
          
          final cleanName = rawName.split(',').first.trim();
          if (seen.contains(cleanName.toLowerCase())) continue;
          
          seen.add(cleanName.toLowerCase());
          
          int rankScore = 0;
          final String propsStr = props.toString().toLowerCase();
          
          // Boost scores if they explicitly contain the city or area
          if (areaName.isNotEmpty && propsStr.contains(areaName.toLowerCase())) rankScore += 10;
          if (cityName.isNotEmpty && propsStr.contains(cityName.toLowerCase())) rankScore += 5;
          
          results.add({
            'name': cleanName,
            'city': props['city'] ?? props['district'] ?? cityName,
            'rankScore': rankScore,
          });
        }
      }

      results.sort((a, b) => (b['rankScore'] as int).compareTo(a['rankScore'] as int));
      return results;

    } catch (error) {
      debugPrint('Error searching landmarks via Photon: $error');
      return [];
    }
  }

  /// Reverse Geocoding to get City, Area, State from Coordinates
  Future<Map<String, String>?> reverseGeocode(double lat, double lon) async {
    try {
      final dioClient = Dio();
      dioClient.options.headers['User-Agent'] = 'NeoParlourApp/1.0';
      final response = await dioClient.get(
        'https://photon.komoot.io/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
        },
      );
      
      var data = response.data;
      if (data is String) data = jsonDecode(data);
      
      final features = data['features'] ?? [];
      if (features.isEmpty) return null;
      
      final props = features.first['properties'] ?? {};
      
      String cleanCity = props['city'] ?? props['town'] ?? '';
      if (cleanCity.isEmpty) {
        final rawCounty = props['county'] ?? props['state_district'] ?? props['district'] ?? '';
        cleanCity = rawCounty
            .replaceAll(RegExp(r'\b(subdistrict|district|city|division|corporation|municipal)\b', caseSensitive: false), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
      }

      String cleanArea = props['locality'] ?? props['suburb'] ?? props['district'] ?? props['name'] ?? props['street'] ?? '';
      final String state = props['state'] ?? '';
      
      return {
        'city': cleanCity,
        'area': cleanArea,
        'state': state,
      };
    } catch (error) {
      debugPrint('Reverse Geocoding error: $error');
      return null;
    }
  }
}
