import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:neo_parlour_owner/data/models/available_slot.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/widgets/reason_dialog.dart';
import 'package:neo_parlour_owner/core/constants/reasons.dart';
import 'package:neo_parlour_owner/providers/appointment_provider.dart';
import 'package:neo_parlour_owner/data/models/appointment_response.dart';
import 'package:neo_parlour_owner/providers/auth_provider.dart';
import 'guest_booking_state.dart';
import 'guest_review_confirm_screen.dart';

class GuestSelectDateTimeScreen extends StatefulWidget {
  final GuestBookingState bookingState;
  final bool isReschedule;
  final Appointment? rescheduleAppointment;

  const GuestSelectDateTimeScreen({
    super.key,
    required this.bookingState,
    this.isReschedule = false,
    this.rescheduleAppointment,
  });

  @override
  State<GuestSelectDateTimeScreen> createState() => _GuestSelectDateTimeScreenState();
}

class _GuestSelectDateTimeScreenState extends State<GuestSelectDateTimeScreen> {
  final ApiClient _apiClient = ApiClient();
  List<AvailableSlot> _slots = [];
  bool _isLoadingSlots = false;
  late DateTime _selectedDate;
  final List<DateTime> _dates = [];
  final ScrollController _dateScrollController = ScrollController(initialScrollOffset: 15 * 62.0); // approx item width is 62

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.bookingState.selectedDate;
    
