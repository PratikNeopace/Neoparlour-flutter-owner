import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/firebase_options.dart';
import 'package:neo_parlour_owner/data/services/notification_service.dart';
import 'package:neo_parlour_owner/modules/pages/splash_screen_one.dart';
import 'package:neo_parlour_owner/providers/inventory_provider.dart';
import 'package:neo_parlour_owner/providers/staff_provider.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/appointment_provider.dart';
import 'package:neo_parlour_owner/providers/service_provider.dart';
import 'package:neo_parlour_owner/providers/feedback_provider.dart';
import 'package:neo_parlour_owner/providers/offer_provider.dart';
import 'package:neo_parlour_owner/providers/analytics_provider.dart';
import 'package:neo_parlour_owner/providers/notification_provider.dart';
import 'package:neo_parlour_owner/providers/package_provider.dart';
import 'package:neo_parlour_owner/providers/attendance_provider.dart';
import 'package:neo_parlour_owner/providers/product_provider.dart';
import 'package:neo_parlour_owner/providers/salon_provider.dart';
import 'package:neo_parlour_owner/providers/order_provider.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Background message received: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    NotificationService().initFCM(); 
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    debugPrint("If you are on Chrome, ensure you have configured Firebase for Web.");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ChangeNotifierProvider(create: (_) => OfferProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PackageProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SalonProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),

      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      home: const SplashOneScreen(),
    );
  }
}
