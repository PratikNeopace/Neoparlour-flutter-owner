import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/widgets/staff_revenue_dialog.dart';
import 'package:neo_parlour_owner/providers/analytics_provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/widgets/offer_revenue_dialog.dart';
import 'package:neo_parlour_owner/providers/offer_provider.dart';

import 'package:neo_parlour_owner/modules/pages/Owner/widgets/offer_usage_dialog.dart';
import 'package:neo_parlour_owner/providers/attendance_provider.dart';
import 'package:neo_parlour_owner/data/models/offer_model.dart';
import '../../../providers/staff_provider.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';

class AnalyticsMainScreen extends StatefulWidget {
  const AnalyticsMainScreen({super.key});

  @override
  State<AnalyticsMainScreen> createState() => _AnalyticsMainScreenState();
}

class _AnalyticsMainScreenState extends State<AnalyticsMainScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ["REVENUE", "OFFER", "STAFF"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final salonId = int.tryParse(authProvider.user?.tenantName ?? '');
      final analyticsProvider = Provider.of<AnalyticsProvider>(
        context,
        listen: false,
      );
      analyticsProvider.fetchRevenueGraph(salonId: salonId);
      analyticsProvider.fetchTotalRevenue(salonId: salonId);
      analyticsProvider.fetchDashboardData();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final provider = Provider.of<AnalyticsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final salonId = int.tryParse(authProvider.user?.tenantName ?? '');
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0XFFFF0B01),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isStartDate) {
        provider.setDateRange(picked, provider.graphEndDate, salonId: salonId);
      } else {
        provider.setDateRange(
          provider.graphStartDate,
          picked,
          salonId: salonId,
        );
      }
    }
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
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTabMenu(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildTabContent(provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    String title = "ANALYTICS";

    return Stack(
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/Images/StaffAnalyticsScreen/background_image.jpg",
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
                    const Color(0XFFFF3502).withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Text(
                title,
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
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 25,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0XFFFF0B01),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              "assets/Images/StaffAnalyticsScreen/floating_icon_staff.svg",
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  bool isSelected = _selectedTabIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTabIndex = index);
                      final provider = Provider.of<AnalyticsProvider>(
                        context,
                        listen: false,
                      );
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final salonId = int.tryParse(authProvider.user?.tenantName ?? '');

                      bool isOfferTab = _tabs[index] == "OFFER";
                      provider.fetchRevenueGraph(
                        salonId: salonId,
                        onlyOffers: isOfferTab,
                      );
                      provider.fetchTotalRevenue(
                        salonId: salonId,
                        onlyOffers: isOfferTab,
                      );
                      provider.fetchDashboardData();

                      if (_tabs[index] == "STAFF") {
                        context.read<AttendanceProvider>().fetchAttendanceHistory();
                      } else if (_tabs[index] == "OFFER") {
                        context.read<OfferProvider>().fetchOffers();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tabs[index],
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.black
                                  : const Color(0XFFCBC8C8),
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 3,
                            width: 50,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0XFFFF0B01)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 10),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Color(0XFF909090), size: 24),
            onSelected: (value) {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final analyticsProvider = Provider.of<AnalyticsProvider>(
                context,
                listen: false,
              );
              final salonId = int.tryParse(authProvider.user?.tenantName ?? '');
              analyticsProvider.setViewType(value, salonId: salonId);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'day', child: Text("Today")),
              const PopupMenuItem(value: 'week', child: Text("Weekly")),
              const PopupMenuItem(value: 'month', child: Text("Monthly")),
              const PopupMenuItem(value: 'year', child: Text("Yearly")),
              const PopupMenuItem(value: 'custom', child: Text("Custom Range")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(AnalyticsProvider provider) {
    switch (_selectedTabIndex) {
      case 0: // REVENUE
        return _buildRevenueContent(provider);
      case 1: // OFFER
        return _buildOfferContent(provider);
      case 2: // STAFF
        return _buildAttendanceContent(provider);
      default:
        return const Center(child: Text("Select a tab"));
    }
  }

  Widget _buildRevenueContent(AnalyticsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTotalRevenueCard(provider),
        if (provider.viewType == 'custom') ...[
          const SizedBox(height: 30),
          Text(
            "Custom",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          _buildFigmaDatePickers(context, provider),
        ],
        const SizedBox(height: 25),
        const Text(
          "REVENUE TRENDS",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        _buildRevenueChartContainer(provider),
      ],
    );
  }

  Widget _buildTotalRevenueCard(AnalyticsProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0XFFFF0B01),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0XFFFF0B01).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Revenue",
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.trending_up, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.isLoading || (provider.viewType != 'custom' && provider.dashboardData == null))
            const SizedBox(
              height: 38,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          else
            Text(
              "₹ ${provider.totalRevenue.toStringAsFixed(2)}",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w700,
              ),
            ),

          const SizedBox(height: 8),
          Text(
            provider.viewType.toUpperCase(),
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaDatePickers(
      BuildContext context,
      AnalyticsProvider provider,
      ) {
    return Row(
      children: [
        Expanded(
          child: _figmaDatePicker(
            context,
            provider.graphStartDate == null
                ? "Select Date"
                : DateFormat('dd-MM-yyyy').format(provider.graphStartDate!.toLocal()),
                () => _selectDate(context, true),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _figmaDatePicker(
            context,
            provider.graphEndDate == null
                ? "Select Date"
                : DateFormat('dd-MM-yyyy').format(provider.graphEndDate!.toLocal()),
                () => _selectDate(context, false),
          ),
        ),
      ],
    );
  }

  Widget _figmaDatePicker(
      BuildContext context,
      String text,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0XFF909090), width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: Color(0XFF909090),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0XFFCBC8C8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferContent(AnalyticsProvider provider) {
    final List<String> offerTitles = [
      "Claimed Offer",
      "Offer Revenue",
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.25,
          ),
          itemCount: offerTitles.length,
          itemBuilder: (context, index) {
            final title = offerTitles[index];
            return _buildAnalyticsCard(
              title,
              onTap: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final analyticsProvider = Provider.of<AnalyticsProvider>(
                  context,
                  listen: false,
                );

                if (title == "Offer Revenue") {
                  final offerProvider = Provider.of<OfferProvider>(
                    context,
                    listen: false,
                  );

                  showDialog(
                    context: context,
                    builder: (context) => const OfferRevenueDialog(),
                  );

                  await offerProvider.fetchOffers();
                  if (context.mounted) {
                    await analyticsProvider.fetchRevenueForOffers(
                      offers: offerProvider.offers,
                      salonId: int.tryParse(authProvider.user?.tenantName ?? ''),
                    );
                  }
                } else if (title == "Claimed Offer") {
                  showDialog(
                    context: context,
                    builder: (context) => const OfferUsageDialog(),
                  );
                  await analyticsProvider.fetchOfferUsageLimits();
                }
              },
            );
          },
        ),
        const SizedBox(height: 25),
        const Text(
          "ALL OFFERS",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        Consumer<OfferProvider>(
          builder: (context, offerProv, child) {
            if (offerProv.isLoading && offerProv.offers.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
            }

            if (offerProv.offers.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("No offers found.", style: TextStyle(color: Colors.grey)),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offerProv.offers.length,
              itemBuilder: (context, index) {
                final offer = offerProv.offers[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0XFFFF0B01).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_offer, color: Color(0XFFFF0B01), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.name.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              offer.description ?? "No description",
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            offer.discountType.name.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0XFFFF0B01),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${offer.discountValue}${offer.discountType == DiscountType.PERCENTAGE ? '%' : ''} OFF",
                            style: const TextStyle(fontSize: 10, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAttendanceContent(AnalyticsProvider provider) {
    final List<String> staffTitles = [
      "Appointments Per Staff",
      "Staff Revenue",
      // "Total Revenue By Staff",
      // "Total Clients Served"
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.25,
          ),
          itemCount: staffTitles.length,
          itemBuilder: (context, index) {
            final title = staffTitles[index];
            return _buildAnalyticsCard(
              title,
              onTap: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final staffProvider = Provider.of<StaffProvider>(
                  context,
                  listen: false,
                );
                final analyticsProvider = Provider.of<AnalyticsProvider>(
                  context,
                  listen: false,
                );

                showDialog(
                  context: context,
                  builder: (context) => const StaffRevenueDialog(),
                );

                await staffProvider.fetchStaff();
                if (context.mounted) {
                  final isRevenue = title.toLowerCase().contains("revenue");
                  await analyticsProvider.fetchRevenueForStaff(
                    staffMembers: staffProvider.staffMembers,
                    salonId: int.tryParse(authProvider.user?.tenantName ?? ''),
                    isRevenue: isRevenue,
                  );
                }
              },
            );
          },
        ),
        const SizedBox(height: 25),
        const Text(
          "STAFF ATTENDANCE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        Consumer2<AttendanceProvider, StaffProvider>(
          builder: (context, attendanceProv, staffProv, child) {
            if (attendanceProv.isLoading && attendanceProv.attendanceHistory.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)));
            }

            if (attendanceProv.attendanceHistory.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("No attendance records found.", style: TextStyle(color: Colors.grey)),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendanceProv.attendanceHistory.length,
              itemBuilder: (context, index) {
                final attendance = attendanceProv.attendanceHistory[index];

                final staffName = staffProv.staffMembers
                    .where((s) => s.id == attendance.staffId || s.userId == attendance.staffId)
                    .map((s) => s.name)
                    .firstWhere((name) => true, orElse: () => "Staff ID: ${attendance.staffId}");

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0XFFFF0B01).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Color(0XFFFF0B01), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staffName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(attendance.attendanceDate),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: attendance.status.toUpperCase() == 'PRESENT'
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              attendance.status.toUpperCase(),
                              style: TextStyle(
                                color: attendance.status.toUpperCase() == 'PRESENT' ? Colors.green : Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            attendance.checkIn != null
                                ? DateFormat('hh:mm a').format(attendance.checkIn!.toLocal())
                                : "--:--",
                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0XFF909090).withValues(alpha: 0.3),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              onTap != null ? "View Details" : "Coming Soon",
              style: const TextStyle(color: Color(0XFF909090), fontSize: 10),
            ),
            const Spacer(),
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: const Color(0XFFFF0B01),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChartContainer(AnalyticsProvider provider) {
    double maxRevenue = 0;
    for (var point in provider.revenuePoints) {
      if (point.revenue > maxRevenue) maxRevenue = point.revenue;
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < provider.revenuePoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), provider.revenuePoints[i].revenue));
    }

    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.only(right: 20, top: 16, bottom: 10, left: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (provider.viewType == 'custom')
                _buildDateRangeSelectors(context, provider)
              else
                const Spacer(),
              _buildChartFilterDropdown(provider),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: provider.isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
            )
                : provider.revenuePoints.isEmpty
                ? const Center(child: Text("No data available"))
                : LineChart(
              LineChartData(
                minY: 0,
                maxY: maxRevenue == 0 ? 100 : maxRevenue * 1.2,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: const SideTitles(showTitles: false),
                    axisNameWidget: const Text(
                      "Revenue",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF606060),
                      ),
                    ),
                    axisNameSize: 20,
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Date",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF606060),
                        ),
                      ),
                    ),
                    axisNameSize: 25,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 &&
                            index < provider.revenuePoints.length) {
                          if (provider.viewType == 'day') {
                            if (index % 4 != 0 &&
                                index !=
                                    provider.revenuePoints.length - 1) {
                              return const SizedBox();
                            }
                          } else if (provider.viewType == 'month') {
                            if (index % 7 != 0 &&
                                index !=
                                    provider.revenuePoints.length - 1) {
                              return const SizedBox();
                            }
                          }

                          return SideTitleWidget(
                            meta: meta,
                            space: 12,
                            child: Transform.rotate(
                              angle: -0.6,
                              child: Text(
                                provider.revenuePoints[index].label,
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                softWrap: false,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Color(0XFF606060),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0XFF909090),
                      width: 1,
                    ),
                    left: BorderSide(color: Color(0XFF909090), width: 1),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: const Color(0XFF7A3FDB),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0XFF7A3FDB),
                            strokeWidth: 0,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(
                        0XFF7A3FDB,
                      ).withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) =>
                        const Color(0XFF7A3FDB).withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartFilterDropdown(AnalyticsProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0XFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
          const SizedBox(width: 6),
          DropdownButton<String>(
            value: provider.viewType,
            underline: const SizedBox(),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.grey,
            ),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            items: ['day', 'week', 'month', 'year', 'custom'].map((
                String value,
                ) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                provider.setViewType(
                  newValue,
                  salonId: int.tryParse(authProvider.user?.tenantName ?? ''),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelectors(
      BuildContext context,
      AnalyticsProvider provider,
      ) {
    return Row(
      children: [
        _miniDateButton(
          context,
          provider.graphStartDate == null
              ? "From"
              : DateFormat('dd/MM/yy').format(provider.graphStartDate!),
          true,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text("-", style: TextStyle(color: Colors.grey, fontSize: 10)),
        ),
        _miniDateButton(
          context,
          provider.graphEndDate == null
              ? "To"
              : DateFormat('dd/MM/yy').format(provider.graphEndDate!),
          false,
        ),
      ],
    );
  }

  Widget _miniDateButton(BuildContext context, String text, bool isStart) {
    return InkWell(
      onTap: () => _selectDate(context, isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.black),
        ),
      ),
    );
  }
}

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
