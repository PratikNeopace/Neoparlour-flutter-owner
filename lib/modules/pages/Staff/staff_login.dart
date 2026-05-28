import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_login.dart';
import 'package:neo_parlour_owner/modules/pages/email_login_screen.dart';
import 'package:neo_parlour_owner/modules/pages/forgot_password_screen.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:provider/provider.dart';

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  bool isRememberMe = false;
  bool isPasswordVisible = false;

  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    accountController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    debugPrint("Staff Login Attempt: ${accountController.text}");
    FlushbarHelper.show(context, "Logging in...");
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (accountController.text.isEmpty || passwordController.text.isEmpty) {
      FlushbarHelper.show(context, "Please enter both Account and Password");
      return;
    }

    final success = await authProvider.login(
      accountController.text,
      passwordController.text,
    );

    if (success) {
      if (!mounted) return;
      final role = authProvider.user?.role.toUpperCase();
      // Consistent with owner_login.dart role checks + common ROLE_ prefixes
      if (role == 'STAFF' ||
          role == 'SALON_STAFF' ||
          role == 'ROLE_STAFF' ||
          role == 'ROLE_SALON_STAFF') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeStaffScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        FlushbarHelper.show(context, "Access Denied: Current role is $role");
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
          //  FULL SCREEN BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/Images/LoginScreen/staff_bg_image.jpg',
              fit: BoxFit.cover,
            ),
          ),

          //  FLOATING LOGIN CARD
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
                      /// Tabs
                      Row(
                        children: [
                          _buildTabItem("SALON OWNER", false, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const SalonOwnerLoginScreen(),
                              ),
                            );
                          }),
                          SizedBox(width: w * 0.1),
                          _buildTabItem("STAFF", true, () {
                            // Already on staff screen
                          }),
                        ],
                      ),

                      SizedBox(height: h * 0.04),

                      /// Inputs
                      _customInputField(
                        imageIcon: "assets/Images/LoginScreen/call.svg",
                        hint: 'Email Or Mobile Number',
                        controller: accountController,
                        h: h,
                      ),

                      _customInputField(
                        imageIcon: "assets/Images/LoginScreen/password.svg",
                        hint: 'Password',
                        controller: passwordController,
                        obscure: !isPasswordVisible,
                        h: h,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0XFF909090),
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),

                      SizedBox(height: h * 0.01),

                      /// Login Button
                      SizedBox(
                        width: double.infinity,
                        height: h * 0.065,
                        child: ElevatedButton(
                          onPressed: context.watch<AuthProvider>().isLoading || !isRememberMe
                              ? null
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRememberMe ?  const Color(0XFFFF0B01) : Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: context.watch<AuthProvider>().isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
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

                      /// Remember Me
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
                          const Text(
                            "Remember me next time",
                            style: TextStyle(
                              color: Color(0XFF909090),
                              fontSize: 11,
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

  Widget _buildTabItem(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
          Container(
            height: 3,
            width: 45,
            decoration: BoxDecoration(
              color: isActive ? const Color(0XFFFF0B01) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customInputField({
    required String imageIcon,
    required String hint,
    required TextEditingController controller,
    required double h,
    bool obscure = false,
    Widget? suffixIcon,
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
              child: SvgPicture.asset(
                imageIcon,
                colorFilter: const ColorFilter.mode(
                  Color(0XFF909090),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          suffixIcon: suffixIcon,

          hintText: hint,
          hintStyle: const TextStyle(color: Color(0XFFADADAD), fontSize: 13),
          filled: true,
          fillColor: const Color(0XFFF9F9F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
        child: Center(
          child: SvgPicture.asset(imageIcon, height: 22, width: 22),
        ),
      ),
    );
  }
}