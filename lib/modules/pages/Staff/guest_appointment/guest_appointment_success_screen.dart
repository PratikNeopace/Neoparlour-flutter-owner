import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/modules/pages/Staff/staff_home_screen.dart';

class GuestAppointmentSuccessScreen extends StatelessWidget {
  const GuestAppointmentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final scale = sw / 375.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100 * scale,
                width: 100 * scale,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBFADE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              SizedBox(height: 24 * scale),
              Text(
                "Booking Confirmed!",
                style: GoogleFonts.poppins(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10 * scale),
              Text(
                "The walk-in appointment has been successfully created and scheduled.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14 * scale,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 50 * scale),
              SizedBox(
                width: double.infinity,
                height: 50 * scale,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeStaffScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFFFF0B01),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "BACK TO HOME",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.bold,
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
}
