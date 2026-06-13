import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:neo_parlour_owner/providers/analytics_provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final salonId = int.tryParse(authProvider.user?.tenantName ?? '');
      Provider.of<AnalyticsProvider>(context, listen: false).fetchRevenueGraph(salonId: salonId);
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
        provider.setDateRange(provider.graphStartDate, picked, salonId: salonId);
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
        onPressed: () => Navigator.pop(context),
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
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildViewTypeDropdown(provider),
                      const SizedBox(height: 15),
                      _buildDateRangePickers(context, provider),
                      const SizedBox(height: 25),
                      const Text(
                        "REVENUE TRENDS",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 15),
                      provider.isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
                              ),
                            )
                          : provider.errorMessage != null
                              ? Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)))
                              : _buildChart(provider),
                      const SizedBox(height: 30),
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

  Widget _buildViewTypeDropdown(AnalyticsProvider provider) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0XFFF8F8F8),
        border: Border.all(color: const Color(0XFF909090)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: provider.viewType,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0XFF909090)),
          items: ['day', 'week', 'month', 'year'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value.toUpperCase(), style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              provider.setViewType(newValue, salonId: int.tryParse(auth.user?.tenantName ?? ''));
            }
          },
        ),
      ),
    );
  }

  Widget _buildDateRangePickers(BuildContext context, AnalyticsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _dateButton(
            context,
            provider.graphStartDate == null ? "Start Date" : DateFormat('dd/MM/yy').format(provider.graphStartDate!),
            true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _dateButton(
            context,
            provider.graphEndDate == null ? "End Date" : DateFormat('dd/MM/yy').format(provider.graphEndDate!),
            false,
          ),
        ),
      ],
    );
  }

  Widget _dateButton(BuildContext context, String text, bool isStart) {
    return InkWell(
      onTap: () => _selectDate(context, isStart),
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const Icon(Icons.calendar_month, size: 18, color: Color(0XFFFF0B01)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(AnalyticsProvider provider) {
    if (provider.revenuePoints.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(child: Text("No data available for this range")),
      );
    }

    double maxRevenue = 0;
    for (var point in provider.revenuePoints) {
      if (point.revenue > maxRevenue) maxRevenue = point.revenue;
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < provider.revenuePoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), provider.revenuePoints[i].revenue));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxRevenue == 0 ? 100 : maxRevenue * 1.2,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                  if (index >= 0 && index < provider.revenuePoints.length) {
                    // Intelligent skipping based on viewType
                    if (provider.viewType == 'day') {
                      // For 24 hours, show every 4th hour and ensure last point is visible
                      if (index % 4 != 0 && index != provider.revenuePoints.length - 1) return const SizedBox();
                    } else if (provider.viewType == 'month') {
                      // For ~30 days, show every 7th day (approx 4 week points as requested)
                      if (index % 7 != 0 && index != provider.revenuePoints.length - 1) return const SizedBox();
                    }
                    // For 'week' (7) and 'year' (12), all labels are shown by default

                    return SideTitleWidget(
                      meta: meta,
                      space: 14.0,
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
              bottom: BorderSide(color: Color(0XFF909090), width: 1),
              left: BorderSide(color: Color(0XFF909090), width: 1),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: const Color(0XFFFF0B01),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0XFFFF0B01),
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0XFFFF0B01).withValues(alpha: 0.1),
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
                  colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent, const Color(0XFFFF3502).withValues(alpha: 0.8)],
                ),
              ),
              child: const Text("REVENUE", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(color: Color(0XFFFF0B01), shape: BoxShape.circle),
            child: SvgPicture.asset("assets/Images/StaffAnalyticsScreen/floating_icon_staff.svg"),
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