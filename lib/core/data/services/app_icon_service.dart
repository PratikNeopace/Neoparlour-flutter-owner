import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class AppIconService {
  // Method Channel matching Owner MainActivity
  static const MethodChannel _channel = MethodChannel('com.neoparlour.owner/app_icon');

  static const String _prefActiveTheme = 'app_icon_active_theme';
  static const String _prefDiwaliPopupShown = 'app_icon_diwali_popup_shown';
  static const String _prefChristmasPopupShown = 'app_icon_christmas_popup_shown';
  static const String _prefNewYearPopupShown = 'app_icon_newyear_popup_shown';
  static const String _prefRevertPopupShown = 'app_icon_revert_popup_shown';

  /// Determines scheduled theme based on calendar date:
  /// 1. Diwali Festive: Nov 6 – Nov 21 (15 Days)
  /// 2. Classic Regular: Nov 22 – Dec 17 (Reverts to original)
  /// 3. Christmas Festive: Dec 18 – Dec 27 (10 Days)
  /// 4. New Year Festive: Dec 28 – Jan 6 (10 Days)
  /// 5. Classic Regular: Jan 7 onwards (Reverts to original)
  static String getScheduledTheme(DateTime now) {
    final month = now.month;
    final day = now.day;

    // New Year: Dec 28 to Jan 6 (10 days)
    if ((month == 12 && day >= 28) || (month == 1 && day <= 6)) {
      return 'newyear';
    }

    // Christmas: Dec 18 to Dec 27 (10 days)
    if (month == 12 && day >= 18 && day <= 27) {
      return 'christmas';
    }

    // Diwali: Nov 6 to Nov 21 (15 days)
    if (month == 11 && day <= 21) {
      return 'diwali';
    }

    // Regular Classic Launcher Icon
    return 'default';
  }

  /// Automatically checks and applies scheduled icon
  static Future<void> checkAndApplySeasonalIcon(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      final targetTheme = getScheduledTheme(now);
      final currentNativeIcon = await getCurrentIcon();

      if (targetTheme == 'diwali') {
        final diwaliPopupShown = prefs.getBool(_prefDiwaliPopupShown) ?? false;
        await prefs.setBool(_prefRevertPopupShown, false);

        if (currentNativeIcon != 'diwali') {
          final success = await _setNativeIcon('diwali');
          if (success) {
            await prefs.setString(_prefActiveTheme, 'diwali');
          }
        }

        if (!diwaliPopupShown && context.mounted) {
          await prefs.setBool(_prefDiwaliPopupShown, true);
          _showIconChangePopup(context, themeName: 'diwali');
        }
      } else if (targetTheme == 'christmas') {
        final christmasPopupShown = prefs.getBool(_prefChristmasPopupShown) ?? false;
        await prefs.setBool(_prefRevertPopupShown, false);

        if (currentNativeIcon != 'christmas') {
          final success = await _setNativeIcon('christmas');
          if (success) {
            await prefs.setString(_prefActiveTheme, 'christmas');
          }
        }

        if (!christmasPopupShown && context.mounted) {
          await prefs.setBool(_prefChristmasPopupShown, true);
          _showIconChangePopup(context, themeName: 'christmas');
        }
      } else if (targetTheme == 'newyear') {
        final newYearPopupShown = prefs.getBool(_prefNewYearPopupShown) ?? false;
        await prefs.setBool(_prefRevertPopupShown, false);

        if (currentNativeIcon != 'newyear') {
          final success = await _setNativeIcon('newyear');
          if (success) {
            await prefs.setString(_prefActiveTheme, 'newyear');
          }
        }

        if (!newYearPopupShown && context.mounted) {
          await prefs.setBool(_prefNewYearPopupShown, true);
          _showIconChangePopup(context, themeName: 'newyear');
        }
      } else {
        // Classic Default (Revert)
        if (currentNativeIcon != 'default') {
          final success = await _setNativeIcon('default');
          if (success) {
            await prefs.setString(_prefActiveTheme, 'default');
            final revertPopupShown = prefs.getBool(_prefRevertPopupShown) ?? false;
            if (!revertPopupShown && context.mounted) {
              await prefs.setBool(_prefRevertPopupShown, true);
              _showIconChangePopup(context, themeName: 'default');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error in AppIconService.checkAndApplySeasonalIcon: $e');
    }
  }

  /// Manually switch icon
  static Future<bool> switchIcon(
    BuildContext context,
    String iconName, {
    bool showPopup = true,
  }) async {
    try {
      final success = await _setNativeIcon(iconName);
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefActiveTheme, iconName);

        if (showPopup && context.mounted) {
          _showIconChangePopup(context, themeName: iconName);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error switching icon: $e');
      return false;
    }
  }

  static Future<bool> _setNativeIcon(String iconName) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('changeIcon', {
        'iconName': iconName,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('PlatformException changing app icon: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error calling changeIcon: $e');
      return false;
    }
  }

  static Future<String> getCurrentIcon() async {
    try {
      final String? result = await _channel.invokeMethod<String>('getCurrentIcon');
      return result ?? 'default';
    } catch (e) {
      return 'default';
    }
  }

  /// Exact Popup Dialog: "You changed the app icon"
  static void _showIconChangePopup(
    BuildContext context, {
    required String themeName,
  }) {
    if (!context.mounted) return;

    final isDiwali = themeName.toLowerCase() == 'diwali';
    final isChristmas = themeName.toLowerCase() == 'christmas';
    final isNewYear = themeName.toLowerCase() == 'newyear' || themeName.toLowerCase() == 'new_year';
    final isFestive = isDiwali || isChristmas || isNewYear;

    String subtitle;
    if (isDiwali) {
      subtitle = "We've activated the special Diwali festive icon for your app! It will automatically switch back to the original icon after 15 days.";
    } else if (isChristmas) {
      subtitle = "We've activated the special Christmas festive icon for your app! It will automatically switch back to the original icon after the holidays.";
    } else if (isNewYear) {
      subtitle = "We've activated the special Happy New Year festive icon for your app! It will automatically switch back to the original icon after the celebrations.";
    } else {
      subtitle = "The festive season has ended. Your app icon has switched back to the classic NeoParlour launcher.";
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isFestive ? const Color(0XFFFFECEB) : const Color(0XFFF5F5F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isChristmas
                    ? Icons.park
                    : (isNewYear
                        ? Icons.auto_awesome
                        : (isDiwali ? Icons.celebration : Icons.check_circle_outline)),
                color: isFestive ? const Color(0XFFFF0B01) : Colors.green.shade600,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "You changed the app icon",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: const Color(0XFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0XFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFFFF0B01),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  isFestive ? "Awesome! ✨" : "Got it",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
