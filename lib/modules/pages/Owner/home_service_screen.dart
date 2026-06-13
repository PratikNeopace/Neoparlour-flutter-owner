import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/salon_provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';

class HomeServicesScreen extends StatefulWidget {
  const HomeServicesScreen({super.key});

  @override
  State<HomeServicesScreen> createState() => _HomeServicesScreenState();
}

class _HomeServicesScreenState extends State<HomeServicesScreen> {
  bool enableBookings = false;
  bool _isPageLoading = true;
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final salonId = authProvider.user?.salonId ?? authProvider.user?.id;
    if (salonId == null) {
      setState(() {
        _isPageLoading = false;
      });
      return;
    }

    try {
      final salonProvider = Provider.of<SalonProvider>(context, listen: false);
      await salonProvider.fetchHomeServiceCharges(salonId);
      final charges = salonProvider.homeServiceCharges ?? 0.0;
      setState(() {
        if (charges > 0.0) {
          enableBookings = true;
          priceController.text = charges.toString();
        } else {
          enableBookings = false;
          priceController.text = "0.0";
        }
        _isPageLoading = false;
      });
    } catch (e) {
      setState(() {
        _isPageLoading = false;
      });
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
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

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: _isPageLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0XFFFF0B01),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // ================= ENABLE BOOKINGS CARD =================
                          Consumer<SalonProvider>(
                            builder: (consumerContext, provider, child) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFF8F8F8),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: const Color(0XFF909090)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // TITLE + SWITCH
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Enable Bookings",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Switch(
                                          value: enableBookings,
                                          activeThumbColor: Colors.white, // The thumb color
                                          activeTrackColor: const Color(
                                            0XFFFF0B01,
                                          ), // The background color when ON
                                          inactiveThumbColor: Colors.grey, // Optional: customize thumb when OFF
                                          inactiveTrackColor: Colors.grey.shade300, // Optional: customize track when OFF
                                          onChanged: (value) {
                                            setState(() {
                                              enableBookings = value;
                                              if (!value) {
                                                priceController.text = "0.0";
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),

                                    // Reduced the height here to bring the description closer
                                    const SizedBox(height: 0),

                                    const Text(
                                      "Allow customers to book appointments\nat their location.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0XFF353535),
                                        height: 1.2, // Added line height for better readability
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    // PRICE FIELD
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: enableBookings ? const Color(0XFFF8F8F8) : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                          color: enableBookings ? const Color(0XFF909090) : Colors.grey.shade400,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: priceController,
                                        enabled: enableBookings,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          fillColor: Colors.white,
                                          border: InputBorder.none,
                                          hintText: "₹ 0.0",
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    const Text(
                                      "This amount will be added to the service total.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0XFF868686),
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    // SAVE BUTTON
                                    SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: provider.isLoading
                                            ? null
                                            : () async {
                                                if (enableBookings && priceController.text.trim().isEmpty) {
                                                  FlushbarHelper.show(context, "Please enter home service charges");
                                                  return;
                                                }
                                                final charges = enableBookings
                                                    ? (double.tryParse(priceController.text) ?? 0.0)
                                                    : 0.0;
                                                if (enableBookings && charges <= 0.0) {
                                                  FlushbarHelper.show(context, "Charges must be greater than 0");
                                                  return;
                                                }
                                                if (enableBookings && charges > 100000.0) {
                                                  FlushbarHelper.show(context, "Charges cannot exceed ₹100,000");
                                                  return;
                                                }
                                                final success = await provider.updateHomeServiceCharges(charges);
                                                if (context.mounted) {
                                                  if (success) {
                                                    FlushbarHelper.show(context, "Charges updated successfully", isSuccess: true);
                                                  } else {
                                                    FlushbarHelper.show(context, provider.errorMessage ?? "Failed to update charges");
                                                  }
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0XFFFF0B01),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(9),
                                          ),
                                        ),
                                        child: provider.isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text(
                                                "SAVE",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
                  "assets/Images/HomeServicesScreen/background_image.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 20, bottom: 25),
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
                "HOME SERVICES",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        // BACK BUTTON
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.5),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        // CAMERA FLOAT ICON
        Positioned(
          right: 15,
          bottom: 15,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0XFFFF0B01),
            child: SvgPicture.asset(
              "assets/Images/HomeServicesScreen/floating_btn_img.svg",
              width: 25,
              height: 25,
            ),
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
