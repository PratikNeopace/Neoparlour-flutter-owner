import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/appointment_provider.dart';
import 'package:neo_parlour_owner/data/models/appointment_response.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/owner_bottom_nav_bar.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/appointment_history_screen.dart';
import 'package:neo_parlour_owner/providers/staff_provider.dart';
import 'package:neo_parlour_owner/data/services/invoice_service.dart';
import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';
import 'package:neo_parlour_owner/widgets/pagination_widget.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['booked', 'cancelled', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _fetchData();
    }
  }

  void _fetchData({int page = 0}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final salonId = int.tryParse(authProvider.user?.tenantName ?? '');
    final status = _statuses[_tabController.index];

    Provider.of<AppointmentProvider>(
      context,
      listen: false,
    ).fetchSchedule(salonId: salonId, status: status, page: page, size: 10);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          _fetchData();
        },
        color: const Color(0XFFFF0B01),
        child: Column(
          children: [
            _buildHeader(context),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: const Color(0XFF909090),
              indicatorColor: const Color(0XFFFF0B01),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "SCHEDULED"),
                Tab(text: "CANCELLED"),
                Tab(text: "COMPLETED"),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "To Mark appointment as complete connect with the staff",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0XFF909090),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Consumer<AppointmentProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading &&
                      provider.scheduleAppointments.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0XFFFF0B01),
                      ),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return TabBarView(
                    controller: _tabController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Managed by buttons/tabs
                    children: [
                      _buildAppointmentList(
                        provider.scheduleAppointments,
                        provider,
                      ),
                      _buildAppointmentList(
                        provider.scheduleAppointments,
                        provider,
                      ),
                      _buildAppointmentList(
                        provider.scheduleAppointments,
                        provider,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const OwnerBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
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
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppointmentList(
    List<Appointment> appointments,
    AppointmentProvider provider,
  ) {
    if (appointments.isEmpty) {
      return const Center(
        child: Text(
          "No appointments found",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length + 1,
      itemBuilder: (context, index) {
        if (index == appointments.length) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 80,
            ), // Add padding to avoid being covered by FAB
            child: PaginationWidget(
              currentPage: provider.scheduleCurrentPage,
              totalPages: provider.scheduleTotalPages,
              onPageSelected: (page) => _fetchData(page: page),
            ),
          );
        }
        return AppointmentCard(appointment: appointments[index]);
      },
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
                image: AssetImage(
                  'assets/Images/ScheduleScreen/background_schedule.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    const Color(0XFFFF3502).withValues(alpha: 0.7),
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
              backgroundColor: Colors.white.withValues(alpha: 0.4),
              child: const Icon(Icons.chevron_left, color: Colors.black),
            ),
          ),
        ),
        const Positioned(
          bottom: 30,
          left: 23,
          child: Text(
            "SCHEDULE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          right: 30,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0XFFFF0B01),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              "assets/Images/ScheduleScreen/floating_icon.svg",
            ),
          ),
        ),
      ],
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const AppointmentCard({super.key, required this.appointment});

  bool isPastAppointment(String? appointmentAt) {
    try {
      if (appointmentAt == null) return true;
      final appointmentDate = DateTime.parse(appointmentAt).toLocal();
      final now = DateTime.now();
      return appointmentDate.isBefore(now);
    } catch (e) {
      return true; // fail-safe
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'dd MMM yyyy',
    ).format(appointment.appointmentAt.toLocal());
    final timeStr = DateFormat(
      'hh:mm a',
    ).format(appointment.appointmentAt.toLocal());
    final status = appointment.status.toLowerCase();

    bool isScheduled =
        status == 'booked' || status == 'rescheduled' || status == 'scheduled';
    bool isCancelled = status == 'cancelled';


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
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header: User Info
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(
                      'assets/Images/HomeScreen/circle_avatar.jpg',
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          appointment.serviceNames.join(", "),
                          style: const TextStyle(
                            color: Color(0XFF909090),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (appointment.staffName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Staff: ${appointment.staffName}",
                            style: const TextStyle(
                              color: Color(0XFFFF0B01),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/Images/ScheduleScreen/calendar.svg",
                            width: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0XFF606060),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/Images/ScheduleScreen/clock.svg",
                            width: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0XFF606060),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Action Area
              if (isScheduled)
                Visibility(
                  visible: !isPastAppointment(
                    appointment.appointmentAt.toIso8601String(),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleReschedule(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0XFFFF0B01),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                "RESCHEDULE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _handleCancel(context),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0XFF909090),
                                shape: const StadiumBorder(),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                "CANCEL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _handleAssignStaff(context),
                        icon: SvgPicture.asset(
                          "assets/Images/ScheduleScreen/assign_staff.svg",
                          width: 18,
                          height: 18,
                        ),
                        label: const Text(
                          "ASSIGN STAFF",
                          style: TextStyle(
                            color: Color(0XFF8D8D8D),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          shape: const StadiumBorder(),
                          side: const BorderSide(color: Color(0XFFE0E0E0)),
                        ),
                      ),
                    ],
                  ),
                )
              else if (status == 'completed')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await InvoiceService().downloadInvoice(appointment.id);
                      } catch (e) {
                        if (context.mounted) {
                          FlushbarHelper.show(
                            context,
                            "Failed to download invoice: $e",
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFFFF0B01),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "DOWNLOAD INVOICE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? const Color(0XFF909090)
                        : const Color(0XFFFF0B01),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleReschedule(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

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
    if (!context.mounted) return;

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
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, reasonController.text),
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
      await appointmentProvider.rescheduleAppointment(
        appointmentId: appointment.id,
        newDateTime: newDateTime,
        reason: reason,
        salonId: int.tryParse(authProvider.user?.tenantName ?? '') ?? 0,
      );

      if (context.mounted) {
        FlushbarHelper.show(context, "Appointment rescheduled successfully!", isSuccess: true);
      }
    } catch (e) {
      if (context.mounted) {
        FlushbarHelper.show(context, "Error: $e");
      }
    }
  }

  Future<void> _handleCancel(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("BACK", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, reasonController.text),
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
      await appointmentProvider.cancelAppointment(
        appointmentId: appointment.id,
        reason: reason,
        salonId: int.tryParse(authProvider.user?.tenantName ?? '') ?? 0,
      );

      if (context.mounted) {
        FlushbarHelper.show(context, "Appointment cancelled!", isSuccess: true);
      }
    } catch (e) {
      if (context.mounted) {
        FlushbarHelper.show(context, "Error: $e");
      }
    }
  }

  void _handleAssignStaff(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _StaffAssignmentDialog(appointment: appointment);
      },
    );
  }
}

