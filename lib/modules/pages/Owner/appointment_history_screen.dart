import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/appointment_provider.dart';
import 'package:neo_parlour_owner/data/models/appointment_response.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/widgets/pagination_widget.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  final int userId;
  final String customerName;

  const AppointmentHistoryScreen({
    super.key,
    required this.userId,
    required this.customerName,
  });

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false).fetchHistory(widget.userId);
    });
  }

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
        child: SvgPicture.asset("assets/Images/BottomNavigationScreen/home_icon.svg"),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => provider.fetchHistory(widget.userId),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final appointments = provider.historyAppointments;
          
          // Calculate Stats
          final totalVisits = appointments.length;
          final totalRevenue = appointments.fold(0.0, (sum, item) => sum + item.finalAmount);
          final lastVisit = appointments.isNotEmpty 
              ? DateFormat('dd MMM').format(appointments.first.appointmentAt.toLocal()) 
              : 'N/A';
          final memberSince = appointments.isNotEmpty 
              ? appointments.last.createdAt.year.toString() 
              : '2026';

          return Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text("Member Since $memberSince", style: const TextStyle(color: Color(0XFF909090), fontSize: 11)),
                      const SizedBox(height: 5),
                      _buildStatsRow(totalVisits.toString(), totalRevenue.toStringAsFixed(0), lastVisit),
                      const SizedBox(height: 22),
                      const Text("Appointment History", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                      const SizedBox(height: 16),
                      if (appointments.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text("No history available"),
                        ))
                      else
                        _buildAppointmentList(appointments),
                      const SizedBox(height: 20),
                      PaginationWidget(
                        currentPage: provider.historyCurrentPage,
                        totalPages: provider.historyTotalPages,
                        onPageSelected: (page) =>
                            provider.fetchHistory(widget.userId, page: page),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              padding: const EdgeInsets.only(left: 25, bottom: 60),
              alignment: Alignment.bottomLeft,
              child: const Text("HISTORY", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
        Positioned(
          right: 30, 
          bottom: 0, 
          child: _buildRedFloatingButton()
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
      ],
    );
  }

  Widget _buildStatsRow(String visits, String revenue, String lastVisit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statBox(visits, "Visits", "assets/Images/HistoryScreen/visits.svg"),
        _statBox(revenue, "Revenue", "assets/Images/HistoryScreen/revenue.svg"),
        _statBox(lastVisit, "Last Visit", "assets/Images/HistoryScreen/last_visit.svg"),
      ],
    );
  }

  Widget _statBox(String val, String label, String icon) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0XFFF5F5F5),
        border: Border.all(color: const Color(0XFF909090)), 
        borderRadius: BorderRadius.circular(9)
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SvgPicture.asset(icon),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color(0XFFFF0B01))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0XFF909090), fontWeight: FontWeight.w400)),
      ]),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final item = appointments[index];
        final serviceName = item.serviceNames.isNotEmpty ? item.serviceNames.join(", ") : "No Services";
        final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(item.appointmentAt.toLocal());
        
        Color statusColor = const Color(0XFF4CAF50); // Completed/Booked
        if (item.status.toLowerCase() == 'cancelled') {
          statusColor = const Color(0XFFFF0B01);
        }

        return _appointmentItem(
          serviceName, 
          "₹ ${item.finalAmount.toStringAsFixed(2)}", 
          item.status.toUpperCase(), 
          statusColor,
          formattedDate,
          item.staffName,
        );
      },
    );
  }

  Widget _appointmentItem(String title, String price, String status, Color color, String date, String staffName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0XFFFF0B01)), 
        borderRadius: BorderRadius.circular(9)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SvgPicture.asset("assets/Images/HistoryScreen/calendar.svg"),
                    const SizedBox(width: 4),
                    Text(date, style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w400)),
                  ],
                ),
                if (staffName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 12, color: Color(0XFFFF0B01)),
                      const SizedBox(width: 4),
                      Text("Staff: $staffName", style: const TextStyle(fontSize: 10, color: Color(0XFFFF0B01), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ]),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end, 
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), 
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(3)
                  ),
                child: Text(
                  status, 
                  style: TextStyle(
                    color: color, 
                    fontSize: 8
                    )
                  )
                ),
            ]),
        ],
      ),
    );
  }


  Widget _buildRedFloatingButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0XFFFF0B01), 
        shape: BoxShape.circle
      ),
      child: const Icon(Icons.history, color: Colors.white, size: 28),
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