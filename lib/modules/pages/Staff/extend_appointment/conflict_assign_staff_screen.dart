import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'package:neo_parlour_owner/data/services/appointment_service.dart';
import 'package:neo_parlour_owner/data/models/staff_model.dart';

class ConflictAssignStaffScreen extends StatefulWidget {
  final int collidedAppointmentId;
  final String appointmentTimeStr; // e.g. "18:00" or similar
  final int durationMinutes;

  const ConflictAssignStaffScreen({
    super.key,
    required this.collidedAppointmentId,
    required this.appointmentTimeStr,
    required this.durationMinutes,
  });

  @override
  State<ConflictAssignStaffScreen> createState() =>
      _ConflictAssignStaffScreenState();
}

class _ConflictAssignStaffScreenState extends State<ConflictAssignStaffScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<dynamic> _availableStaff = [];
  bool _isLoading = true;
  int? _selectedStaffId;
  String? _selectedStaffName;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final salonId = authProvider.user?.salonId ?? int.tryParse(authProvider.user?.tenantName ?? '');
      
      final staffList = await _appointmentService.getAvailableStaff(
        widget.appointmentTimeStr,
        widget.durationMinutes,
        salonId: salonId,
      );
      setState(() {
        _availableStaff = staffList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        FlushbarHelper.show(context, "Failed to load staff: $e");
      }
    }
  }

  Future<void> _assignStaff() async {
    if (_selectedStaffId == null) return;
    try {
      await _appointmentService.assignStaff(
        widget.collidedAppointmentId,
        {
          "staffId": _selectedStaffId,
          "staffName": _selectedStaffName,
        },
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        FlushbarHelper.show(context, "Failed to assign staff: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "ASSIGN STAFF TO #${widget.collidedAppointmentId}",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Available Staff at ${widget.appointmentTimeStr}",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: _availableStaff.isEmpty
                        ? Center(child: Text("No staff available for this time.", style: GoogleFonts.poppins()))
                        : ListView.builder(
                            itemCount: _availableStaff.length,
                            itemBuilder: (context, index) {
                              // Safely parse using the Staff model
                              final staffMap = _availableStaff[index] as Map<String, dynamic>;
                              final staff = Staff.fromJson(staffMap);
                              final staffId = staff.id ?? staff.userId ?? 0;
                              final staffName = staff.name;
                              final isSelected = _selectedStaffId == staffId;

                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  title: Text(
                                    staffName,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  trailing: Radio<int>(
                                    value: staffId,
                                    groupValue: _selectedStaffId,
                                    activeColor: const Color(0XFFFF0B01),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedStaffId = val;
                                        _selectedStaffName = staffName;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedStaffId != null ? _assignStaff : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFFFF0B01),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        "Confirm Staff",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
