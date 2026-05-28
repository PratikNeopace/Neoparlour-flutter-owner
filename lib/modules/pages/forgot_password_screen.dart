import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isOtpSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (_mobileController.text.length < 10) {
      FlushbarHelper.show(context, "Please enter a valid mobile number");
      return;
    }

    final success = await Provider.of<AuthProvider>(context, listen: false)
        .sendForgotPasswordOtp(_mobileController.text);

    if (success) {
      if (!mounted) return;
      setState(() {
        _isOtpSent = true;
      });
      FlushbarHelper.show(context, "OTP sent successfully");
    } else {
      if (!mounted) return;
      final error = Provider.of<AuthProvider>(context, listen: false).errorMessage;
      FlushbarHelper.show(context, error ?? "Failed to send OTP");
    }
  }

  Future<void> _handleResetPassword() async {
    if (_otpController.text.isEmpty) {
      _showError("Please enter the OTP");
      return;
    }
    if (_passwordController.text.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match");
      return;
    }

    final success = await Provider.of<AuthProvider>(context, listen: false).resetPassword(
      mobile: _mobileController.text,
      otp: _otpController.text,
      newPassword: _passwordController.text,
    );

    if (success) {
      if (!mounted) return;
      FlushbarHelper.show(context, "Password reset successfully. Please login.");
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      final error = Provider.of<AuthProvider>(context, listen: false).errorMessage;
      _showError(error ?? "Failed to reset password");
    }
  }

  void _showError(String message) {
    FlushbarHelper.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reset Password",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.08, vertical: h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isOtpSent ? "Verification" : "Forgot Password?",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                _isOtpSent
                    ? "Enter the OTP sent to ${_mobileController.text} and your new password."
                    : "Enter your registered mobile number to receive an OTP for password reset.",
                style: const TextStyle(fontSize: 14, color: Color(0XFF909090)),
              ),
              const SizedBox(height: 40),

              if (!_isOtpSent) ...[
                _customInputField(
                  icon: Icons.phone_android_outlined,
                  hint: 'Mobile Number',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                ),
              ] else ...[
                _customInputField(
                  icon: Icons.message_outlined,
                  hint: 'Enter OTP',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                ),
                _customInputField(
                  icon: Icons.lock_outline,
                  hint: 'New Password',
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                _customInputField(
                  icon: Icons.lock_outline,
                  hint: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  obscure: _obscureConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : (_isOtpSent ? _handleResetPassword : _handleSendOtp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFFFF0B01),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isOtpSent ? "RESET PASSWORD" : "SEND OTP",
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
                            ),
                    );
                  },
                ),
              ),
              
              if (_isOtpSent) ...[
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isOtpSent = false),
                    child: const Text(
                      "Change Mobile Number",
                      style: TextStyle(color: Color(0XFF909090), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _customInputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0XFFFF0B01), size: 22),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0XFFADADAD), fontSize: 14),
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
}
