import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:neo_parlour_owner/modules/pages/Owner/owner_home_screen.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/providers/attendance_provider.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/widgets/nav_bars/staff_bottom_nav_bar.dart';

class LeaveRequestStaffScreen extends StatefulWidget {
  const LeaveRequestStaffScreen({super.key});

  @override
  State<LeaveRequestStaffScreen> createState() =>
      _LeaveRequestStaffScreenState();
}

class _LeaveRequestStaffScreenState extends State<LeaveRequestStaffScreen> {
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final firstDate = isStart ? DateTime.now() : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0XFFFF0B01), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleSave() async {
    if (_startDate == null ||
        _endDate == null ||
        _reasonController.text.trim().isEmpty) {
      FlushbarHelper.show(context, "Please fill all required fields");
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffId = authProvider.user?.id ?? 0;

    if (staffId == 0) {
      FlushbarHelper.show(context, "Invalid Staff ID");
      return;
    }

    final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
    final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);

    final success = await context.read<AttendanceProvider>().applyLeave(
      staffId: staffId,
      startDate: startDateStr,
      endDate: endDateStr,
      reason: _reasonController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _reasonController.clear();
      setState(() {
        _startDate = null;
        _endDate = null;
      });
      Navigator.pop(
        context,
        true,
      ); // Go back to the dashboard with success status
    } else {
      final errorMsg =
          context.read<AttendanceProvider>().errorMessage ??
          "Failed to submit leave request";
      print("Leave Request Failure: $errorMsg");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FlushbarHelper.show(context, errorMsg);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: const StaffBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
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
        elevation: 4,
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          "assets/Images/BottomNavigationScreen/home_icon.svg",
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= TITLE =================
                  Row(
                    children: [
                      const Icon(Icons.exit_to_app, size: 20),
                      const SizedBox(width: 4),
                      const Text(
                        "LEAVE REQUEST",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Color(0XFFFF0B01),
                    thickness: 2,
                    endIndent: 200,
                  ),
                  const SizedBox(height: 30),

                  // ================= FORM =================
                  _buildDateField(
                    label: "Start Date",
                    selectedDate: _startDate,
                    onTap: () => _selectDate(context, true),
                  ),
                  const SizedBox(height: 20),
                  _buildDateField(
                    label: "End Date",
                    selectedDate: _endDate,
                    onTap: () => _selectDate(context, false),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    "Reason for leave",
                    "assets/Images/Staff/LeaveRequestScreen/reason_icon.svg",
                    controller: _reasonController,
                  ),
                  const SizedBox(height: 40),

                  // ================= BUTTONS =================
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              context.watch<AttendanceProvider>().isLoading
                              ? null
                              : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: context.watch<AttendanceProvider>().isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "SUBMIT REQUEST",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(
                              color: Color(0XFF909090),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderCurveClipper(),
          child: Container(
            height: 225,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/Images/LeaveRequestScreen/background_image.jpg",
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
              child: const Text(
                "LEAVE REQUEST",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
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
              backgroundColor: Colors.white.withOpacity(0.5),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -5,
          right: 22,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0XFFFF0B01),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: SvgPicture.asset(
                  "assets/Images/LeaveRequestScreen/floating_action_btn.svg",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= TEXT FIELD =================
  Widget _buildTextField(
    String hint,
    String icon, {
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: 3,
      minLines: 1,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBC8C8), fontSize: 14),
        filled: true,
        fillColor: const Color(0XFFF8F8F8),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(icon, width: 20, height: 20),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0XFF909090)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0XFFFF0B01)),
        ),
      ),
    );
  }

  // ================= DATE FIELD =================
  Widget _buildDateField({
    required String label,
    DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0XFFF8F8F8),
          border: Border.all(color: const Color(0XFF909090)),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Color(0XFF909090),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              selectedDate != null
                  ? DateFormat('dd MMM yyyy').format(selectedDate)
                  : label,
              style: TextStyle(
                color: selectedDate != null
                    ? Colors.black
                    : const Color(0xFFCBC8C8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
