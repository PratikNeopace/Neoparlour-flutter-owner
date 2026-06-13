import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/schedule_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/service_main_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/staff_main_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/feedback_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/add_offers_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/inventory_main_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/package_main_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/product_main_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/home_service_screen.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/subscription_screen.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        elevation: 4,
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          "assets/Images/BottomNavigationScreen/home_icon.svg",
        ),
      ),
      // Wrapped in Stack to place back button above the header
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // 1. Header with S-Curve and Image
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipPath(
                      clipper: HeaderCurveClipper(),
                      child: Container(
                        height: 225,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/Images/ManageScreen/background_manage.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0XFF000000).withValues(alpha: 0.35),
                                const Color(0XFFFF3502).withValues(alpha: 0.85),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.only(left: 23, bottom: 40),
                          child: const Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "MANAGE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Floating Card Icon
                    Positioned(
                      bottom: -8,
                      right: 22,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 56,
                          width: 56,
                          padding: const EdgeInsets.all(16.0),
                          decoration: const BoxDecoration(
                            color: Color(0XFFFF0B01),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            "assets/Images/ManageScreen/floating_bg.svg",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Manage Options List
                const SizedBox(height: 30),
                _manageOptionItem(
                  context,
                  "assets/Images/ManageScreen/schedule.svg",
                  "Schedule",
                ),
                _manageOptionItem(
                  context,
                  "assets/Images/ManageScreen/service.svg",
                  "Service",
                ),
                _manageOptionItem(
                  context,
                  "assets/Images/ManageScreen/inventory.svg",
                  "Inventory",
                ),
                _manageOptionItem(
                  context,
                  "assets/Images/ManageScreen/staff.svg",
                  "Staff",
                ),
                _manageOptionItem(
                  context,
                  "assets/Images/ManageScreen/feedback.svg",
                  "Feedback",
                ),
                _manageOptionItem(
                  context,
                  "assets/Images/ManageScreen/home_service.svg",
                  "Home Services",
                ),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final role = auth.user?.role.toUpperCase();
                    final isOwner = role == 'SALON_OWNER' || role == 'OWNER';

                    if (!isOwner) return const SizedBox.shrink();

                    return _manageOptionItem(
                      context,
                      "assets/Images/ManageScreen/subscription.svg",
                      "Subscription",
                    );
                  },
                ),
                _manageOptionItem(
                  context,
                  "assets/Images/ManageScreen/add_offers.svg",
                  "Add Offers",
                ),
                _manageOptionItem(
                  context,
                  "assets/Images/ManageScreen/add_products.svg",
                  "Add Products",
                ),
                _manageOptionItem(
                  context,
                  "assets/Images/ManageScreen/add_packages.svg",
                  "Add Packages",
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Back button positioned absolutely on top
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.5),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _manageOptionItem(BuildContext context, String icon, String title) {
    return GestureDetector(
      onTap: () {
        if (title == "Schedule") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScheduleScreen()),
          );
        } else if (title == "Service") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ServiceMainScreen()),
          );
        } else if (title == "Staff") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffMainScreen()),
          );
        } else if (title == "Feedback") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FeedbackScreen()),
          );
        } else if (title == "Add Offers") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddOffersScreen()),
          );
        } else if (title == "Inventory") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InventoryMainScreen(),
            ),
          );
        } else if (title == "Add Packages") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PackageMainScreen()),
          );
        } else if (title == "Add Products") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductMainScreen()),
          );
        } else if (title == "Home Services") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeServicesScreen()),
          );
        } else if (title == "Subscription") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(icon),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

// Clipper for the S-Curve header
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
