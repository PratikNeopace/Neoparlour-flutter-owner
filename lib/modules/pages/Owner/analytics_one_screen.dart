import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';

class AnalyticsOneScreen extends StatefulWidget {
  const AnalyticsOneScreen({super.key});

  @override
  State<AnalyticsOneScreen> createState() => _AnalyticsOneScreenState();
}

class _AnalyticsOneScreenState extends State<AnalyticsOneScreen> {
  int selectedIndex = 0; 

  final List<String> titles = [
    "Inventory",
    "Rescheduled",
    "Cancelled",
    "Attendance"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: const OwnerBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0XFFFF0B01),
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          "assets/Images/BottomNavigationScreen/home_icon.svg",
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: titles.length,
                    itemBuilder: (context, index) =>
                        _buildAnalyticsCard(titles[index], "View Details", index),
                  ),
                  const SizedBox(height: 25),
                  const Text("ALL BOOKINGS",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  _buildChartPlaceholder(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String subtitle, int index) {
    bool isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Color(0XFFF5F5F5),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color:  const Color(0XFF909090) ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0XFF909090),
              ),
            ),
            Spacer(),
            Container(height: 4, width: 60, color: const Color(0XFFFF0B01)),
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
                image: AssetImage("assets/Images/StaffAnalyticsScreen/background_image.jpg"), 
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 25, bottom: 20),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502).withOpacity(0.7)
                  ],
                ),
              ),
              child: const Text("ANALYTICS",
                  style: TextStyle(
                      color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500)
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
          
          right: 10,
          bottom: 20,
          child: CircleAvatar(
            backgroundColor: const Color(0XFFFF0B01),
            radius: 30,
            child: SvgPicture.asset(
              "assets/Images/StaffAnalyticsScreen/floating_icon_staff.svg",
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartPlaceholder() => Container(
        height: 200,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300)),
        child: const Center(
            child: Icon(Icons.bar_chart, size: 100, color: Colors.grey)),
      );
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}