    // Generate 15 past days + today + 29 future days
    final now = DateTime.now();
    for (int i = -15; i < 30; i++) {
      _dates.add(now.add(Duration(days: i)));
    }

    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _slots.clear();
    });

    try {
      final String dateStr = '${_selectedDate.toIso8601String().split('T')[0]}T00:00:00Z';
      
      final staffId = widget.bookingState.selectedStaff?.id;
      final int duration = widget.bookingState.totalDuration > 0 ? widget.bookingState.totalDuration : 30;

      dynamic response;
      if (staffId != null) {
        response = await _apiClient.get(
          'appointments/staff/$staffId/available-slots',
          queryParameters: {
            'selectedDate': dateStr,
            'durationMinutes': duration,
          },
        );
      } else {
        response = await _apiClient.get(
          'appointments/salon-slots',
          queryParameters: {'selectedDate': dateStr},
        );
      }

      if (response.data is List) {
        final List<AvailableSlot> fetchedSlots = (response.data as List)
            .map((json) => AvailableSlot.fromJson(json))
            .toList();
        setState(() {
          _slots = fetchedSlots;
          _isLoadingSlots = false;
        });
      } else {
        setState(() {
          _isLoadingSlots = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _isLoadingSlots = false;
      });
      if (mounted) {
        FlushbarHelper.show(context, ApiClient.handleDioError(e));
      }
    } catch (e) {
      setState(() {
        _isLoadingSlots = false;
      });
      if (mounted) {
        FlushbarHelper.show(context, "Error fetching slots: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final scale = sw / 375.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "SELECT DATE & TIME",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18 * scale,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: Text(
                  DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                  style: GoogleFonts.poppins(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Horizontal Date timeline
              Container(
                height: 80 * scale,
                margin: EdgeInsets.symmetric(vertical: 10 * scale),
                child: ListView.builder(
                  controller: _dateScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
                    final date = _dates[index];
                    final isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                          widget.bookingState.selectedDate = date;
                          widget.bookingState.selectedSlot = null; // reset selected slot
                        });
                        _fetchSlots();
                      },
                      child: Container(
                        width: 60 * scale,
                        margin: EdgeInsets.only(right: 12 * scale),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0XFFFF0B01) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(
                            color: isSelected ? const Color(0XFFFF0B01) : const Color(0XFFD0D0D0),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEE').format(date).toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey[600],
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              DateFormat('d').format(date),
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              Padding(
                padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 8 * scale),
                child: Text(
                  "AVAILABLE SLOTS",
                  style: GoogleFonts.poppins(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Slots Grid
              Expanded(
                child: _isLoadingSlots
                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0XFFFF0B01))))
                    : _slots.isEmpty
                        ? Center(
                            child: Text(
                              "No slots available for this date",
                              style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.grey),
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 100 * scale),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12 * scale,
                              mainAxisSpacing: 12 * scale,
                              childAspectRatio: 2.2,
                            ),
                            itemCount: _slots.length,
                            itemBuilder: (context, index) {
                              final slot = _slots[index];
                              final isSelected = widget.bookingState.selectedSlot?.displayTime == slot.displayTime &&
                                  DateFormat('yyyy-MM-dd').format(widget.bookingState.selectedSlot!.startTime) ==
                                      DateFormat('yyyy-MM-dd').format(slot.startTime);
                              final isBusy = slot.busy;

                              return GestureDetector(
                                onTap: isBusy ? null : () {
                                  setState(() {
                                    widget.bookingState.selectedSlot = slot;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isBusy ? Colors.grey.shade200 : (isSelected ? const Color(0XFFFF0B01) : Colors.white),
                                    borderRadius: BorderRadius.circular(8 * scale),
                                    border: Border.all(
                                      color: isSelected && !isBusy ? const Color(0XFFFF0B01) : (isBusy ? Colors.transparent : const Color(0XFF909090)),
                                      width: isSelected && !isBusy ? 2 : 1,
                                    ),
                                    boxShadow: isBusy ? null : const [
                                      BoxShadow(
                                        color: Color(0x08000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    slot.displayTime,
                                    style: GoogleFonts.poppins(
                                      color: isBusy ? Colors.grey.shade400 : (isSelected ? Colors.white : Colors.black),
                                      fontWeight: isSelected && !isBusy ? FontWeight.w600 : FontWeight.w500,
                                      fontSize: 13 * scale,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),

          // Bottom Bar
          Positioned(
            bottom: 20 * scale,
            left: 16 * scale,
            right: 16 * scale,
            child: SafeArea(
              child: Container(
                height: 68 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1F22),
                borderRadius: BorderRadius.circular(34 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.isReschedule ? "Reschedule Appointment" : (widget.bookingState.selectedSlot == null
                              ? "Select slot"
                              : "Slot selected"),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!widget.isReschedule)
                          Text(
                            widget.bookingState.selectedSlot == null
                                ? "${widget.bookingState.selectedServices.length} service${widget.bookingState.selectedServices.length > 1 ? 's' : ''}"
                                : "${widget.bookingState.selectedServices.length} service${widget.bookingState.selectedServices.length > 1 ? 's' : ''} • ${widget.bookingState.selectedSlot!.displayTime}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11 * scale,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.bookingState.selectedSlot == null
                        ? () {
                            FlushbarHelper.show(context, "Please select an available time slot");
                          }
                        : () {
                            if (widget.isReschedule) {
                              final provider = Provider.of<AppointmentProvider>(context, listen: false);
                              _showRescheduleReasonDialog(context, provider);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GuestReviewConfirmScreen(bookingState: widget.bookingState),
                                ),
                              ).then((_) => setState(() {}));
                            }
                          },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 10 * scale),
                      decoration: BoxDecoration(
                        color: widget.bookingState.selectedSlot == null ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                        borderRadius: BorderRadius.circular(20 * scale),
                      ),
                      child: Text(
                        widget.isReschedule ? "Confirm Reschedule" : "Next",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 12 * scale,
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
      ),
    );
  }

  Future<void> _showRescheduleReasonDialog(BuildContext context, AppointmentProvider provider) async {
    if (widget.rescheduleAppointment == null || widget.bookingState.selectedSlot == null) return;
    
    final String? reason = await showDialog<String>(
      context: context,
      builder: (context) => ReasonDialog(
        title: "Reschedule Reason",
        hintText: "Enter reason for rescheduling...",
        predefinedReasons: Reasons.rescheduleReasons,
        confirmText: "RESCHEDULE",
      ),
    );

    if (reason != null && reason.isNotEmpty && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      try {
        final newDateTime = DateTime(
          widget.bookingState.selectedDate.year,
          widget.bookingState.selectedDate.month,
          widget.bookingState.selectedDate.day,
          widget.bookingState.selectedSlot!.startTime.hour,
          widget.bookingState.selectedSlot!.startTime.minute,
        );

        await provider.rescheduleAppointment(
          appointmentId: widget.rescheduleAppointment!.id,
          newDateTime: newDateTime,
          reason: reason,
          salonId: int.tryParse(authProvider.user?.tenantName ?? '') ?? 0,
        );
        if (mounted) {
          Navigator.pop(context, true); // Pop the select date time screen and pass true to signal success
        }
      } catch (e) {
        if (mounted) {
          FlushbarHelper.show(context, "Error: $e");
        }
      }
    }
  }
}
