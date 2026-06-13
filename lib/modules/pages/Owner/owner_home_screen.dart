import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/appointment_provider.dart';
import 'package:neo_parlour_owner/providers/analytics_provider.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/analytics_two_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/appointment_history_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/notification_screen.dart';
import 'package:neo_parlour_owner/data/models/appointment_response.dart';
import 'package:neo_parlour_owner/main.dart'; // To access global routeObserver
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';
import 'package:neo_parlour_owner/widgets/pagination_widget.dart';
import 'package:neo_parlour_owner/providers/staff_provider.dart';
import 'package:neo_parlour_owner/data/models/staff_model.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshData();
    });
  }

  void _onScroll() {
    // Infinite scroll disabled in favor of manual pagination
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route events
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and this route shows up
    debugPrint("DEBUG: Returning to Home Screen, refreshing data...");
    _refreshData();
  }

  void _refreshData() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final salonId = authProvider.user?.salonId ?? authProvider.user?.id;

    debugPrint("DEBUG: _refreshData triggered. SalonId: $salonId");

    if (salonId == null) return; // prevent invalid API calls

    // Perform fetch
    context.read<AppointmentProvider>().fetchUpcomingAppointments(salonId: salonId, size: 10);
    
    final analyticsProvider = context.read<AnalyticsProvider>();
    analyticsProvider.fetchTotalRevenue(salonId: salonId);
    analyticsProvider.fetchDashboardData();
  }

  Future<void> _handleReschedule(Appointment appointment) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: appointment.appointmentAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0XFFFF0B01)),
        ),
        child: child!,
      ),
    );

    if (pickedDate == null || !mounted) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(appointment.appointmentAt),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0XFFFF0B01)),
        ),
        child: child!,
      ),
    );

    if (pickedTime == null || !mounted) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final reasonController = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reschedule Reason"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Enter reason for rescheduling...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFFFF0B01),
            ),
            child: const Text(
              "RESCHEDULE",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      );

      try {
        await appointmentProvider.rescheduleAppointment(
          appointmentId: appointment.id,
          newDateTime: newDateTime,
          reason: reasonController.text,
          salonId: int.tryParse(authProvider.user?.tenantName ?? '') ?? 0,
        );
        if (mounted) {
          FlushbarHelper.show(context, "Appointment rescheduled successfully", isSuccess: true);
          _refreshData();
        }
      } catch (e) {
        if (mounted) {
          FlushbarHelper.show(context, "Error: $e");
        }
      }
    }
  }

  Future<void> _handleCancel(Appointment appointment) async {
    final reasonController = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Appointment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to cancel this appointment?"),
            const SizedBox(height: 15),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: "Enter cancellation reason...",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("NO"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "CANCEL APPOINTMENT",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      );

      try {
        await appointmentProvider.cancelAppointment(
          appointmentId: appointment.id,
          reason: reasonController.text,
          salonId: int.tryParse(authProvider.user?.tenantName ?? '') ?? 0,
        );
        if (mounted) {
          FlushbarHelper.show(context, "Appointment cancelled successfully", isSuccess: true);
          _refreshData();
        }
      } catch (e) {
        if (mounted) {
          FlushbarHelper.show(context, "Error: $e");
        }
      }
    }
  }

  Future<void> _handleAssignStaff(Appointment appointment) async {
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    
    final formattedTime = appointment.appointmentAt.toUtc().toIso8601String();
    final duration = appointment.serviceDuration ?? 30;

    await staffProvider.fetchAvailableStaff(
        selectedTime: formattedTime, 
        durationMinutes: duration,
    );

    if (!mounted) return;

    final staff = await showDialog<Staff>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Staff"),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<StaffProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.staffMembers.isEmpty) {
                return const Text("No staff available");
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: provider.staffMembers.length,
                itemBuilder: (context, index) {
                  final staff = provider.staffMembers[index];
                  return ListTile(
                    title: Text(staff.name),
                    subtitle: Text(staff.role),
                    onTap: () => Navigator.pop(context, staff),
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    if (staff != null && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

      try {
        await appointmentProvider.assignStaffToAppointment(
          appointmentId: appointment.id,
          newStaffId: staff.id!,
          newStaffName: staff.name,
          salonId: int.tryParse(authProvider.user?.tenantName ?? ''),
        );
        if (mounted) {
          FlushbarHelper.show(context, "Staff assigned successfully", isSuccess: true);
          _refreshData();
        }
      } catch (e) {
        if (mounted) {
          FlushbarHelper.show(context, "Error: $e");
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const OwnerBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        backgroundColor: const Color(0XFFFF0B01),
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          "assets/Images/BottomNavigationScreen/home_icon.svg",
          width: 24,
        ),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final salonId = int.tryParse(authProvider.user?.tenantName ?? '');
          final analyticsProvider = Provider.of<AnalyticsProvider>(
            context,
            listen: false,
          );
          await Future.wait([
            Provider.of<AppointmentProvider>(
              context,
              listen: false,
            ).fetchUpcomingAppointments(salonId: salonId, size: 10),
            analyticsProvider.fetchTotalRevenue(salonId: salonId),
            analyticsProvider.fetchDashboardData(),
          ]);
        },
        color: const Color(0XFFFF0B01),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics:
              const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works even when content is short
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildTodayOverview(),
              const SizedBox(height: 15),
              _buildStatsGrid(),
              const SizedBox(height: 25),
              _buildUpcomingAppointments(),
              const SizedBox(height: 100), // Extra space for bottom nav
            ],
          ),
        ),
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
            height: 316,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/Images/HomeScreen/background_image.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 24, bottom: 40),
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
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 100, bottom: 5),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      final userName = auth.user?.name ?? "Owner";

                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          // "WELCOME ${(auth.user?.name ?? "Owner").toUpperCase()}",
                           "WELCOME ${userName.toUpperCase()}",
                           maxLines: 1,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 250,
          right: 32,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            ),
            child: Container(
              width: 59,
              height: 59,
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
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      "assets/Images/BottomNavigationScreen/notification_icon.svg",
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "1",
                        style: TextStyle(
                          color: Color(0XFFFF0B01),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayOverview() {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        String title = "TODAY OVERVIEW";
        switch (provider.viewType) {
          case 'week':
            title = "WEEKLY OVERVIEW";
            break;
          case 'month':
            title = "MONTHLY OVERVIEW";
            break;
          case 'year':
            title = "YEARLY OVERVIEW";
            break;
          case 'day':
          default:
            title = "TODAY OVERVIEW";
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.sort,
                      color: Color(0XFF8D8D8D),
                      size: 20,
                    ),
                    onSelected: (value) {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final salonId = int.tryParse(authProvider.user?.tenantName ?? '');
                      provider.setViewType(value, salonId: salonId);
                    },
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'day', child: Text("Today")),
                      const PopupMenuItem(value: 'week', child: Text("Weekly")),
                      const PopupMenuItem(
                        value: 'month',
                        child: Text("Monthly"),
                      ),
                      const PopupMenuItem(value: 'year', child: Text("Yearly")),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        final data = provider.dashboardData;
        final periodLabel = provider.getPeriodLabel();
        final List<Map<String, dynamic>> dynamicStats = [
          {
            "title": "Revenue",
            "subtitle": "Total for $periodLabel",
            "value": "₹ ${data?.revenue.toStringAsFixed(0) ?? '0'}",
            "icon": "assets/Images/HomeScreen/revenue_icon.svg",
            "valueColor": const Color(0XFFFF0B01),
          },
          {
            "title": "Bookings",
            "subtitle": "Count for $periodLabel",
            "value": data?.booked.toString() ?? "00",
            "icon": "assets/Images/HomeScreen/today_overview.svg",
            "valueColor": const Color(0XFFFF0B01),
          },
          {
            "title": "Offer Usage",
            "subtitle": "Used $periodLabel",
            "value": data?.offerUsage.toString() ?? "00",
            "icon": "assets/Images/HomeScreen/offer_anaytics_icon.svg",
            "valueColor": const Color(0XFFFF0B01),
          },
          {
            "title": "Completed",
            "subtitle": "Total $periodLabel",
            "value": data?.completed.toString() ?? "00",
            "icon": "assets/Images/HomeScreen/staff_analytics_icon.svg",
            "valueColor": const Color(0XFFFF0B01),
          },
          {
            "title": "Cancelled",
            "subtitle": "Total $periodLabel",
            "value": data?.cancelled.toString() ?? "00",
            "icon": "assets/Images/HomeScreen/staff_attendance_icon.svg",
            "valueColor": const Color(0XFFFF0B01),
          },
          {
            "title": "Rescheduled",
            "subtitle": "Total $periodLabel",
            "value": data?.rescheduled.toString() ?? "00",
            "icon": "assets/Images/HomeScreen/leave_request_icon.svg",
            "valueColor": const Color(0XFFFF0B01),
          },
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dynamicStats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 156 / 111,
            ),
            itemBuilder: (context, index) {
              final stat = dynamicStats[index];
              return GestureDetector(
                onTap: () {
                  if (stat['title'] == "Offer Analytics") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsTwoScreen(),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0XFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0XFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: SvgPicture.asset(
                          stat['icon'],
                          height: 40,
                          colorFilter: ColorFilter.mode(
                            const Color(0XFFE0E0E0).withValues(alpha: 0.5),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stat['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stat['subtitle'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0XFF909090),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (provider.isLoading && data == null)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0XFFFF0B01),
                              ),
                            )
                          else
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                stat['value'],
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: stat['valueColor'],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingAppointments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "UPCOMING APPOINTMENTS",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Consumer<AppointmentProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
                  ),
                );
              }

              if (provider.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (provider.appointments.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "No upcoming appointments",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = provider.appointments[index];
                      final dateStr = DateFormat(
                        'dd MMM yyyy',
                      ).format(appointment.appointmentAt.toLocal());
                      final timeStr = DateFormat(
                        'hh:mm a',
                      ).format(appointment.appointmentAt.toLocal());

                      return GestureDetector(
                        onLongPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentHistoryScreen(
                                userId: appointment.userId,
                                customerName: appointment.customerName,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0XFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 25,
                                    backgroundImage: AssetImage(
                                      'assets/Images/HomeScreen/circle_avatar.jpg',
                                    ),
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
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          appointment.serviceNames.join(", "),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: const Color(0XFF8D8D8D),
                                          ),
                                        ),
                                        if (appointment.staffName.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            "Staff: ${appointment.staffName}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0XFFFF0B01),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        "View details",
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/Images/HomeScreen/calendar_icon.svg",
                                            width: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            dateStr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: const Color(0XFF909090),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/Images/HomeScreen/time_icon.svg",
                                            width: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeStr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: const Color(0XFF909090),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _handleReschedule(appointment),
                                      child: _appointmentButton(
                                        "RESCHEDULE",
                                        const Color(0XFFFF0B01),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _handleCancel(appointment),
                                      child: _appointmentButton(
                                        "CANCEL",
                                        const Color(0XFF909090),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (appointment.staffId == null || appointment.staffId == 0) ...[
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () => _handleAssignStaff(appointment),
                                  child: _appointmentButton(
                                    "ASSIGN STAFF",
                                    const Color(0XFF2196F3),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildPaginationWidget(provider),
                  if (provider.isFetchingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationWidget(AppointmentProvider provider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final salonId = int.tryParse(authProvider.user?.tenantName ?? '');

    return PaginationWidget(
      currentPage: provider.currentPage,
      totalPages: provider.totalPages,
      onPageSelected: (page) => provider.goToPage(page: page, salonId: salonId),
    );
  }

  Widget _appointmentButton(String label, Color bgColor) {
    return Container(
      height: 31,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
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
      size.height * 0.45,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
