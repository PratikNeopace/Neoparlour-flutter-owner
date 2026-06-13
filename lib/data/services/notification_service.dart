import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<PaginatedNotifications> fetchNotifications({
    required int salonId,
    String? status, // "sent", "pending", etc.
    String? type,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParameters = {
        'salonId': salonId,
        'status': ?status,
        'type': ?type,
        'page': page,
        'size': size,
      };

      final response = await _apiClient.get(
        'notifications/search',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return PaginatedNotifications.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch notifications: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> initFCM() async {
  debugPrint("Requesting FCM permissions...");
  await _fcm.requestPermission(alert: true, badge: true, sound: true);

  debugPrint("Initializing Local Notifications...");
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await _localNotifications.initialize(
    settings: settings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint("Notification tapped: ${response.payload}");
    },
  );

  debugPrint("Requesting Android permissions...");
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  debugPrint("Creating Notification Channel...");
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'owner_channel',
    'Owner Notifications',
    description: 'This channel is used for owner notifications.',
    importance: Importance.max,
  );

  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  debugPrint("Getting FCM Token...");
  try {
    String? vapidKey;
    if (kIsWeb) {
      vapidKey = "BIdYnU3B7lY_U7wKzUv3Qv7Jv_Z_qX_L7_X_z_v_x_Z_Y";
    }

    final token = await _fcm.getToken(vapidKey: vapidKey);
    debugPrint("FCM TOKEN (RAW) => $token");

    if (token != null) {
      await _registerToken(token);
    }
  } catch (e) {
    debugPrint("NON-FATAL: Error getting FCM token: $e");
  }


  FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);
  FirebaseMessaging.onMessage.listen(_showForegroundNotification);
}

Future<void> _registerToken(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    
    if (userId != null) {
      // Use the profile update endpoint as confirmed by UserDTO
      await _apiClient.put(
        "auth/users/$userId",
        data: {"fcmToken": token},
      );
      debugPrint("FCM Token registered successfully for user $userId");
    } else {
      // Fallback for registration flow
      debugPrint("No user ID found, skipping token registration");
    }
  } catch (e) {
    debugPrint("Token registration failed: $e");
  }
}

Future<void> _showForegroundNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'owner_channel',
    'Owner Notifications',
    channelDescription: 'This channel is used for owner notifications.',
    importance: Importance.max,
    priority: Priority.high,
  );

  await _localNotifications.show(
    id: 0,
    title: message.notification?.title ?? "Neo Parlour",
    body: message.notification?.body ?? "",
    notificationDetails: NotificationDetails(android: androidDetails),
    payload: jsonEncode(message.data),
  );
}
}
