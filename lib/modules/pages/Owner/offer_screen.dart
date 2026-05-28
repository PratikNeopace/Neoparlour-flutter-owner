import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../../providers/offer_provider.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  int selectedIndex = 0; // Default selected card index

  final List<String> titles = [
    "Claimed Offer",
    "Offer Revenue",
    "Booking Via Offers",
    "New Customers Via Offers"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            child: CustomRefreshIndicator(
              onRefresh: () async {
                final offerProvider = Provider.of<OfferProvider>(context, listen: false);
                await offerProvider.fetchOffers();
              },
              color: const Color(0XFFFF0B01),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
          )],
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
            // const SizedBox(height: 7),
            Spacer(),
            Container(height: 4, width: 60, color: const Color(0XFFFF0B01)),
          ],
        ),
      ),
    );
  }

   Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            width: double.infinity,
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
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.4),
              child: const Icon(Icons.chevron_left, color: Colors.black),
            ),
          ),
        ),
        const Positioned(
          bottom: 30,
          left: 23,
          child: Text(
            "OFFER",
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w500),
          ),
        ),
        Positioned(
          bottom: -5,
          right: 22,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0XFFFF0B01),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 6)),
              ],
            ),
            child: Center(
              child: SizedBox(
                height: 26,
                width: 26,
                child: SvgPicture.asset("assets/Images/ServicesScreen/floating_icon_service.svg",
                fit: BoxFit.contain
                )
              )
            )
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