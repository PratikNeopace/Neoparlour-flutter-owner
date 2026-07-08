import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:neo_parlour_owner/core/utils/date_time_utils.dart';
import 'package:neo_parlour_owner/data/services/appointment_service.dart';
import 'package:neo_parlour_owner/data/models/available_slot.dart';

class ConflictRescheduleScreen extends StatefulWidget {
  final int collidedAppointmentId;
  final int staffId;
  final int durationMinutes;

  const ConflictRescheduleScreen({
    super.key,
    required this.collidedAppointmentId,
    required this.staffId,
    required this.durationMinutes,
  });

  @override
  State<ConflictRescheduleScreen> createState() =>
      _ConflictRescheduleScreenState();
}

class _ConflictRescheduleScreenState extends State<ConflictRescheduleScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _availableSlots = [];
  bool _isLoading = false;
  String? _selectedTime;
  DateTime? _selectedSlotTime;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() {
      _isLoading = true;
      _selectedTime = null;
    });
    try {
      final slots = await _appointmentService.getAvailableSlots(
        widget.staffId,
        _selectedDate,
        widget.durationMinutes,
      );
      setState(() {
        _availableSlots = slots;
      });
    } catch (e) {
      if (mounted) {
        FlushbarHelper.show(context, "Failed to load slots: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0XFFFF0B01),
            colorScheme: const ColorScheme.light(primary: Color(0XFFFF0B01)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchSlots();
    }
  }

  Future<void> _reschedule() async {
    if (_selectedSlotTime == null) return;
    try {
      final newTimeIso = DateTimeUtils.toIstIsoString(_selectedSlotTime!);

      await _appointmentService.rescheduleAppointment(
        widget.collidedAppointmentId,
        newTimeIso,
        "Rescheduled due to staff schedule conflict",
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        FlushbarHelper.show(context, "Failed to reschedule: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "RESCHEDULE APPOINTMENT #${widget.collidedAppointmentId}",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Date",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0XFFFF0B01), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Available Time Slots",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0XFFFF0B01)))
                  : _availableSlots.isEmpty
                      ? Center(child: Text("No slots available for this date.", style: GoogleFonts.poppins()))
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                            itemCount: _availableSlots.length,
                            itemBuilder: (context, index) {
                              final slotMap = _availableSlots[index] as Map<String, dynamic>;
                              final slot = AvailableSlot.fromJson(slotMap);
                              // e.g. slot.displayTime = "10:00"
                              final time = slot.displayTime.isNotEmpty ? slot.displayTime : DateFormat("HH:mm").format(slot.startTime);
                              final isSelected = _selectedTime == time;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTime = time;
                                  _selectedSlotTime = slot.startTime;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0XFFFF0B01) : Colors.white,
                                  border: Border.all(color: isSelected ? const Color(0XFFFF0B01) : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  time,
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTime != null ? _reschedule : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFFFF0B01),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Confirm Reschedule",
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
