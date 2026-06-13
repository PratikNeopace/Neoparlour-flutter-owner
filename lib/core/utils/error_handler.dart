import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';

class ErrorHandler {
  static String parseError(dynamic e) {
    if (e is DioException) {
      return ApiClient.handleDioError(e);
    }
    final str = e.toString();
    if (str.contains('Failed host lookup') || 
        str.contains('SocketException') || 
        str.contains('Network is unreachable') || 
        str.contains('Connection refused')) {
      return "Please check your internet connection and try again.";
    }
    return str.replaceAll('Exception: ', '');
  }
}
