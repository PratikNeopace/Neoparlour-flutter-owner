import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/data/models/register_user_model.dart';
import 'package:neo_parlour_owner/data/services/auth_service.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_login.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/new_subscription_screen.dart';
import 'dart:async';

class VerifyRegistrationOtpScreen extends StatefulWidget {
  final UserRegistrationRequest registrationRequest;

  const VerifyRegistrationOtpScreen({
    super.key,
    required this.registrationRequest,
  });

  @override
  State<VerifyRegistrationOtpScreen> createState() =>
      _VerifyRegistrationOtpScreenState();
}

class _VerifyRegistrationOtpScreenState
    extends State<VerifyRegistrationOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.sendRegisterOtp(widget.registrationRequest.phone);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FlushbarHelper.show(
              context,
              "OTP resent successfully",
              isSuccess: true,
            );
          }
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FlushbarHelper.show(
              context,
              "Failed to resend OTP: ${e.toString()}",
            );
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 6) {
      FlushbarHelper.show(context, "Please enter full 6-digit OTP");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.registerWithOtp(
        widget.registrationRequest.toJson(),
        otp,
      );

      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final loginSuccess = await authProvider.login(
        widget.registrationRequest.phone,
        widget.registrationRequest.password,
      );

      if (!mounted) return;

      if (loginSuccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NewSubscriptionScreen()),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Registration Successful"),
            content: const Text("Your account has been created. Please login."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SalonOwnerLoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text("LOGIN NOW"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FlushbarHelper.show(context, "Verification Failed: ${e.toString()}");
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double w = size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/Images/SplashScreen/splash_screen_one_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: w * 0.05),
              padding: EdgeInsets.fromLTRB(
                25,
                30,
                25,
                MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "VERIFY OTP",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 2,
                      width: 60,
                      color: const Color(0XFFFF0B01),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "We sent a verification code to your\nmobile number ${widget.registrationRequest.phone.substring(0, 2)}******${widget.registrationRequest.phone.substring(widget.registrationRequest.phone.length - 2)}",
                      style: const TextStyle(
                        color: Color(0XFF909090),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => _otpBox(index)),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0XFFFF0B01),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "VERIFY",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Didn't receive OTP? ",
                          style: TextStyle(
                            color: Color(0XFF909090),
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: _canResend ? _resendOtp : null,
                          child: Text(
                            _canResend
                                ? "Resend OTP"
                                : "Resend in ${_secondsRemaining}s",
                            style: TextStyle(
                              color: _canResend
                                  ? const Color(0XFFFF0B01)
                                  : const Color(0XFFADADAD),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0XFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? const Color(0XFFFF0B01)
              : const Color(0XFFE0E0E0),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            setState(() {});
            if (index < 5) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          } else {
            if (index > 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          }
        },
      ),
    );
  }

  Widget _socialCircle(String svg, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: bgColor == Colors.white
            ? Border.all(color: Colors.grey.shade300)
            : null,
      ),
      child: SvgPicture.asset(svg, height: 20, width: 20),
    );
  }
}
