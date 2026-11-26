import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/data/services/subscription_service.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/data/services/subscription_redirect_service.dart';
import 'package:neo_parlour_owner/data/services/salon_service.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';

class NewSubscriptionScreen extends StatefulWidget {
  const NewSubscriptionScreen({super.key});

  @override
  State<NewSubscriptionScreen> createState() => _NewSubscriptionScreenState();
}

class _NewSubscriptionScreenState extends State<NewSubscriptionScreen> with WidgetsBindingObserver {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  List<dynamic> _plans = [];
  bool _isLoadingPlans = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchPlans();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleSubscriptionResume();
    }
  }

  Future<void> _handleSubscriptionResume() async {
    // Refresh plans list
    _fetchPlans();
    
    // Fetch updated token reflecting new subscription status
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.refreshUserToken();
    
    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
        (route) => false,
      );
    }
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
        _showTopFlushBar('${AppLocalizations.of(context)!.failedToLoadPlans}$e');
      }
    }
  }

  void _showTopFlushBar(String message, {bool isSuccess = false}) {
    FlushbarHelper.show(context, message, isSuccess: isSuccess);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _launchSubscriptionUrl() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    setState(() => _isLoading = true);
    try {
      final salonProfile = await SalonService().getSalonProfile();
      final salonId = salonProfile.salonId.toString();

      await SubscriptionRedirectService.launchSubscriptionPortal(
        token: user?.token ?? '',
        salonId: salonId,
        ownerName: user?.name ?? '',
        ownerEmail: user?.email ?? '',
        ownerPhone: user?.phone ?? '',
      );
    } catch (e) {
      _showTopFlushBar('${AppLocalizations.of(context)!.failedToOpenPricingPortal}$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                        child: Text(
                          AppLocalizations.of(context)!.skipForNow,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
    final String planName = plan['planName'] ?? '';

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
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.whatYouCanGet,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
          _buildFeatureRow(AppLocalizations.of(context)!.staffManagement),
          const SizedBox(height: 12),
          _buildFeatureRow(AppLocalizations.of(context)!.inventoryManagement),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _launchSubscriptionUrl,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0B01),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.subscribeOnWebsite,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
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
