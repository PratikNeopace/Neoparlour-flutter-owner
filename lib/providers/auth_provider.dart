import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:neo_parlour_owner/data/models/auth_response.dart';
import 'package:neo_parlour_owner/data/services/auth_service.dart';
import 'package:neo_parlour_owner/data/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthResponse? _user;
  AuthResponse? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? fcmToken;
      try {
        String? vapidKey;
        if (kIsWeb) {
          vapidKey = "BIdYnU3B7lY_U7wKzUv3Qv7Jv_Z_qX_L7_X_z_v_x_Z_Y";
        }
        fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
        debugPrint("LOGIN FCM TOKEN (RAW) => $fcmToken");
      } catch (e) {
        debugPrint("Non-fatal error getting FCM token during login: $e");
      }


      final response = await _authService.login(username, password, fcmToken: fcmToken);
      _user = response;
      
      final prefs = await SharedPreferences.getInstance();
      // Clear previous session safely
      await prefs.remove('token');
      await prefs.remove('role');
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_role');

      // Determine explicit role
      String role = 'owner';
      final apiRole = response.role.toUpperCase();
      if (apiRole == 'STAFF' || 
          apiRole == 'SALON_STAFF' || 
          apiRole == 'ROLE_STAFF' || 
          apiRole == 'ROLE_SALON_STAFF') {
        role = 'staff';
      }

      // Save new session
      await prefs.setString('token', response.token);
      await prefs.setString('auth_token', response.token); // Keep for ApiClient backward compatibility
      await prefs.setString('role', role);
      await prefs.setInt('user_id', response.id);
      await prefs.setString('user_role', response.role);
      
      // Initialize FCM after successful login to ensure token is registered with auth
      NotificationService().initFCM();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> initializeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('auth_token');
    final userId = prefs.getInt('user_id');
    
    if (token != null && userId != null) {
      await fetchProfile(userId);
    }
  }

  Future<void> fetchProfile(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role') ?? 'owner';
      
      AuthResponse profile;
      if (role == 'staff') {
        profile = await _authService.getStaffProfile(userId);
      } else {
        profile = await _authService.getProfile(userId);
      }
      
      // CRITICAL: Preserve the original userId to prevent ID-switching bugs
      _user = profile.copyWith(id: userId);
    } catch (e) {
      _errorMessage = ErrorHandler.parseError(e);
      if (e.toString().contains('401')) {
        await logout();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout API failed: $e');
    }
    
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    notifyListeners();
  }

  Future<bool> sendForgotPasswordOtp(String mobile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendForgotPasswordOtp(mobile);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String mobile,
    required String otp,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(
        mobile: mobile,
        otp: otp,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.parseError(e);
      notifyListeners();
      return false;
    }
  }
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role') ?? 'owner';
      
      AuthResponse updatedUser;
      if (role == 'staff') {
        updatedUser = await _authService.updateStaffProfile(_user!.id, data);
      } else {
        updatedUser = await _authService.updateProfile(_user!.id, data);
      }
      
      // CRITICAL: Preserve the original userId (login ID) to prevent ID-jumping
      _user = updatedUser.copyWith(id: _user!.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.parseError(e);
      notifyListeners();
      return false;
    }
  }
  Future<bool> refreshToken() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.refreshToken();
      _user = response;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token);
      await prefs.setString('auth_token', response.token);
      await prefs.setInt('user_id', response.id);
      await prefs.setString('user_role', response.role);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.deleteAccount(_user!.id);
      await logout(); // Clear session after deletion
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.parseError(e);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
