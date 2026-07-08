import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:neo_parlour_owner/core/utils/error_handler.dart';
import 'package:neo_parlour_owner/core/utils/date_time_utils.dart';
import 'guest_booking_state.dart';
import 'guest_appointment_success_screen.dart';

class GuestReviewConfirmScreen extends StatefulWidget {
  final GuestBookingState bookingState;

  const GuestReviewConfirmScreen({super.key, required this.bookingState});

  @override
  State<GuestReviewConfirmScreen> createState() => _GuestReviewConfirmScreenState();
}

class _GuestReviewConfirmScreenState extends State<GuestReviewConfirmScreen> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.bookingState.customerName;
    _phoneController.text = widget.bookingState.customerNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleBookAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final selectedSlot = widget.bookingState.selectedSlot;
      if (selectedSlot == null) {
        throw Exception("Please select a date and time slot first.");
      }

      final appointmentTime = selectedSlot.startTime;
      final appointmentAtStr = DateTimeUtils.toIstIsoString(appointmentTime);

      final totalDur = widget.bookingState.totalDuration;
      final totalP = widget.bookingState.totalPrice;
      final discountW = widget.bookingState.weekdayDiscountAmount;
      final finalP = widget.bookingState.finalAmount;

      final requestData = {
        "userId": null,
        "customerId": null,
        "salonId": widget.bookingState.salonId,
        "staffId": widget.bookingState.selectedStaff?.id,
        "staffName": widget.bookingState.selectedStaff?.name,
        "customerName": _nameController.text.trim(),
        "customerNumber": _phoneController.text.trim(),
        "appointmentAt": appointmentAtStr,
        "serviceDuration": totalDur,
        "totalPrice": totalP,
        "discountAmount": 0,
        "weekdayDiscountAmount": discountW,
        "finalAmount": finalP,
        "homeCharge": 0,
        "homeService": false,
        "address": null,
        "status": "booked",
        "services": widget.bookingState.selectedServices.map((s) => {
          "serviceId": s.id.toString(),
          "serviceName": s.name,
          "price": s.price,
          "duration": s.duration
        }).toList()
      };

      final response = await _apiClient.post(
        'appointments/walk-in',
        data: requestData,
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success! Clear selections and show success screen
          widget.bookingState.selectedServices.clear();
          widget.bookingState.selectedSlot = null;
          widget.bookingState.selectedStaff = null;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GuestAppointmentSuccessScreen(),
            ),
          );
        } else {
          throw Exception("Server returned status code: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = ErrorHandler.parseError(e);
        FlushbarHelper.show(context, "Booking failed: $errorMsg");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final scale = sw / 375.0;

    final dateFormatted = DateFormat('EEEE, d MMMM').format(widget.bookingState.selectedDate);
    final slotFormatted = widget.bookingState.selectedSlot?.displayTime ?? '';
    final staffName = widget.bookingState.selectedStaff?.name ?? "Any Expert (No Preference)";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "REVIEW & CONFIRM",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18 * scale,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Save fields back to state
            widget.bookingState.customerName = _nameController.text.trim();
            widget.bookingState.customerNumber = _phoneController.text.trim();
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: const Color(0XFFD0D0D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0XFFFF0B01), size: 18),
                        SizedBox(width: 8 * scale),
                        Text(
                          "$dateFormatted at $slotFormatted",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14 * scale,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10 * scale),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: Color(0XFFFF0B01), size: 18),
                        SizedBox(width: 8 * scale),
                        Text(
                          "Expert: $staffName",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 13 * scale,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20 * scale),

              // Customer Details inputs
              Text(
                "CUSTOMER DETAILS",
                style: GoogleFonts.poppins(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10 * scale),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Customer Name",
                  labelStyle: GoogleFonts.poppins(fontSize: 13 * scale),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8 * scale)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter customer name";
                  }
                  return null;
                },
              ),

              SizedBox(height: 15 * scale),

              // Mobile Number Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  labelStyle: GoogleFonts.poppins(fontSize: 13 * scale),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8 * scale)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter mobile number";
                  }
                  if (value.trim().length != 10 || int.tryParse(value.trim()) == null) {
                    return "Please enter a valid 10-digit mobile number";
                  }
                  return null;
                },
              ),

              SizedBox(height: 24 * scale),

              // Services List
              Text(
                "SELECTED SERVICES",
                style: GoogleFonts.poppins(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8 * scale),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.bookingState.selectedServices.length,
                itemBuilder: (context, index) {
                  final service = widget.bookingState.selectedServices[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: GoogleFonts.poppins(fontSize: 13 * scale, color: Colors.black87),
                          ),
                        ),
                        Text(
                          "₹${service.price}",
                          style: GoogleFonts.poppins(fontSize: 13 * scale, fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 16 * scale),
              const Divider(),
              SizedBox(height: 8 * scale),

              // Pricing Breakdown
              Text(
                "BILL DETAILS",
                style: GoogleFonts.poppins(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10 * scale),

              // Subtotal Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Subtotal",
                    style: GoogleFonts.poppins(fontSize: 13 * scale, color: Colors.grey[600]),
                  ),
                  Text(
                    "₹${widget.bookingState.totalPrice}",
                    style: GoogleFonts.poppins(fontSize: 13 * scale, color: Colors.black),
                  ),
                ],
              ),

              // Weekday Discount Row (if applicable)
              if (widget.bookingState.weekdayDiscountAmount > 0) ...[
                SizedBox(height: 8 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Weekday Discount (${widget.bookingState.weekdayDiscountPercent.toStringAsFixed(0)}%)",
                      style: GoogleFonts.poppins(fontSize: 13 * scale, color: Colors.green),
                    ),
                    Text(
                      "- ₹${widget.bookingState.weekdayDiscountAmount}",
                      style: GoogleFonts.poppins(fontSize: 13 * scale, fontWeight: FontWeight.w600, color: Colors.green),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12 * scale),
              const Divider(),
              SizedBox(height: 8 * scale),

              // Total Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Price",
                    style: GoogleFonts.poppins(fontSize: 15 * scale, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    "₹${widget.bookingState.finalAmount}",
                    style: GoogleFonts.poppins(fontSize: 16 * scale, fontWeight: FontWeight.bold, color: const Color(0XFFFF0B01)),
                  ),
                ],
              ),

              SizedBox(height: 40 * scale),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 50 * scale,
                child: ElevatedButton(
                  onPressed: _isBooking ? null : _handleBookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFFFF0B01),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    elevation: 0,
                  ),
                  child: _isBooking
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : Text(
                          "CONFIRM BOOKING",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 30 * scale + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