class _StaffAssignmentDialog extends StatefulWidget {
  final Appointment appointment;
  const _StaffAssignmentDialog({required this.appointment});

  @override
  State<_StaffAssignmentDialog> createState() => _StaffAssignmentDialogState();
}

class _StaffAssignmentDialogState extends State<_StaffAssignmentDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formattedTime = widget.appointment.appointmentAt
          .toUtc()
          .toIso8601String();
      final duration = widget.appointment.serviceDuration ?? 30;

      Provider.of<StaffProvider>(context, listen: false).fetchAvailableStaff(
        selectedTime: formattedTime,
        durationMinutes: duration,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Assign New Staff",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Consumer<StaffProvider>(
        builder: (consumerContext, staffProvider, child) {
          if (staffProvider.isLoading) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
              ),
            );
          }

          final staffList = staffProvider.staffMembers.toList();

          if (staffList.isEmpty) {
            return const SizedBox(
              height: 100,
              child: Center(child: Text("No staff available")),
            );
          }

          return SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.separated(
              itemCount: staffList.length,
              separatorBuilder: (separatorContext, index) => const Divider(),
              itemBuilder: (itemContext, index) {
                final staff = staffList[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0XFFFFF0EE),
                    child: Icon(Icons.person, color: Color(0XFFFF0B01)),
                  ),
                  title: Text(
                    staff.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(staff.role),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Color(0XFF909090),
                  ),
                  onTap: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
                    final salonId = int.tryParse(authProvider.user?.tenantName ?? '');

                    try {
                      await appointmentProvider.assignStaffToAppointment(
                        appointmentId: widget.appointment.id,
                        newStaffId: staff.id ?? 0,
                        newStaffName: staff.name,
                        salonId: salonId,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        FlushbarHelper.show(
                          context,
                          "Staff assigned to ${staff.name} successfully",
                          isSuccess: true,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        FlushbarHelper.show(context, "Error: $e");
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "CANCEL",
            style: TextStyle(
              color: Color(0XFF909090),
              fontWeight: FontWeight.bold,
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
