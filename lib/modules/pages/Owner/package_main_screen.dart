import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/add_package_screen.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';

class PackageMainScreen extends StatefulWidget {
  const PackageMainScreen({super.key});

  @override
  State<PackageMainScreen> createState() => _PackageMainScreenState();
}

class _PackageMainScreenState extends State<PackageMainScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          elevation: 4,
          shape: const CircleBorder(),
          child: SvgPicture.asset("assets/Images/BottomNavigationScreen/home_icon.svg"),
        ),
        body: Column(
          children: [
            _buildHeader(context),
            const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Color(0XFFCBC8C8),
              indicatorColor: Color(0XFFFF0B01),
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              tabs: [
                Tab(text: "ADD PACKAGE"),
                Tab(text: "PACKAGE LIST"),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                   AddPackageScreen(showAsTab: true, initialTabIndex: 0),
                   AddPackageScreen(showAsTab: true, initialTabIndex: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Images/CreateInvoiceScreen/background_image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 25, bottom: 40),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502).withOpacity(0.7),
                  ],
                ),
              ),
              child: const Text(
                "PACKAGES",
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
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.5),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            ),
          ),
        ),
         Positioned(
          right: 30,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0XFFFF0B01), shape: BoxShape.circle),
            child: SvgPicture.asset("assets/Images/AddPackageScreen/floating_action_icon.svg"),
          ),
        ),
      ],
    );
  }
}

class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.55, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height * 0.35);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
