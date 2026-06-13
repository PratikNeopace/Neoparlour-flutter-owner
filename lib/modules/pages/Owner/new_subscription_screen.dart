import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/data/services/subscription_service.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';
class NewSubscriptionScreen extends StatefulWidget {
  const NewSubscriptionScreen({super.key});

  @override
  State<NewSubscriptionScreen> createState() => _NewSubscriptionScreenState();
}

class _NewSubscriptionScreenState extends State<NewSubscriptionScreen> {
  late Razorpay _razorpay;
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  List<dynamic> _plans = [];
  bool _isLoadingPlans = true;
  final Map<String, TextEditingController> _couponControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _fetchPlans() async {
    try {
      final plans = await _subscriptionService.getPlans();
      if (mounted) {
        setState(() {
          _plans = plans.where((p) => p['active'] == true).toList();
          _isLoadingPlans = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPlans = false);
        _showTopFlushBar('Failed to load plans: $e');
      }
    }
  }

  void _showTopFlushBar(String message, {bool isSuccess = false}) {
    FlushbarHelper.show(context, message, isSuccess: isSuccess);
  }

  @override
  void dispose() {
    for (var controller in _couponControllers.values) {
      controller.dispose();
    }
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) return;
    try {
      final verifyResponse = await _subscriptionService.verifyPayment(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        userId: userId,
      );
      
      if (mounted) {
        await authProvider.refreshToken();
        if (!mounted) return;
        
        _showTopFlushBar(verifyResponse['message'] ?? 'Subscription activated successfully!', isSuccess: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showTopFlushBar('Verification failed: $e');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showTopFlushBar('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showTopFlushBar('External Wallet: ${response.walletName}');
  }

  Future<void> _startSubscription(String planCode) async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId == null) {
      _showTopFlushBar('User not logged in.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final orderData = await _subscriptionService.createOrder(planCode: planCode, userId: userId);
      
      var options = {
        'key': orderData['key'],
        'amount': orderData['amount'],
        'currency': orderData['currency'] ?? 'INR',
        'name': 'NeoParlour',
        'description': 'Subscription',
        'order_id': orderData['id'],
        'prefill': {
          'contact': '9999999999',
          'email': 'test@example.com'
        },
      };

      _razorpay.open(options);
    } catch (e) {
      _showTopFlushBar('Failed to create order: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _redeemCoupon(String planCode, String couponCode) async {
    if (couponCode.trim().isEmpty) {
      _showTopFlushBar('Please enter a coupon code.');
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    if (userId == null) {
      _showTopFlushBar('User not logged in.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final orderData = await _subscriptionService.createOrder(
          planCode: planCode, userId: userId, couponCode: couponCode.trim());
      
      if (orderData['status']?.toString().toLowerCase() == 'active') {
        await authProvider.refreshToken();
        if (mounted) {
          _showTopFlushBar('Coupon applied! Subscription activated successfully!', isSuccess: true);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
            (route) => false,
          );
        }
      } else {
        if (orderData['key'] == null || orderData['key'].toString().isEmpty) {
          throw Exception('Invalid coupon code or missing payment key from server.');
        }
        var options = {
          'key': orderData['key'],
          'amount': orderData['amount'],
          'currency': orderData['currency'] ?? 'INR',
          'name': 'NeoParlour',
          'description': 'Subscription',
          'order_id': orderData['id'],
          'prefill': {
            'contact': '9999999999',
            'email': 'test@example.com'
          },
        };
        _razorpay.open(options);
      }
    } catch (e) {
      if (mounted) {
        _showTopFlushBar(ErrorHandler.parseError(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            // Background Gradient
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF0B01),
                  Color(0xFF990701),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top Action Button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 24.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
                          );
                        },
                        child: const Text(
                          'Skip For Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Subscription Cards List
                  Expanded(
                    child: _isLoadingPlans 
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : ListView.separated(
                            padding: EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              top: 0,
                              bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
                            ),
                            itemCount: _plans.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 24),
                            itemBuilder: (context, index) {
                              return _buildSubscriptionCard(_plans[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(dynamic plan) {
    final double amount = (plan['amountInPaise'] ?? 0) / 100;
    final String amountText = "₹${amount.toStringAsFixed(0)}";
    final String planCode = plan['planCode'] ?? '';
    final String planName = plan['planName'] ?? '';

    if (!_couponControllers.containsKey(planCode)) {
      _couponControllers[planCode] = TextEditingController();
    }
    final controller = _couponControllers[planCode]!;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crown Icon Header
           Center(
            child: SvgPicture.asset("assets/Images/SubscriptionScreen/crown.svg"),
          ),
          const SizedBox(height: 24),

          // Pricing & Info Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'What You Can Get?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
                  children: [
                    TextSpan(
                      text: amountText,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' /$planName',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Features List
          _buildFeatureRow('Staff Management'),
          const SizedBox(height: 12),
          _buildFeatureRow('Inventory Management'),
          const SizedBox(height: 32),

          // Subscribe Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _startSubscription(planCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0B01),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0,
              ),
              child: const Text(
                'SUBSCRIBE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter Coupon Code',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _redeemCoupon(planCode, controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Text('Redeem', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper item for features with checkmark
  Widget _buildFeatureRow(String featureText) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black54, width: 1.5),
          ),
          padding: const EdgeInsets.all(2),
          child: const Icon(
            Icons.check,
            size: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          featureText,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
