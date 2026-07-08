// ignore_for_file: deprecated_member_use
import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:neo_parlour_owner/core/utils/date_time_utils.dart';
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
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/guest_appointment/guest_booking_state.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/guest_appointment/guest_select_date_time_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/guest_appointment/guest_select_services_screen.dart';
import 'package:neo_parlour_owner/data/models/staff_model.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/extend_appointment/extend_select_services_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/extend_appointment/conflict_reschedule_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/extend_appointment/conflict_assign_staff_screen.dart';
import 'package:neo_parlour_owner/data/models/service_model.dart';
import 'package:neo_parlour_owner/data/models/offer_model.dart';
import 'package:neo_parlour_owner/data/models/package_model.dart';
class HomeStaffScreen extends StatefulWidget {
  const HomeStaffScreen({super.key});

  @override
  State<HomeStaffScreen> createState() => _HomeStaffScreenState();
}

class _HomeStaffScreenState extends State<HomeStaffScreen> {
  bool _isStarting = false;
  bool _showSearch = false;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                    _buildQuickActions(context),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ASSIGNED APPOINTMENTS",
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
                            "See More",
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
                    _buildDateStrip(context),
                    const SizedBox(height: 15),
                    Consumer<AppointmentProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading && provider.appointments.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
                          );
                        }
                        
                        final searchQuery = _searchController.text.toLowerCase();
                        final filteredAppointments = provider.appointments.where((apt) {
                          final aptDate = apt.appointmentAt.toLocal();
                          final isSameDate = aptDate.year == _selectedDate.year &&
                                             aptDate.month == _selectedDate.month &&
                                             aptDate.day == _selectedDate.day;
                          
                          if (!isSameDate) return false;
                          if (searchQuery.isEmpty) return true;

                          final name = apt.customerName.toLowerCase();
                          final mobile = apt.customerMobile?.toLowerCase() ?? '';
                          return name.contains(searchQuery) || mobile.contains(searchQuery);
                        }).toList();

                        if (provider.errorMessage != null && filteredAppointments.isEmpty) {
                          return Center(
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        if (filteredAppointments.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Center(
                                child: Text("No Upcoming appointments found for this date"),
                              ),
                              const SizedBox(height: 20),
                              _buildPaginationWidget(provider),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            ...filteredAppointments.map(
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
      onPageSelected: (page) => provider.goToPage(page: page, staffId: staffId, status: null),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      color: Colors.white, // Or whatever background color matches the body if we want it seamless
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good Morning",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Hello ${auth.user?.name ?? 'Staff'} \u{1F44B}",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                },
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSearch = !_showSearch;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.search, color: Colors.black, size: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StaffNotificationScreen(),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Icon(Icons.notifications_outlined, color: Colors.black, size: 24),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0XFFFF0B01),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_showSearch) ...[
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "Search Appointment",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ],
      ),
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
      FlushbarHelper.show(context, "Checked in successfully", isSuccess: true);
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
      FlushbarHelper.show(context, "Checked out successfully", isSuccess: true);
    } else if (mounted) {
      final errorMsg =
          context.read<AttendanceProvider>().errorMessage ??
          "Failed to check out";
      FlushbarHelper.show(context, errorMsg);
    }
  }

  Widget _buildAttendanceButtons() {
    return Consumer2<AuthProvider, AttendanceProvider>(
      builder: (context, auth, attendance, child) {
        final staffId = auth.user?.id ?? 0;
        final today = DateTime.now();
        final att = attendance.todayAttendance;
        bool hasCheckedIn = false;
        bool hasCheckedOut = false;

        if (att != null) {
          final localDate = att.attendanceDate.toLocal();
          if (localDate.year == today.year && 
              localDate.month == today.month && 
              localDate.day == today.day) {
            hasCheckedIn = att.checkIn != null;
            hasCheckedOut = att.checkOut != null;
          }
        }

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (hasCheckedIn || attendance.isLoading)
                    ? null
                    : () => _handleCheckIn(staffId),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: hasCheckedIn ? Colors.grey.shade300 : const Color(0XFFFF0B01),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: (attendance.isLoading && !hasCheckedIn)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Check In",
                            style: GoogleFonts.poppins(
                              color: hasCheckedIn ? Colors.grey : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
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
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: (!hasCheckedIn || hasCheckedOut)
                        ? Colors.grey.shade300
                        : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: (attendance.isLoading && hasCheckedIn && !hasCheckedOut)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Check Out",
                            style: GoogleFonts.poppins(
                              color: (!hasCheckedIn || hasCheckedOut) ? Colors.grey : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            "Guest\nAppointment",
            "assets/Images/HomeScreen/guest_icon.png",
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0XFFFF0B01)),
                  ),
                ),
              );
              try {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final salonId = authProvider.user?.salonId ?? int.tryParse(authProvider.user?.tenantName ?? '') ?? 0;
                final response = await ApiClient().get('salons/$salonId');
                
                double weekdayDiscount = 0.0;
                if (response.data != null && response.data['weekdayDiscountPercent'] != null) {
                  weekdayDiscount = double.tryParse(response.data['weekdayDiscountPercent'].toString()) ?? 0.0;
                }

                if (context.mounted) {
                  Navigator.pop(context); // dismiss loading dialog
                  final staffId = authProvider.user?.id ?? 0;
                  final staffName = authProvider.user?.name ?? '';
                  final bookingState = GuestBookingState(salonId: salonId)
                    ..weekdayDiscountPercent = weekdayDiscount
                    ..selectedStaff = Staff(id: staffId, name: staffName, phone: '', email: '');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuestSelectServicesScreen(bookingState: bookingState),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // dismiss loading dialog
                  FlushbarHelper.show(context, "Failed to load salon details: $e");
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String assetPath, {VoidCallback? onTap, bool isIcon = false, IconData? iconData}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isIcon && iconData != null)
              Icon(iconData, color: Colors.grey.shade600, size: 24)
            else
              Image.asset(assetPath, width: 24, height: 24, errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: Colors.grey.shade600, size: 24)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateStrip(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E2E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMM').format(_selectedDate).toUpperCase(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 30, // Show next 30 days
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index - 5)); // Allow some past days too, or start from today. Let's start from today for simplicity, wait, mockup shows dates. Let's just do from today.
                final actualDate = DateTime.now().add(Duration(days: index));
                final isSelected = actualDate.year == _selectedDate.year &&
                                   actualDate.month == _selectedDate.month &&
                                   actualDate.day == _selectedDate.day;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = actualDate;
                    });
                    final authProvider = context.read<AuthProvider>();
                    if (authProvider.user != null) {
                      context.read<AppointmentProvider>().fetchUpcomingAppointments(
                        staffId: authProvider.user!.id,
                        status: null,
                        specificDate: actualDate,
                      );
                    }
                  },
                  child: Container(
                    width: 45,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0XFFFF0B01) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d').format(actualDate),
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat('EEE').format(actualDate),
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handleExtend(Appointment apt) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExtendSelectServicesScreen(appointment: apt),
      ),
    );

    if (result != null && mounted) {
      final addedServices = result['addedServices'] as List<NeoService>;
      final addedOffer = result['addedOffer'] as Offer?;
      final addedPackage = result['addedPackage'] as ServicePackage?;
      final addedDuration = result['addedDuration'] as int;
      final addedPrice = result['addedPrice'] as double;

      final newServices = List<AppointmentServiceItem>.from(apt.services ?? []);
      for (var s in addedServices) {
        newServices.add(AppointmentServiceItem(
          id: 0,
          serviceId: s.id.toString(),
          serviceName: s.name,
          price: s.price,
          duration: s.duration,
        ));
      }
      if (addedPackage != null) {
        for (var s in addedPackage.services) {
          newServices.add(AppointmentServiceItem(
            id: 0,
            serviceId: s.id.toString(),
            serviceName: s.name,
            price: s.price,
            duration: s.duration,
          ));
        }
      }

      final updatedApt = apt.copyWith(
        serviceDuration: (apt.serviceDuration ?? 0) + addedDuration,
        totalPrice: apt.totalPrice + addedPrice,
        finalAmount: apt.finalAmount + addedPrice,
        offerId: addedOffer?.id ?? apt.offerId,
        offerName: addedOffer?.name ?? apt.offerName,
        packageId: addedPackage?.id ?? apt.packageId,
        packageName: addedPackage?.name ?? apt.packageName,
        services: newServices,
      );

      try {
        await context.read<AppointmentProvider>().extendAppointment(
          originalAppointment: apt,
          updatedAppointment: updatedApt,
        );
        if (mounted) {
          FlushbarHelper.show(context, "Appointment extended successfully!", isSuccess: true);
        }
      } catch (e) {
        if (mounted) {
          final errorMsg = e.toString();
          if (errorMsg.contains('Conflict detected')) {
            _showConflictDialog(errorMsg, apt);
          } else {
            FlushbarHelper.show(context, "Failed to extend appointment: $errorMsg");
          }
        }
      }
    }
  }

  void _showConflictDialog(String conflictMessage, Appointment currentApt) {
    // Parse the message to extract collided appointment IDs and names
    // Example: - Appointment ID: 15 for John Doe at 06:00 PM.
    final RegExp regExp = RegExp(r"Appointment ID:\s*(\d+)\s*for\s*(.*?)\s*at\s*(.*?)\.");
    final Iterable<RegExpMatch> matches = regExp.allMatches(conflictMessage);

    List<Map<String, dynamic>> collidedAppointments = [];
    for (final match in matches) {
      if (match.groupCount >= 3) {
        collidedAppointments.add({
          'id': int.tryParse(match.group(1)!) ?? 0,
          'name': match.group(2)!.trim(),
          'time': match.group(3)!.trim(),
          'details': '${match.group(2)} at ${match.group(3)}',
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Conflict Detected", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Extending this appointment collides with:",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 15),
                if (collidedAppointments.isEmpty)
                  Text(conflictMessage, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]))
                else
                  ...collidedAppointments.map((c) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ID: ${c['id']} • ${c['details']}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ConflictRescheduleScreen(
                                              collidedAppointmentId: c['id'],
                                              staffId: currentApt.staffId ?? 0,
                                              durationMinutes: 30, // approximate
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          if (mounted) FlushbarHelper.show(context, "Rescheduled successfully", isSuccess: true);
                                          _refreshData();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        side: BorderSide(color: Colors.grey.shade300),
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                      ),
                                      child: Text("Reschedule", style: GoogleFonts.poppins(fontSize: 11)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        // Convert 'time' e.g. "06:00 PM" to ZonedDateTime string for backend
                                        String timeStr = c['time'];
                                        try {
                                          final parsed = DateFormat("hh:mm a").parse(timeStr);
                                          final aptDate = currentApt.appointmentAt.toLocal();
                                          final combined = DateTime(
                                            aptDate.year, 
                                            aptDate.month, 
                                            aptDate.day, 
                                            parsed.hour, 
                                            parsed.minute
                                          );
                                          timeStr = DateTimeUtils.toIstIsoString(combined);
                                        } catch (e) {
                                          // ignore, pass raw
                                        }

                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ConflictAssignStaffScreen(
                                              collidedAppointmentId: c['id'],
                                              appointmentTimeStr: timeStr,
                                              durationMinutes: 30, // approximate
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          if (mounted) FlushbarHelper.show(context, "Staff assigned successfully", isSuccess: true);
                                          _refreshData();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0XFFFF0B01),
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                      ),
                                      child: Text("Assign Staff", style: GoogleFonts.poppins(fontSize: 11, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey[700])),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentCard(Appointment apt) {
    final startTime = apt.appointmentAt.toLocal();
    final endTime = apt.estimatedEndAt?.toLocal() ?? startTime.add(Duration(minutes: apt.serviceDuration ?? 0));
    final startTimeStr = DateFormat('hh:mm a').format(startTime);
    final endTimeStr = DateFormat('hh:mm a').format(endTime);
    final dateStr = DateFormat('dd MMM yyyy').format(startTime);
    final serviceStr = apt.serviceNames.join(', ');
    final status = apt.status.toUpperCase();
    
    String nextApptStr = "--";
    if (apt.nextAppointmentAt != null) {
      nextApptStr = DateFormat('hh:mm a').format(apt.nextAppointmentAt!.toLocal());
    }

    final showActionGrid = status == 'BOOKED' || status == 'RESCHEDULED' || status == 'STARTED' || status == 'IN_PROGRESS';

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!showActionGrid)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE0E0E0),
                        backgroundImage: AssetImage('assets/Images/HomeScreen/circle_avatar.jpg'),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apt.customerName.isEmpty ? "Customer Name" : apt.customerName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          serviceStr,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (showActionGrid) ...[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse("tel:${apt.customerMobile}");
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.phone, color: Colors.green, size: 18),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Call Now",
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _handleCancel(apt),
                          child: Container(
                            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4, top: 4), // Lifted up a bit
                            child: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 24),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Cancel\nAppointment",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ] else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // view details
                          },
                          child: Text("View details", style: TextStyle(fontSize: 10)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(startTimeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              
              if (showActionGrid) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Appointments Duration", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text("$startTimeStr - $endTimeStr", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Next Appointment at", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(nextApptStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final provider = context.read<AppointmentProvider>();
                          final authProvider = context.read<AuthProvider>();
                          try {
                            await provider.startAppointment(
                              appointmentId: apt.id,
                              staffId: authProvider.user?.id,
                            );
                            if (mounted) FlushbarHelper.show(context, "Appointment started successfully!", isSuccess: true);
                          } catch (e) {
                            if (mounted) FlushbarHelper.show(context, "Error: $e");
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0XFFFFE2E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text("STARTED", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleReschedule(apt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0XFFFFE2E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text("RESCHEDULE", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleExtend(apt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0XFFFFE2E1)),
                          ),
                          alignment: Alignment.center,
                          child: Text("EXTEND", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showCompleteDialog(apt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text("COMPLETED", style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (apt.cancelReason != null && apt.cancelReason!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_outlined, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Cancel Reason: ${apt.cancelReason}",
                          style: const TextStyle(fontSize: 11, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              if (apt.ownerRescheduleReason != null && apt.ownerRescheduleReason!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Owner Reschedule Reason: ${apt.ownerRescheduleReason}",
                          style: const TextStyle(fontSize: 11, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              if (apt.customerRescheduleReason != null && apt.customerRescheduleReason!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Customer Reschedule Reason: ${apt.customerRescheduleReason}",
                          style: const TextStyle(fontSize: 11, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),

              if (!showActionGrid) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleReschedule(apt),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0XFFFF0B01),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        child: Text("RESCHEDULE", style: GoogleFonts.roboto(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleCancel(apt),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        child: Text("CANCEL", style: GoogleFonts.roboto(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (showActionGrid && (status == 'STARTED' || status == 'IN_PROGRESS'))
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  "INPROGRESS",
                  style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          )
        else if (!showActionGrid)
          Container(
            margin: const EdgeInsets.only(bottom: 15),
          ),
      ],
    );
  }

  void _showCompleteDialog(Appointment appointment) {
    if (appointment.status?.toLowerCase() != 'in_progress') {
      FlushbarHelper.show(context, "You can only complete an appointment that has been started.");
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffId = authProvider.user?.id;
    final salonId = authProvider.user?.salonId ?? int.tryParse(authProvider.user?.tenantName ?? '');

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
                              isSuccess: true,
                            );
                            _refreshData();
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
    final localContext = context;
    final authProvider = Provider.of<AuthProvider>(localContext, listen: false);
    final salonId = authProvider.user?.salonId ?? int.tryParse(authProvider.user?.tenantName ?? '') ?? 0;
    
    final bookingState = GuestBookingState(salonId: salonId);
    bookingState.fromAppointment(appointment);

    final bool? success = await Navigator.push(
      localContext,
      MaterialPageRoute(
        builder: (context) => GuestSelectDateTimeScreen(
          bookingState: bookingState,
          isReschedule: true,
          rescheduleAppointment: appointment,
        ),
      ),
    );

    if (success == true && localContext.mounted) {
      FlushbarHelper.show(localContext, "Appointment rescheduled successfully", isSuccess: true);
      _refreshData();
    }
  }

  Future<void> _handleCancel(Appointment appointment) async {
    final localContext = context;
    final authProvider = Provider.of<AuthProvider>(localContext, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(localContext, listen: false);
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: localContext,
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

    if (!localContext.mounted) return;

    try {
      await appointmentProvider.cancelAppointment(
        appointmentId: appointment.id,
        reason: reason,
        salonId: authProvider.user?.salonId ?? int.tryParse(authProvider.user?.tenantName ?? '') ?? 0,
      );

      if (localContext.mounted) {
        FlushbarHelper.show(localContext, "Appointment cancelled!", isSuccess: true);
      }
    } catch (e) {
      if (localContext.mounted) {
        FlushbarHelper.show(localContext, "Error: $e");
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'booked':
        return Colors.green;
      case 'started':
        return Colors.teal;
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
        color: const Color(0XFFFF0B01).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0XFFFF0B01).withValues(alpha: 0.2)),
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

class CallNowButton extends StatelessWidget {
  final String? phoneNumber;

  const CallNowButton({super.key, this.phoneNumber});

  Future<void> _launchCall() async {
    final trimmed = phoneNumber?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: trimmed,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint("Error launching dialer: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = phoneNumber?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: _launchCall,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
        decoration: BoxDecoration(
          color: const Color(0xFFDBFADE),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.call,
              size: 12,
              color: Colors.black,
            ),
            const SizedBox(width: 4),
            Text(
              "Call Now",
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

