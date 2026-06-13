import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/appointment_provider.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';

class AnalyticsTwoScreen extends StatefulWidget {
  const AnalyticsTwoScreen({super.key});

  @override
  State<AnalyticsTwoScreen> createState() => _AnalyticsTwoScreenState();
}

class _AnalyticsTwoScreenState extends State<AnalyticsTwoScreen> {
  int selectedIndex = 0; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final salonId = int.tryParse(authProvider.user?.tenantName ?? '');
      if (salonId != null) {
        Provider.of<AppointmentProvider>(context, listen: false)
            .fetchAnalyticsData(salonId: salonId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.analyticsAppointments.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Text(
                      provider.errorMessage!,
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                final List<Map<String, dynamic>> analyticsData = [
                  {"title": "Total Clients", "count": provider.totalClientsCount},
                  {"title": "Total Services", "count": provider.totalServicesCount},
                  {"title": "Employees", "count": provider.employeesCount},
                  {"title": "Appointment", "count": provider.totalAppointmentsCount},
                ];

                return SingleChildScrollView(
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
                        itemCount: analyticsData.length,
                        itemBuilder: (context, index) => _buildAnalyticsCard(
                          analyticsData[index]['title'],
                          analyticsData[index]['count'].toString().padLeft(2, '0'),
                          index,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "ALL BOOKINGS",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: 0,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (provider.analyticsAppointments.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text(
                              "No bookings found",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.analyticsAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = provider.analyticsAppointments[index];
                            return _buildBookingItem(appointment);
                          },
                        ),
                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String count, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0XFFF5F5F5),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected ? const Color(0XFFFF0B01) : const Color(0XFF909090),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isSelected ? Colors.black : const Color(0XFF606060),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "View Details",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: const Color(0XFF909090),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? const Color(0XFFFF0B01) : Colors.black87,
                  ),
                ),
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0XFFFF0B01),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(dynamic appointment) {
    final dateStr = DateFormat('dd MMM yyyy').format(appointment.appointmentAt.toLocal());
    final timeStr = DateFormat('hh:mm a').format(appointment.appointmentAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0XFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/Images/HomeScreen/circle_avatar.jpg'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.customerName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  appointment.serviceNames.join(", "),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0XFF909090),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 12, color: Color(0XFFFF0B01)),
                    const SizedBox(width: 4),
                    Text(
                      "Staff: ${appointment.staffName}",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0XFFFF0B01),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0XFFFF0B01).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  appointment.status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0XFFFF0B01),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SvgPicture.asset("assets/Images/HomeScreen/calendar_icon.svg", width: 12),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(fontSize: 10, color: const Color(0XFF909090)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SvgPicture.asset("assets/Images/HomeScreen/time_icon.svg", width: 12),
                  const SizedBox(width: 4),
                  Text(
                    timeStr,
                    style: GoogleFonts.poppins(fontSize: 10, color: const Color(0XFF909090)),
                  ),
                ],
              ),
            ],
          ),
        ],
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
              padding: const EdgeInsets.only(left: 25, bottom: 30),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502).withValues(alpha: 0.8)
                  ],
                ),
              ),
              child: Text(
                "ANALYTICS",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
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
          right: 25,
          bottom: 25,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0XFFFF0B01),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.all(15),
            child: SvgPicture.asset(
              "assets/Images/StaffAnalyticsScreen/floating_icon_staff.svg",
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              height: 25,
            ),
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}