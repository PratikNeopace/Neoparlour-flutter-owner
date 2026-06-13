import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  int selectedTab = 0; // 0 = Pending, 1 = Approved

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
          width: 22,
          height: 22,
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTabs(),
                    const SizedBox(height: 20),

                    if (selectedTab == 0) _pendingCard(),
                    if (selectedTab == 1)
                      const Center(
                        child: Text(
                          "No Approved Requests",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                  "assets/Images/LeaveRequestScreen/background_image.jpg",
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
                "LEAVE REQUEST",
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
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),

        Positioned(
          right: 15,
          bottom: 15,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0XFFFF0B01),
            child: SvgPicture.asset(
              height:50,
              width:50,
              "assets/Images/LeaveRequestScreen/floating_action_btn.svg",
            ),
          ),
        ),
      ],
    );
  }

  // ================= TABS =================
  Widget _buildTabs() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => selectedTab = 0),
          child: Column(
            children: [
              Text(
                "PENDING",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: selectedTab == 0 ? Colors.black : Color(0XFFCBC8C8),
                ),
              ),
              const SizedBox(height: 6),
              if (selectedTab == 0)
                Container(height: 2, width: 60, color: const Color(0XFFFF0B01)),
            ],
          ),
        ),
        const SizedBox(width: 25),
        GestureDetector(
          onTap: () => setState(() => selectedTab = 1),
          child: Column(
            children: [
              Text(
                "APPROVED",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: selectedTab == 1 ? Colors.black : Color(0XFFCBC8C8),
                ),
              ),
              const SizedBox(height: 6),
              if (selectedTab == 1)
                Container(height: 2, width: 70, color: const Color(0XFFFF0B01)),
            ],
          ),
        ),
      ],
    );
  }

  // ================= PENDING CARD =================
  Widget _pendingCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0XFF909090)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  image: const DecorationImage(
                    image: AssetImage(
                      "assets/Images/LeaveRequestScreen/circle_avatar.jpg",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Text(
                          "Pratik Ghodake",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "Leave Type - Paid",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0XFF8D8D8D),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Duration : 01-04-2026 To 02-04-2026",
                      style: TextStyle(fontSize: 11, color: Color(0XFF8D8D8D)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFFFF0B01),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    "APPROVE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    "REJECT",
                    style: TextStyle(color: Color(0XFF909090)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
