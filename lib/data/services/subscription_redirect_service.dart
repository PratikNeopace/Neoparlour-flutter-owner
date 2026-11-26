import 'package:url_launcher/url_launcher.dart';

class SubscriptionRedirectService {
  static const String _webBaseUrl = "https://neoparlour.com/buy-subscription";

  /// Safely constructs the redirect URL and launches the default system browser.
  static Future<void> launchSubscriptionPortal({
    required String token,
    required String salonId,
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
  }) async {
    // 1. URL-encode parameters to prevent breaks with spaces or special characters
    final Map<String, String> queryParams = {
      'token': token,
      'ownerToken': token, // Added to prevent website JS crash
      'salonId': salonId,
      'name': ownerName,
      'email': ownerEmail,
      'phone': ownerPhone,
    };
    final String queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final Uri finalUri = Uri.parse('$_webBaseUrl?$queryString');
    
    // 2. Launch the default system browser externally
    if (await launchUrl(
      finalUri,
      mode: LaunchMode.externalApplication,
    )) {
      print("Launched subscription portal: $finalUri");
    } else {
      throw 'Could not launch subscription portal at $finalUri';
    }
  }
}
