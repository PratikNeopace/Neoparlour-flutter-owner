import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/modules/pages/splash_screen_three.dart';

class SplashTwoScreen extends StatefulWidget {
  const SplashTwoScreen({super.key});

  @override
  State<SplashTwoScreen> createState() => _SplashTwoScreenState();
}

class _SplashTwoScreenState extends State<SplashTwoScreen> {
  Timer? _timer;
  bool _isNavigated = false;
  Color skipColor = const Color(0XFF505050);

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _navigateToNext);
  }

  void _navigateToNext() {
    if (_isNavigated) return;
    _isNavigated = true;
    _timer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashThreeScreen()),
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
    final mainFontSize = (size.width * 0.11).clamp(36.0, 54.0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Images/SplashScreen/splash_screen_two_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.white.withValues(alpha:0.1),
              )
            ),
          ),

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
                    "Your",
                    style: GoogleFonts.habibi(
                      fontSize: topFontSize,
                      height: 1.0,
                      color: const Color(0XFF626262),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "PARLOUR",
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
                    "Platter",
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
                            "Skip",
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
                      "Version 1.0.0 | Powered By Neopaceinfotech LLP",
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
