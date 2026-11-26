import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_login.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';

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
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty || mobile.length < 10 || !RegExp(r'^\d+$').hasMatch(mobile)) {
      FlushbarHelper.show(context, AppLocalizations.of(context)!.validMobileError);
      return;
    }

    final success = await Provider.of<AuthProvider>(context, listen: false)
        .sendForgotPasswordOtp(mobile);

    if (success) {
      if (!mounted) return;
      setState(() {
        _isOtpSent = true;
      });
      FlushbarHelper.show(context, AppLocalizations.of(context)!.otpSentSuccess, isSuccess: true);
    } else {
      if (!mounted) return;
      final error = Provider.of<AuthProvider>(context, listen: false).errorMessage;
      FlushbarHelper.show(context, error ?? AppLocalizations.of(context)!.failedToSendOtp);
    }
  }

  Future<void> _handleResetPassword() async {
    if (_otpController.text.isEmpty) {
      _showError(AppLocalizations.of(context)!.enterOtpError);
      return;
    }
    if (_passwordController.text.length < 6) {
      _showError(AppLocalizations.of(context)!.passwordLengthError);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError(AppLocalizations.of(context)!.passwordsDoNotMatch);
      return;
    }

    final success = await Provider.of<AuthProvider>(context, listen: false).resetPassword(
      mobile: _mobileController.text.trim(),
      otp: _otpController.text.trim(),
      newPassword: _passwordController.text,
    );

    if (success) {
      if (!mounted) return;
      FlushbarHelper.show(context, AppLocalizations.of(context)!.passwordResetSuccess, isSuccess: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SalonOwnerLoginScreen()),
            (route) => false,
          );
        }
      });
    } else {
      if (!mounted) return;
      final error = Provider.of<AuthProvider>(context, listen: false).errorMessage;
      _showError(error ?? AppLocalizations.of(context)!.failedToResetPassword);
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
        title: Text(
          AppLocalizations.of(context)!.resetPasswordTitle,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.08, vertical: h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isOtpSent ? AppLocalizations.of(context)!.verificationTitle : AppLocalizations.of(context)!.forgotPasswordTitle,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                _isOtpSent
                    ? AppLocalizations.of(context)!.enterOtpAndNewPassword(_mobileController.text)
                    : AppLocalizations.of(context)!.enterMobileForOtp,
                style: const TextStyle(fontSize: 14, color: Color(0XFF909090)),
              ),
              const SizedBox(height: 40),

              if (!_isOtpSent) ...[
                _customInputField(
                  icon: Icons.phone_android_outlined,
                  hint: AppLocalizations.of(context)!.mobileNumber,
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                ),
              ] else ...[
                _customInputField(
                  icon: Icons.message_outlined,
                  hint: AppLocalizations.of(context)!.enterOtp,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                ),
                _customInputField(
                  icon: Icons.lock_outline,
                  hint: AppLocalizations.of(context)!.newPassword,
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                _customInputField(
                  icon: Icons.lock_outline,
                  hint: AppLocalizations.of(context)!.confirmNewPassword,
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
                              _isOtpSent ? AppLocalizations.of(context)!.resetPasswordBtn : AppLocalizations.of(context)!.sendOtpBtn,
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
                    child: Text(
                      AppLocalizations.of(context)!.changeMobileNumber,
                      style: const TextStyle(color: Color(0XFF909090), fontSize: 13),
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
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
