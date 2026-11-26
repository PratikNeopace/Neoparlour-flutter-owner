import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/maintenance_status.dart';
import 'package:neo_parlour_owner/modules/pages/owner_maintenance_screen.dart';

class OwnerMaintenanceInterceptor extends Interceptor {
  final GlobalKey<NavigatorState> navigatorKey;
  
  OwnerMaintenanceInterceptor({required this.navigatorKey});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Intercept HTTP 503 Service Unavailable or maintenance flag in payload
    if (err.response?.statusCode == 503 || (err.response?.data != null && err.response?.data is Map && err.response?.data['maintenance'] == true)) {
      final status = MaintenanceStatus.fromJson(err.response?.data is Map ? err.response?.data : {});
      
      // Redirect Salon Owner / Staff App globally to full-screen Maintenance View
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => OwnerMaintenanceScreen(status: status),
          ),
          (route) => false,
        );
      }
    }
    super.onError(err, handler);
  }
}
