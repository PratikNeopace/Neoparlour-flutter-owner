import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/staff_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/leave_requests_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../Owner/owner_home_screen.dart';
import '../../../data/services/appointment_service.dart';
import '../../../data/services/inventory_service.dart';
import '../../../data/services/analytics_service.dart';
import '../../../data/models/appointment_response.dart';
import '../../../data/models/inventory_model.dart';
import '../../../data/models/revenue_model.dart';
import 'package:intl/intl.dart';

class StaffAnalyticsScreen extends StatefulWidget {
  const StaffAnalyticsScreen({super.key});

  @override
  State<StaffAnalyticsScreen> createState() => _StaffAnalyticsScreenState();
}

class _StaffAnalyticsScreenState extends State<StaffAnalyticsScreen> {
  String _selectedPeriod = 'Weekly';
  final AnalyticsService _analyticsService = AnalyticsService();
  List<RevenuePointDTO> _revenueData = [];
  bool _isGraphLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRevenueGraphData();
    });
  }

  Future<void> _fetchRevenueGraphData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffId = authProvider.user?.id;
    if (staffId == null) return;

    setState(() {
      _isGraphLoading = true;
    });

    try {
      final viewType = _selectedPeriod.toLowerCase() == 'daily' 
          ? 'day' 
          : (_selectedPeriod.toLowerCase() == 'weekly' ? 'week' : 'month');
      
      final data = await _analyticsService.getRevenueGraph(
        viewType,
        staffId: staffId,
        onlyOffers: false,
      );

      setState(() {
        _revenueData = data;
        _isGraphLoading = false;
      });
    } catch (e) {
      setState(() {
        _isGraphLoading = false;
      });
      if (mounted) {
        FlushbarHelper.show(context, "Error fetching graph data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const StaffBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final role = authProvider.user?.role;
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
          width: 24,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(size),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 32),
                  _buildBookingsSection(),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: StaffHeaderClipper(),
          child: Container(
            height: 225,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Images/StaffAnalyticsScreen/background_image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 24, bottom: 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                    const Color(0XFFFF3502).withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "ANALYTICS",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
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
          right: 32,
          bottom: 0,
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0XFFFF0B01),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                "assets/Images/StaffAnalyticsScreen/floating_icon_staff.svg",
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                width: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard("Inventory", "View Details", 0.6, onTap: () {
          _showInventoryDetailsPopup(context);
        }),
        _buildStatCard("Rescheduled", "View Details", 0.4, onTap: () {
          _showAppointmentDetailsPopup(context, "rescheduled");
        }),
        _buildStatCard("Cancelled", "View Details", 0.3, onTap: () {
          _showAppointmentDetailsPopup(context, "cancelled");
        }),
        _buildStatCard("Leave Requests", "View Details", 0.8, onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LeaveRequestsScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(String title, String subtitle, double progress, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            Stack(
              children: [
                Container(
                  height: 9,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0XFFFF0B01),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDetailsPopup(BuildContext context, String status) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffId = authProvider.user?.id;

    if (staffId == null) return;

    showDialog(
      context: context,
      builder: (context) => AppointmentDetailsDialog(
        status: status,
        staffId: staffId,
      ),
    );
  }

  void _showInventoryDetailsPopup(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffId = authProvider.user?.id;

    if (staffId == null) return;

    showDialog(
      context: context,
      builder: (context) => InventoryDetailsDialog(
        staffId: staffId,
      ),
    );
  }

  Widget _buildBookingsSection() {
    double maxRevenue = 0;
    for (var point in _revenueData) {
      if (point.revenue > maxRevenue) maxRevenue = point.revenue;
    }
    double maxY = maxRevenue < 100 ? 100 : maxRevenue * 1.2;

    List<FlSpot> spots = _revenueData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.revenue);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "REVENUE TREND GRAPH",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedPeriod = newValue);
                      _fetchRevenueGraphData();
                    }
                  },
                  items: <String>['Daily', 'Weekly', 'Monthly']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 280,
          width: double.infinity,
          padding: const EdgeInsets.only(right: 20, top: 16, bottom: 10, left: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isGraphLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
              : _revenueData.isEmpty
                  ? Center(child: Text("No revenue data available", style: GoogleFonts.poppins(color: Colors.grey)))
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: maxY,
                        gridData: const FlGridData(show: false),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (spot) => const Color(0XFF7A3FDB).withValues(alpha: 0.9),
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                return LineTooltipItem(
                                  "₹${barSpot.y.toStringAsFixed(0)}",
                                  GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < _revenueData.length) {
                                  // Skip some labels for better readability on small screens if many points
                                  if (_revenueData.length > 7 && index % (index < 7 ? 1 : 2) != 0) {
                                    return const SizedBox();
                                  }

                                  String label = _revenueData[index].label;
                                  if (label.length > 5 && label.contains('-')) {
                                    final parts = label.split('-');
                                    if (parts.length >= 3) {
                                      label = "${parts[2]}/${parts[1]}";
                                    }
                                  }

                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 12,
                                    child: Transform.rotate(
                                      angle: -0.6,
                                      child: Text(
                                        label,
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
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const SizedBox();
                                return Text(
                                  NumberFormat.compact().format(value),
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                              color: const Color(0XFF7A3FDB).withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }
  }


class StaffHeaderClipper extends CustomClipper<Path> {
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

class AppointmentDetailsDialog extends StatefulWidget {
  final String status;
  final int staffId;

  const AppointmentDetailsDialog({
    super.key,
    required this.status,
    required this.staffId,
  });

  @override
  State<AppointmentDetailsDialog> createState() => _AppointmentDetailsDialogState();
}

class _AppointmentDetailsDialogState extends State<AppointmentDetailsDialog> {
  final AppointmentService _appointmentService = AppointmentService();
  bool _isLoading = true;
  PaginatedAppointments? _paginatedData;
  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _appointmentService.fetchAppointments(
        staffId: widget.staffId,
        status: widget.status,
        page: _currentPage,
        size: _pageSize,
      );
      setState(() {
        _paginatedData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        FlushbarHelper.show(context, "Error fetching appointments: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.status.toUpperCase();
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$title DETAILS",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
                  : _paginatedData == null || _paginatedData!.content.isEmpty
                      ? Center(
                          child: Text(
                            "No $title appointments found.",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _paginatedData!.content.length,
                          itemBuilder: (context, index) {
                            final appointment = _paginatedData!.content[index];
                            return _buildAppointmentCard(appointment);
                          },
                        ),
            ),
            if (_paginatedData != null && _paginatedData!.totalPages > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() => _currentPage--);
                              _fetchAppointments();
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                    ),
                    Text(
                      "Page ${_currentPage + 1} of ${_paginatedData!.totalPages}",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    IconButton(
                      onPressed: _currentPage < _paginatedData!.totalPages - 1
                          ? () {
                              setState(() => _currentPage++);
                              _fetchAppointments();
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(appointment.appointmentAt.toLocal());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appointment.customerName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                "₹${appointment.finalAmount.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0XFFFF0B01),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          if (appointment.customerMobile != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 12, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  appointment.customerMobile!,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: appointment.serviceNames.map((name) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                name,
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class InventoryDetailsDialog extends StatefulWidget {
  final int staffId;

  const InventoryDetailsDialog({
    super.key,
    required this.staffId,
  });

  @override
  State<InventoryDetailsDialog> createState() => _InventoryDetailsDialogState();
}

class _InventoryDetailsDialogState extends State<InventoryDetailsDialog> {
  final InventoryService _inventoryService = InventoryService();
  bool _isLoading = true;
  List<StaffInventoryResponse>? _inventoryList;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _inventoryService.getStaffInventoryByStaffId(widget.staffId);
      setState(() {
        _inventoryList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        FlushbarHelper.show(context, "Error fetching inventory: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "INVENTORY DETAILS",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
                  : _inventoryList == null || _inventoryList!.isEmpty
                      ? Center(
                          child: Text(
                            "No inventory items found.",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _inventoryList!.length,
                          itemBuilder: (context, index) {
                            final item = _inventoryList![index];
                            return _buildInventoryCard(item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(StaffInventoryResponse item) {
    final assignedAt = item.assignedAt != null 
        ? DateFormat('dd MMM yyyy').format(item.assignedAt!.toLocal())
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.inventoryName ?? "Unknown Product",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0XFFFF0B01).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "ID: ${item.id}",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0XFFFF0B01),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoColumn("Allocated", item.allocatedQuantity.toStringAsFixed(1)),
              const SizedBox(width: 24),
              _buildInfoColumn("Remaining", item.remainingQuantity?.toStringAsFixed(1) ?? '0.0'),
              const SizedBox(width: 24),
              _buildInfoColumn("Used", item.usedQuantity?.toStringAsFixed(1) ?? '0.0'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoColumn("Number of appoinement", "${item.appointmentCount ?? 0}"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Assigned By: ${item.assignedBy ?? 'N/A'}",
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                  ),
                  Text(
                    "Date: $assignedAt",
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (item.notes != null && item.notes!.isNotEmpty)
                Tooltip(
                  message: item.notes!,
                  child: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
