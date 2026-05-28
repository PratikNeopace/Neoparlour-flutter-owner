import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/staff_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_notification_screen.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/attendance_provider.dart';

import 'package:neo_parlour_owner/modules/pages/Staff/leave_request_staff_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/inventory_staff_screen.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';
import 'package:neo_parlour_owner/providers/appointment_provider.dart';
import 'package:neo_parlour_owner/data/models/appointment_response.dart';
import 'package:neo_parlour_owner/providers/inventory_provider.dart';
import 'package:neo_parlour_owner/data/models/inventory_model.dart';
import 'package:neo_parlour_owner/widgets/pagination_widget.dart';

import 'appointment_staff_screen.dart';

class HomeStaffScreen extends StatefulWidget {
  const HomeStaffScreen({super.key});

  @override
  State<HomeStaffScreen> createState() => _HomeStaffScreenState();
}

class _HomeStaffScreenState extends State<HomeStaffScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<AttendanceProvider>().fetchTodayAttendance(
          authProvider.user!.id,
        );
        context.read<AppointmentProvider>().fetchUpcomingAppointments(
          staffId: authProvider.user!.id,
          status: null,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: const StaffBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _refreshData();
        },
        backgroundColor: const Color(0XFFFF0B01),
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          "assets/Images/BottomNavigationScreen/home_icon.svg",
        ),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          _refreshData();
          // wait briefly to show refresh indicator
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ATTENDANCE",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildAttendanceButtons(),
                    const SizedBox(height: 15),
                    _buildAttendanceCard(),
                    const SizedBox(height: 15),
                    _buildNavButtons(context),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "UPCOMING APPOINTMENTS",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AppointmentStaffScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Show All",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0XFFFF0B01),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Consumer<AppointmentProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading &&
                            provider.appointments.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0XFFFF0B01),
                            ),
                          );
                        }
                        if (provider.errorMessage != null &&
                            provider.appointments.isEmpty) {
                          return Center(
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        if (provider.appointments.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Center(
                                child: Text("No Upcoming appointments found"),
                              ),
                              const SizedBox(height: 20),
                              _buildPaginationWidget(provider),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            ...provider.appointments.map(
                              (apt) => _buildAppointmentCard(apt),
                            ),
                            const SizedBox(height: 20),
                            _buildPaginationWidget(provider),
                            const SizedBox(height: 15),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationWidget(AppointmentProvider provider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffId = authProvider.user?.id;

    return PaginationWidget(
      currentPage: provider.currentPage,
      totalPages: provider.totalPages,
      onPageSelected: (page) => provider.goToPage(page: page, staffId: staffId),
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
                image: AssetImage(
                  "assets/Images/CreateInvoiceScreen/background_image.jpg",
                ),
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
                    const Color(0XFFFF3502).withOpacity(0.7),
                  ],
                ),
              ),
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return Text(
                    "WELCOME ${auth.user?.name.toUpperCase() ?? 'STAFF'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 20,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StaffNotificationScreen(),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceButtons() {
    return Consumer2<AuthProvider, AttendanceProvider>(
      builder: (context, auth, attendance, child) {
        final staffId = auth.user?.id ?? 0;
        final hasCheckedIn = attendance.todayAttendance?.checkIn != null;
        final hasCheckedOut = attendance.todayAttendance?.checkOut != null;

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (hasCheckedIn || attendance.isLoading)
                    ? null
                    : () => _handleCheckIn(staffId),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildOutlinedBox(
                      "Check In",
                      color: hasCheckedIn ? Colors.grey.shade300 : null,
                      textColor: (hasCheckedIn || attendance.isLoading)
                          ? Colors.grey
                          : null,
                    ),
                    if (attendance.isLoading && !hasCheckedIn)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0XFFFF0B01),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (!hasCheckedIn || hasCheckedOut || attendance.isLoading)
                    ? null
                    : () => _handleCheckOut(staffId),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildOutlinedBox(
                      "Check Out",
                      color: (!hasCheckedIn || hasCheckedOut)
                          ? Colors.grey.shade300
                          : null,
                      textColor:
                          (!hasCheckedIn ||
                              hasCheckedOut ||
                              attendance.isLoading)
                          ? Colors.grey
                          : null,
                    ),
                    if (attendance.isLoading && hasCheckedIn && !hasCheckedOut)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0XFFFF0B01),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleCheckIn(int staffId) async {
    debugPrint("DEBUG: Check-in clicked for staffId: $staffId");
    if (staffId == 0) {
      FlushbarHelper.show(context, "Error: Invalid Staff ID");
      return;
    }
    final success = await context.read<AttendanceProvider>().checkIn(staffId);
    if (success && mounted) {
      FlushbarHelper.show(context, "Checked in successfully");
    } else if (mounted) {
      final errorMsg =
          context.read<AttendanceProvider>().errorMessage ??
          "Failed to check in";
      FlushbarHelper.show(context, errorMsg);
    }
  }

  void _handleCheckOut(int staffId) async {
    debugPrint("DEBUG: Check-out clicked for staffId: $staffId");
    if (staffId == 0) {
      FlushbarHelper.show(context, "Error: Invalid Staff ID");
      return;
    }
    final success = await context.read<AttendanceProvider>().checkOut(staffId);
    if (success && mounted) {
      FlushbarHelper.show(context, "Checked out successfully");
    } else if (mounted) {
      final errorMsg =
          context.read<AttendanceProvider>().errorMessage ??
          "Failed to check out";
      FlushbarHelper.show(context, errorMsg);
    }
  }

  Widget _buildAttendanceCard() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final attendance = provider.todayAttendance;
        final checkInStr = attendance?.checkIn != null
            ? DateFormat('hh:mm a').format(attendance!.checkIn!.toLocal())
            : '--:--';
        final checkOutStr = attendance?.checkOut != null
            ? DateFormat('hh:mm a').format(attendance!.checkOut!.toLocal())
            : '--:--';

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMMM yyyy').format(DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  LiveAttendanceTimer(
                    checkIn: attendance?.checkIn,
                    checkOut: attendance?.checkOut,
                  ),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPunchItem(
                    "Punch In",
                    checkInStr,
                    Icons.login,
                    Colors.green,
                  ),
                  _buildPunchItem(
                    "Punch Out",
                    checkOutStr,
                    Icons.logout,
                    Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaveRequestStaffScreen(),
                ),
              ).then((value) {
                if (value == true && mounted) {
                  FlushbarHelper.show(
                    context,
                    "Request sent to owner successfully",
                    isSuccess: true,
                  );
                }
              });
            },
            child: _buildOutlinedBox("Leave Request", icon: Icons.exit_to_app),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryStaffScreen(),
                ),
              );
            },
            child: _buildOutlinedBox("Inventory", icon: Icons.inventory),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Appointment apt) {
    final timeStr = DateFormat('hh:mm a').format(apt.appointmentAt.toLocal());
    final dateStr = DateFormat(
      'dd MMM yyyy',
    ).format(apt.appointmentAt.toLocal());
    final serviceStr = apt.serviceNames.join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0XFF909090)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              "View details",
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 25.5,
                backgroundColor: Color(0xFFE0E0E0),
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
                      apt.customerName ?? "Customer Name",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      serviceStr,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0XFF909090),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Color(0XFF909090),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0XFF909090),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        size: 16,
                        color: Color(0XFF909090),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0XFF909090),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (apt.status.toUpperCase() == 'BOOKED' ||
              apt.status.toUpperCase() == 'RESCHEDULED') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleReschedule(apt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFFFF0B01),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      "RESCHEDULE",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleCancel(apt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFF909090),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      "CANCEL",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showCompleteDialog(apt),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0XFF909090)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "COMPLETED",
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: const Color(0XFF909090),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _getStatusColor(apt.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: _getStatusColor(apt.status).withOpacity(0.5),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                apt.status.toUpperCase(),
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: _getStatusColor(apt.status),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCompleteDialog(Appointment appointment) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffId = authProvider.user?.id;
    final salonId = int.tryParse(authProvider.user?.tenantName ?? '');

    if (staffId == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<StaffOpenInventoryResponse>>(
          future: context.read<InventoryProvider>().fetchOpenedStaffInventory(
            staffId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
                  ),
                ),
              );
            }

            final items = snapshot.data ?? [];
            // Track usage: Map of {id: int, isFinished: bool}
            Map<int, bool> usageMap = {};
            for (var item in items) {
              usageMap[item.id] = item.isFinished;
            }
            List<int> selectedIds = [];
            bool isNoneSelected = false;

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "Enter Inventories used",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to inventory or handle use inventory
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const InventoryStaffScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Use Inventory",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isNoneSelected,
                                  activeColor: const Color(0XFFFF0B01),
                                  onChanged: (value) {
                                    setState(() {
                                      isNoneSelected = value ?? false;
                                      if (isNoneSelected) {
                                        selectedIds.clear();
                                      }
                                    });
                                  },
                                ),
                                const Expanded(
                                  child: Text(
                                    "None (No inventory used)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final item = items[index - 1];
                        final isSelected = selectedIds.contains(item.id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                activeColor: const Color(0XFFFF0B01),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedIds.add(item.id);
                                      isNoneSelected = false;
                                    } else {
                                      selectedIds.remove(item.id);
                                    }
                                  });
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.inventoryName ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "Opened: ${item.openedQuantity}",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected) ...[
                                const Text(
                                  "Finished?",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                Radio<bool>(
                                  value: true,
                                  groupValue: usageMap[item.id],
                                  activeColor: const Color(0XFFFF0B01),
                                  onChanged: (val) {
                                    setState(() => usageMap[item.id] = true);
                                  },
                                ),
                                const Text(
                                  "Yes",
                                  style: TextStyle(fontSize: 10),
                                ),
                                Radio<bool>(
                                  value: false,
                                  groupValue: usageMap[item.id],
                                  activeColor: const Color(0XFFFF0B01),
                                  onChanged: (val) {
                                    setState(() => usageMap[item.id] = false);
                                  },
                                ),
                                const Text(
                                  "No",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFFFF0B01),
                      ),
                      onPressed: () async {
                        try {
                          // Prepare payload: List<Map<String, dynamic>>
                          final List<Map<String, dynamic>> openedProductUsages =
                              selectedIds.map((id) {
                                return {
                                  'id': id,
                                  'isFinished': usageMap[id] ?? false,
                                };
                              }).toList();

                          await context
                              .read<AppointmentProvider>()
                              .completeAppointment(
                                appointmentId: appointment.id,
                                appointment: appointment,
                                openedProductUsages: openedProductUsages,
                                salonId: salonId,
                                staffId: staffId,
                              );
                          if (context.mounted) {
                            Navigator.pop(context);
                            FlushbarHelper.show(
                              context,
                              "Appointment completed successfully!",
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            FlushbarHelper.show(context, "Error: $e");
                          }
                        }
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _handleReschedule(Appointment appointment) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: appointment.appointmentAt.toLocal(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(appointment.appointmentAt.toLocal()),
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

    if (pickedTime == null) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!context.mounted) return;

    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reschedule Reason"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Enter reason for rescheduling",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0XFFFF0B01)),
            ),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text(
              "RESCHEDULE",
              style: TextStyle(color: Color(0XFFFF0B01)),
            ),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    if (!context.mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      );

      await appointmentProvider.rescheduleAppointment(
        appointmentId: appointment.id,
        newDateTime: newDateTime,
        reason: reason,
        salonId: int.tryParse(authProvider.user?.tenantName ?? '') ?? 0,
      );

      if (context.mounted) {
        FlushbarHelper.show(context, "Appointment rescheduled successfully!");
      }
    } catch (e) {
      if (context.mounted) {
        FlushbarHelper.show(context, "Error: $e");
      }
    }
  }

  Future<void> _handleCancel(Appointment appointment) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancellation Reason"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Enter reason for cancellation",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0XFFFF0B01)),
            ),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BACK", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text(
              "CANCEL APPOINTMENT",
              style: TextStyle(color: Color(0XFFFF0B01)),
            ),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    if (!context.mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      );

      await appointmentProvider.cancelAppointment(
        appointmentId: appointment.id,
        reason: reason,
        salonId: int.tryParse(authProvider.user?.tenantName ?? '') ?? 0,
      );

      if (context.mounted) {
        FlushbarHelper.show(context, "Appointment cancelled!");
      }
    } catch (e) {
      if (context.mounted) {
        FlushbarHelper.show(context, "Error: $e");
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'booked':
        return Colors.green;
      case 'rescheduled':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPunchItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildOutlinedBox(
    String text, {
    IconData? icon,
    Color? color,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 16, color: textColor),
          if (icon != null) const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Header Clipper ---
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

class LiveAttendanceTimer extends StatefulWidget {
  final DateTime? checkIn;
  final DateTime? checkOut;

  const LiveAttendanceTimer({super.key, this.checkIn, this.checkOut});

  @override
  State<LiveAttendanceTimer> createState() => _LiveAttendanceTimerState();
}

class _LiveAttendanceTimerState extends State<LiveAttendanceTimer> {
  Timer? _timer;
  late String _durationStr;

  @override
  void initState() {
    super.initState();
    _durationStr = "00h : 00m : 00s";
    _updateDuration();
    _setupTimer();
  }

  void _setupTimer() {
    _timer?.cancel();
    if (widget.checkIn != null && widget.checkOut == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateDuration();
      });
    }
  }

  @override
  void didUpdateWidget(covariant LiveAttendanceTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checkIn != oldWidget.checkIn ||
        widget.checkOut != oldWidget.checkOut) {
      _updateDuration();
      _setupTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateDuration() {
    if (widget.checkIn == null) {
      if (mounted) setState(() => _durationStr = "00h : 00m : 00s");
      return;
    }

    final endTime = widget.checkOut ?? DateTime.now();
    final diff = endTime.difference(widget.checkIn!);

    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (mounted) {
      setState(() {
        _durationStr = "${hours}h : ${minutes}m : ${seconds}s";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0XFFFF0B01).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0XFFFF0B01).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 16, color: Color(0XFFFF0B01)),
          const SizedBox(width: 8),
          Text(
            _durationStr,
            style: GoogleFonts.poppins(
              color: const Color(0XFFFF0B01),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
