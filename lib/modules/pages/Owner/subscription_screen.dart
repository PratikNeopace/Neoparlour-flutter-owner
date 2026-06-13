import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/data/services/subscription_service.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
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
    ScaffoldMessenger.of(context).clearSnackBars();
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
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: const OwnerBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final role = authProvider.user?.role.toUpperCase();
          if (role == 'SALON_OWNER' || role == 'OWNER') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeStaffScreen()),
              (route) => false,
            );
          }
        },
        backgroundColor: const Color(0XFFFF0B01),
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          "assets/Images/BottomNavigationScreen/home_icon.svg",
          width: 22,
          height: 22,
        ),
      ),

      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      children: [
                        if (_isLoadingPlans)
                          const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
                        else if (_plans.isEmpty)
                          const Center(child: Text("No subscription plans available."))
                        else
                          ..._plans.asMap().entries.map((entry) {
                            int index = entry.key;
                            dynamic plan = entry.value;
                            if (index % 2 == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 25.0),
                                child: _buildPremiumCard(plan),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 25.0),
                                child: _buildBasicCard(plan),
                              );
                            }
                          }),
                      ],
                    ),
                  ),
                ),
              ],
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

  // ================= PREMIUM CARD =================
  Widget _buildPremiumCard(dynamic plan) {
    final double amount = (plan['amountInPaise'] ?? 0) / 100;
    final String amountText = "₹${amount.toStringAsFixed(0)} / ${plan['planName'] ?? ''}";
    final String planCode = plan['planCode'] ?? '';

    if (!_couponControllers.containsKey(planCode)) {
      _couponControllers[planCode] = TextEditingController();
    }
    final controller = _couponControllers[planCode]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0XFFFF0B01),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Center(
            child: Column(
              children:  [
                SvgPicture.asset("assets/Images/SubscriptionScreen/floating_icon_subscription.svg",height:50,width: 50),
                SizedBox(height: 10),
                Text(
                  amountText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "What You Can Get?",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          _featureItem("Inventory Management", true),
          _featureItem("Staff Management", true),
          _featureItem("Analytics Dashboard", true),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startSubscription(planCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                "SUBSCRIBE",
                style: TextStyle(
                  color: Color(0XFFFF0B01),
                  fontWeight: FontWeight.bold,
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
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter Coupon Code',
                    hintStyle: const TextStyle(color: Colors.white70),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(9.0)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(9.0)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _redeemCoupon(planCode, controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
                  ),
                  child: const Text('Redeem', style: TextStyle(color: Color(0XFFFF0B01), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= BASIC CARD =================
  Widget _buildBasicCard(dynamic plan) {
    final double amount = (plan['amountInPaise'] ?? 0) / 100;
    final String amountText = "₹${amount.toStringAsFixed(0)} / ${plan['planName'] ?? ''}";
    final String planCode = plan['planCode'] ?? '';

    if (!_couponControllers.containsKey(planCode)) {
      _couponControllers[planCode] = TextEditingController();
    }
    final controller = _couponControllers[planCode]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0XFFDDDDDD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Center(
            child: Column(
              children: [
                 SvgPicture.asset("assets/Images/SubscriptionScreen/floating_icon_subscription.svg",height:50,width:50, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                SizedBox(height: 10),
                Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "What You Can Get?",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          _featureItem("Inventory Management", false),
          _featureItem("Staff Management", false),
          _featureItem("Advanced Reports", false),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startSubscription(planCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFFFF0B01),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                "SUBSCRIBE",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9.0)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
                  ),
                  child: const Text('Redeem', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= FEATURE ITEM =================
 Widget _featureItem(String text, bool isPremium) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. CIRCULAR BACKGROUND
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isPremium ? Colors.white : Colors.black,
                  shape: BoxShape.circle, // Makes the container circular
                ),
              ),
              
              // 2. TICK ICON
              Icon(
                Icons.check,
                size: 14,
                color: isPremium ? const Color(0XFFFF0B01) : Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Use Expanded to prevent text from overflowing on small screens
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isPremium ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/Images/SubscriptionScreen/background_image.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 25, bottom: 25),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502),
                  ],
                ),
              ),
              child: const Text(
                "SUBSCRIPTION",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        Positioned(
          right: 15,
          bottom: 15,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0XFFFF0B01),
            child: SvgPicture.asset("assets/Images/SubscriptionScreen/floating_icon_subscription.svg"),
          ),
        ),
      ],
    );
  }
}

// ================= CLIPPER =================
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}