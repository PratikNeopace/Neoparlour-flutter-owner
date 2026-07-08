import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://sb.neoparlour.com/api/';
  late Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    debugPrint('DEBUG: ApiClient initialized with baseUrl: $baseUrl');

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token') ?? prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // You can handle global errors here (e.g., 401 logging out)
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> post(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.post(endpoint, data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      debugPrint('DEBUG: API GET request to $endpoint with params $queryParameters');
      final response = await dio.get(endpoint, queryParameters: queryParameters, options: options);
      debugPrint('DEBUG: API Response status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('DEBUG: API GET request failed: $e');
      rethrow;
    }
  }

  Future<Response> put(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.put(endpoint, data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String endpoint, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.delete(endpoint, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.patch(endpoint, data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  static String handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout || 
        e.type == DioExceptionType.sendTimeout) {
      return "Connection timed out. Please check your internet connection and try again.";
    }
    if (e.type == DioExceptionType.connectionError) {
      return "No internet connection. Please check your network and try again.";
    }

    if (e.response?.statusCode == 500) {
      return "Something went wrong on the server. Please try again later.";
    }
    String message = 'Something went wrong';
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data.containsKey('message')) {
          message = data['message'].toString();
        } else if (data.containsKey('msg')) {
          message = data['msg'].toString();
        } else if (data.containsKey('error')) {
          message = data['error'].toString();
        } else if (data.containsKey('success')) {
          message = data['success'].toString();
        } else if (data.containsKey('status')) {
          message = data['status'].toString();
        } else if (data.containsKey('data') && data['data'] is String) {
          message = data['data'].toString();
        } else {
          message = data.toString();
        }
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            if (decoded.containsKey('message')) {
              message = decoded['message'].toString();
            } else if (decoded.containsKey('msg')) {
              message = decoded['msg'].toString();
            } else if (decoded.containsKey('error')) {
              message = decoded['error'].toString();
            } else {
              message = data;
            }
          } else {
            message = data;
          }
        } catch (_) {
          message = data;
        }
      } else if (data is List && data.isNotEmpty) {
        message = data.first.toString();
      } else {
        message = data.toString();
      }
    } else if (e.message != null && e.message!.isNotEmpty) {
      message = e.message!;
    }
    return message;
  }
}
