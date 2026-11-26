import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:neo_parlour_owner/modules/pages/splash_screen_two.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/maintenance_status.dart';
import 'package:neo_parlour_owner/modules/pages/owner_maintenance_screen.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';
import 'package:neo_parlour_owner/core/data/services/app_icon_service.dart';

class SplashOneScreen extends StatefulWidget {
  const SplashOneScreen({super.key});

  @override
  State<SplashOneScreen> createState() => _SplashOneScreenState();
}

class _SplashOneScreenState extends State<SplashOneScreen> {
  Timer? _timer;
  bool _isNavigated = false;
  Color skipColor = const Color(0XFF505050);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppIconService.checkAndApplySeasonalIcon(context);
    });
    _timer = Timer(const Duration(seconds: 3), _navigateToNext);
  }

  Future<void> _checkMaintenanceOnLaunch() async {
    try {
      final dio = ApiClient().dio;
      final response = await dio.get('${ApiClient.baseUrl}v1/maintenance/status');
      final status = MaintenanceStatus.fromJson(response.data);
      
      if (status.enabled) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => OwnerMaintenanceScreen(status: status)),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Continue normal startup flow if check fails or no maintenance
    }
  }

  Future<bool> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
          return true;
        } else if (info.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
          return false;
        }
      }
    } catch (e) {
      debugPrint("InAppUpdate Error: \$e");
    }
    return false;
  }

  Future<void> _navigateToNext() async {
    _isNavigated = true;
    _timer?.cancel();
    
    await _checkMaintenanceOnLaunch();
    // If we navigated to maintenance, we shouldn't proceed
    if (!mounted) return;

    bool isUpdating = await _checkForUpdate();
    if (isUpdating) return;
    
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashTwoScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final containerHeight = (size.height * 0.28).clamp(180.0, 260.0);
    final topFontSize = (size.width * 0.06).clamp(18.0, 26.0);
    final mainFontSize = (size.width * 0.12).clamp(36.0, 54.0);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset(
            'assets/Images/SplashScreen/splash_screen_one_bg.jpg',
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),

          // 2. Logo
          Positioned(
            top: size.height * 0.33,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                'assets/Images/SplashScreen/neo_parlour_logo.svg',
                height: size.height * 0.14,
              ),
            ),
          ),

          // 3. Bottom Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width * 0.92,
              height: containerHeight + bottomPadding,
              padding: EdgeInsets.only(
                left: size.width * 0.06,
                right: size.width * 0.06,
                top: size.height * 0.025,
                bottom: bottomPadding + 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7A58).withValues(alpha: 0.35),
                    blurRadius: 60,
                    spreadRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.splashOneTop,
                    style: GoogleFonts.habibi(
                      fontSize: topFontSize,
                      height: 1.0,
                      color: const Color(0XFF626262),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppLocalizations.of(context)!.splashOneMid,
                      maxLines: 1,
                      softWrap: false,
                      style: GoogleFonts.imbue(
                        fontSize: mainFontSize,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFF5000),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.splashOneBottom,
                    style: GoogleFonts.habibi(
                      fontSize: topFontSize,
                      color: const Color(0XFF626262),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() => skipColor = const Color(0XFFFF0B01));
                      Future.delayed(const Duration(milliseconds: 200), _navigateToNext);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.skipSplash,
                            style: GoogleFonts.poppins(
                              color: skipColor,
                              fontSize: (size.width * 0.045).clamp(14.0, 20.0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color(0XFFC1BDBD),
                          ),
                        ],
                      ),
                    ),
                  ),
                   Text(
                      AppLocalizations.of(context)!.versionFooter,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0XFF626262),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
