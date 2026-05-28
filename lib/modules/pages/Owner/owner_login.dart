import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_register_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_login.dart';
import 'package:neo_parlour_owner/modules/pages/email_login_screen.dart';
import 'package:neo_parlour_owner/modules/pages/forgot_password_screen.dart';

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
  void dispose() {
    salonIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!isAgreeTerms || !isRememberMe) {
      FlushbarHelper.show(context, "Please accept all agreements to continue.");
      return;
    }

    if (salonIdController.text.isEmpty || passwordController.text.isEmpty) {
      FlushbarHelper.show(context, "Please enter both ID and Password");
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
                    color: const Color(0XFFFF7A58).withOpacity(0.25),
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
                          _buildTabItem("SALON OWNER", true, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SalonOwnerLoginScreen(),
                              ),
                            );
                          }),
                          SizedBox(width: w * 0.1),
                          _buildTabItem("STAFF", false, () {
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
                        hint: 'Salon ID or Email',
                        controller: salonIdController,
                        h: h,
                      ),

                      /// PASSWORD FIELD
                      _customInputField(
                        imageIcon: "assets/Images/LoginScreen/password.svg",
                        hint: 'Password',
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
                              : const Text(
                                  "LOGIN",
                                  style: TextStyle(
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
                          const Expanded(
                            child: Text(
                              "I agree to the Privacy Policy, Terms of Use And Terms of Service",
                              style: TextStyle(
                                color: Color(0XFF909090),
                                fontSize: 11,
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
                            child: const Text(
                              "I agree to receive marketing notifications with offers and news",
                              style: TextStyle(
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
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
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
                          style: const TextStyle(
                            color: Color(0XFF909090),
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: "Register",
                              style: const TextStyle(
                                color: Color(0XFFFF0B01),
                                fontWeight: FontWeight.bold,
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
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
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
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: const Color(0XFF909090),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,

          hintText: hint,
          hintStyle: const TextStyle(color: Color(0XFFADADAD), fontSize: 13),
          filled: true,
          fillColor: const Color(0XFFF9F9F9),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0XFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0XFFFF0B01)),
          ),
        ),
      ),
    );
  }

  /// SOCIAL ICON
  Widget _socialIcon(String imageIcon, Color bgColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: bgColor == Colors.white
              ? Border.all(color: const Color(0XFFE0E0E0))
              : null,
        ),
        child: Center(child: SvgPicture.asset(imageIcon, height: 22)),
      ),
    );
  }
}
