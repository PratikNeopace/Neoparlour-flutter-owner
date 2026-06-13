import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/add_staff_screen.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/staff_provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';

class StaffMainScreen extends StatefulWidget {
  const StaffMainScreen({super.key});

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<StaffProvider>(
      builder: (context, staffProvider, child) {
        // Automatically switch to 'ADD STAFF' tab (index 0) if a staff member is selected for edit
        if (staffProvider.editingStaff != null && _tabController.index != 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _tabController.animateTo(0);
          });
        }

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
          elevation: 4,
          shape: const CircleBorder(),
          child: SvgPicture.asset("assets/Images/BottomNavigationScreen/home_icon.svg"),
        ),
        body: Column(
          children: [
            _buildHeader(context),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: const Color(0XFFCBC8C8),
              indicatorColor: const Color(0XFFFF0B01),
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              tabs: const [
                Tab(text: "ADD STAFF"),
                Tab(text: "STAFF LIST"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                   AddStaffScreen(showAsTab: true, initialTabIndex: 0),
                   AddStaffScreen(showAsTab: true, initialTabIndex: 1),
                ],
              ),
            ),
          ],
        ));
      },
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
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502).withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: const Text(
                "STAFF",
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
              backgroundColor: Colors.white.withValues(alpha: 0.5),
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
            child: SvgPicture.asset("assets/Images/AddStaffScreen/floating_staff.svg"),
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
