import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_register_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_login.dart';
import 'package:neo_parlour_owner/modules/pages/forgot_password_screen.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';
import 'package:neo_parlour_owner/widgets/language_selector_button.dart';
import 'package:neo_parlour_owner/core/data/services/app_icon_service.dart';

class SalonOwnerLoginScreen extends StatefulWidget {
  const SalonOwnerLoginScreen({super.key});

  @override
  State<SalonOwnerLoginScreen> createState() => _SalonOwnerLoginScreenState();
}

class _SalonOwnerLoginScreenState extends State<SalonOwnerLoginScreen> {
  bool isRememberMe = false;
  bool _isPasswordVisible = false;
  bool isAgreeTerms = false;

  final TextEditingController salonIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppIconService.checkAndApplySeasonalIcon(context);
    });
  }

  @override
  void dispose() {
    salonIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  Future<void> openOwnerTerms() async {
    final Uri url = Uri.parse(
      'https://www.neoparlour.com/owner/terms-and-conditions',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> openOwnerPrivacy() async {
    final Uri url = Uri.parse(
      'https://www.neoparlour.com/owner/privacy-policy',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!isAgreeTerms || !isRememberMe) {
      FlushbarHelper.show(context, AppLocalizations.of(context)!.pleaseAcceptAgreements);
      return;
    }

    if (salonIdController.text.isEmpty || passwordController.text.isEmpty) {
      FlushbarHelper.show(context, AppLocalizations.of(context)!.pleaseEnterIdAndPassword);
      return;
    }

    final success = await authProvider.login(
      salonIdController.text,
      passwordController.text,
    );

    if (success) {
      if (!mounted) return;
      final role = authProvider.user?.role;
      if (role == 'SALON_OWNER' || role == 'OWNER') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
        );
      } else if (role == 'STAFF' || role == 'SALON_STAFF') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeStaffScreen()),
        );
      }
    } else {
      if (!mounted) return;
      FlushbarHelper.show(context, authProvider.errorMessage ?? "Login Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double h = size.height;
    final double w = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// FULL SCREEN BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/Images/LoginScreen/salon_owner_bg_image.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// FLOATING LOGIN CARD
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: w * 0.05),
              padding: EdgeInsets.fromLTRB(
                w * 0.08,
                h * 0.04,
                w * 0.08,
                h * 0.03,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0XFFFF7A58).withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: 5,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Tabs (Salon Owner Active)
                      Row(
                        children: [
                          _buildTabItem(AppLocalizations.of(context)!.salonOwnerTab, true, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SalonOwnerLoginScreen(),
                              ),
                            );
                          }),
                          SizedBox(width: w * 0.1),
                          _buildTabItem(AppLocalizations.of(context)!.staffTab, false, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StaffLoginScreen(),
                              ),
                            );
                          }),
                        ],
                      ),

                      SizedBox(height: h * 0.04),

                      /// Salon ID FIELD
                      _customInputField(
                        imageIcon: "assets/Images/LoginScreen/call.svg",
                        hint: AppLocalizations.of(context)!.mobileOrEmail,
                        controller: salonIdController,
                        h: h,
                      ),

                      /// PASSWORD FIELD
                      _customInputField(
                        imageIcon: "assets/Images/LoginScreen/password.svg",
                        hint: AppLocalizations.of(context)!.password,
                        controller: passwordController,
                        obscure: !_isPasswordVisible,
                        isPassword: true,
                        h: h,
                      ),

                      SizedBox(height: h * 0.01),

                      /// LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: h * 0.065,
                        child: ElevatedButton(
                          onPressed:
                              context.watch<AuthProvider>().isLoading ||
                                  !isAgreeTerms ||
                                  !isRememberMe
                              ? null
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFFFF0B01),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: context.watch<AuthProvider>().isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  AppLocalizations.of(context)!.loginTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 14,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: h * 0.015),

                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: isAgreeTerms,
                              activeColor: const Color(0XFFFF0B01),
                              onChanged: (v) {
                                setState(() => isAgreeTerms = v!);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Color(0XFF909090),
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                ),
                                children: [
                                  TextSpan(text: AppLocalizations.of(context)!.iAgreeToThe),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.privacyPolicy,
                                    style: const TextStyle(
                                      color: Color(0XFFFF0B01),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = openOwnerPrivacy,
                                  ),
                                  TextSpan(text: AppLocalizations.of(context)!.comma),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.termsOfUse,
                                    style: const TextStyle(
                                      color: Color(0XFFFF0B01),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = openOwnerTerms,
                                  ),
                                  TextSpan(text: AppLocalizations.of(context)!.and),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.termsOfService,
                                    style: const TextStyle(
                                      color: Color(0XFFFF0B01),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = openOwnerTerms,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: h * 0.015),

                      /// REMEMBER ME
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: isRememberMe,
                              activeColor: const Color(0XFFFF0B01),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (v) =>
                                  setState(() => isRememberMe = v!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.iAgreeMarketing,
                              style: const TextStyle(
                                color: Color(0XFF909090),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.forgotPassword,
                          style: const TextStyle(
                            color: Color(0XFFFF0B01),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: h * 0.02),

                      /// Register
                      RichText(
                        text: TextSpan(
                          text: AppLocalizations.of(context)!.dontHaveAccount,
                          style: const TextStyle(
                            color: Color(0XFF141414),
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)!.register,
                              style: const TextStyle(
                                color: Color(0XFFFF0B01),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OwnerRegisterScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.02),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// TAB
  Widget _buildTabItem(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.black : const Color(0XFFADADAD),
              ),
            ),
            const SizedBox(height: 6),

            /// Dynamic underline (auto text width)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3,
              width: double.infinity, // ← full text width
              decoration: BoxDecoration(
                color: isActive ? const Color(0XFFFF0B01) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INPUT FIELD
  Widget _customInputField({
    required String imageIcon,
    required String hint,
    required TextEditingController controller,
    required double h,
    bool obscure = false,
    bool isPassword = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.02),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final text = value.text;
          // If it only contains digits (or is empty and the user might type digits),
          // actually, let's just say if it matches numbers only, max length 10, else 50.
          // Wait, if they start typing numbers, it's 10. If they type a letter, it's 50.
          final isNumber = RegExp(r'^[0-9]*$').hasMatch(text);
          final maxLength = isNumber ? 10 : 50;
          
          return TextField(
            controller: controller,
            obscureText: obscure,
            maxLength: isPassword ? null : maxLength,
            decoration: InputDecoration(
              counterText: "", // Hide the length counter
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: SvgPicture.asset(imageIcon),
                ),
              ),

              // EYE ICON HERE
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0XFFADADAD),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,

              filled: true,
              fillColor: const Color(0XFFF9F9F9),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0XFFADADAD),
                fontSize: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0XFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0XFFFF0B01)),
              ),
            ),
          );
        },
      ),
    );
  }

  /// SOCIAL ICON

}
