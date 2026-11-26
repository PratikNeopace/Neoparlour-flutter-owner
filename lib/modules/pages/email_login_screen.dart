import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';
import 'package:neo_parlour_owner/widgets/language_selector_button.dart';

class EmailLoginScreen extends StatelessWidget {
  const EmailLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Language Selector
            const SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20, top: 10),
                  child: LanguageSelectorButton(),
                ),
              ),
            ),
            // 🔹 Header with S-Curve
            Stack(
              children: [
                ClipPath(
                  clipper: HeaderCurveClipper(),
                  child: Container(
                    height: 225,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/Images/EmailLoginScreen/background_image.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0XFF8B8B8B),
                            Colors.transparent,
                            Color(0XFFFF3502),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 30,
                  child: Text(
                    AppLocalizations.of(context)!.loginTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // Login Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(context)!.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0XFF8B8989),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _socialButton(
                    AppLocalizations.of(context)!.continueWithGoogle,
                    "assets/Images/EmailLoginScreen/google_logo.svg",
                  ),

                  const SizedBox(height: 15),

                  _socialButton(
                    AppLocalizations.of(context)!.continueWithFacebook,
                    "assets/Images/EmailLoginScreen/facebook_logo.svg",
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          AppLocalizations.of(context)!.or,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 📧 Email Input
                  TextField(
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.emailAddress,
                      filled: true,
                      fillColor: const Color(0XFFF8F8F8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0XFF909090)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔴 Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: () {
                      //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SalonIDScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFFFF0B01),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.continueBtn,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 127 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Social Login Button
  Widget _socialButton(String text, String imagePath) {
    return GestureDetector(
      onTap: (){
        
      },
      child: Container(
        width: double.infinity,
        height: 49,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0XFF909090)),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(imagePath, height: 20, width: 20),
            const SizedBox(width: 43),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Custom Clipper for Header Curve
class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.55, size.height);

    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height * 0.35,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}