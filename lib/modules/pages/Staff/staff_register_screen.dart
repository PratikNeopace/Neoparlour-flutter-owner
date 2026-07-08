import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_register_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_login.dart';
import 'package:neo_parlour_owner/modules/pages/email_login_screen.dart';

class StaffRegisterScreen extends StatefulWidget {
  const StaffRegisterScreen({super.key});

  @override
  State<StaffRegisterScreen> createState() => _StaffRegisterScreenState();
}

class _StaffRegisterScreenState extends State<StaffRegisterScreen> {
  bool isChecked = false;
  bool isOwnerTab = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController salonIdController = TextEditingController();
  final TextEditingController specialityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    salonIdController.dispose();
    specialityController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double h = size.height;
    final double w = size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/Images/SplashScreen/splash_screen_one_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: w * 0.05),
                  padding: EdgeInsets.fromLTRB(
                    w * 0.06,
                    h * 0.03,
                    w * 0.06,
                    h * 0.03, // Consistent padding, Scaffold handles the keyboard
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// TABS
                        Row(
                          children: [
                            _buildTabItem(
                              "OWNER",
                              false,
                                  () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const OwnerRegisterScreen(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: w * 0.08),
                            _buildTabItem(
                              "EMPLOYEE",
                              true,
                                  () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const StaffRegisterScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: h * 0.03),

                        _customInputField(
                            "assets/Images/RegisterScreen/username.svg",
                            "User Name",
                            nameController),
                        _customInputField(
                            "assets/Images/RegisterScreen/mail.svg",
                            "Email Id",
                            emailController),
                        _customInputField(
                            "assets/Images/RegisterScreen/call.svg",
                            "Mobile Number",
                            mobileController,
                            isVerify: true),
                        _customInputField(
                            "assets/Images/RegisterScreen/username.svg",
                            "Salon ID",
                            salonIdController),
                        _customInputField(
                            "assets/Images/RegisterScreen/username.svg",
                            "Enter Speciality",
                            specialityController),
                        _customInputField(
                            "assets/Images/RegisterScreen/password.svg",
                            "Create a password",
                            passwordController,
                            obscure: true),
                        _customInputField(
                            "assets/Images/RegisterScreen/password.svg",
                            "Confirm password",
                            confirmPasswordController,
                            obscure: true),

                        SizedBox(height: h * 0.01),

                        SizedBox(
                          width: double.infinity,
                          height: h * 0.065,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0XFFFF0B01),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "REGISTER",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              activeColor:
                              const Color(0XFFFF0B01),
                              onChanged: (v) =>
                                  setState(() => isChecked = v!),
                            ),
                            const Text(
                              "I agree with terms of use",
                              style: TextStyle(
                                  color: Color(0XFF909090),
                                  fontSize: 12),
                            ),
                          ],
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Already have account? ",
                                  style:
                                  TextStyle(color: Color(0XFF909090)),
                                ),
                                TextSpan(
                                  text: "Login",
                                  style: const TextStyle(
                                    color: Color(0XFFFF0B01),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const StaffLoginScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "or sign in with",
                            style: TextStyle(
                                color: Color(0XFF909090),
                                fontSize: 11),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            _socialIcon(
                                "assets/Images/LoginScreen/facebook.svg",
                                const Color(0XFF3B5998)),
                            _socialIcon(
                                "assets/Images/LoginScreen/google.svg",
                                Colors.white),
                          ],
                        ),
                        SizedBox(height: 20 + MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
      String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color:
              isActive ? Colors.black : const Color(0XFFADADAD),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: title.length * 9,
            color:
            isActive ? const Color(0XFFFF0B01) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _customInputField(String icon, String hint,
      TextEditingController controller,
      {bool obscure = false, bool isVerify = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              icon,
              colorFilter: const ColorFilter.mode(
                  Color(0XFF909090), BlendMode.srcIn),
            ),
          ),
          suffixIcon: isVerify
              ? const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Verify",
              style: TextStyle(
                  color: Color(0XFFFF0B01),
                  fontWeight: FontWeight.bold),
            ),
          )
              : null,
          hintText: hint,
          hintStyle:
          const TextStyle(color: Color(0XFFADADAD)),
          filled: true,
          fillColor: const Color(0XFFF9F9F9),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0XFFE0E0E0), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0XFFFF0B01), width: 1.6),
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(String icon, Color bgColor) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmailLoginScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: bgColor == Colors.white
              ? Border.all(color: Colors.grey.shade300)
              : null,
        ),
        child: Center(
          child: SvgPicture.asset(icon, height: 20),
        ),
      ),
    );
  }
}