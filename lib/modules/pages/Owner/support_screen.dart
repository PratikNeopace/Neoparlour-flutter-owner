import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'jeevan.j@neopaceinfotech.com',
      queryParameters: {
        'subject': 'Neo Parlour Support Request',
      },
    );
    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open email client. Please email jeevan.j@neopaceinfotech.com."),
            backgroundColor: Color(0XFFFF0B01),
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '9119591956',
    );
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open dialer. Please call 9119591956 directly."),
            backgroundColor: Color(0XFFFF0B01),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          "SUPPORT",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              
              // Help Icon / Header illustration placeholder
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0XFFFF0B01).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headset_mic_rounded,
                  size: 48,
                  color: Color(0XFFFF0B01),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Friendly sub-text
              Text(
                "We’re here to help you every step of the way.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0XFF2D2D2D),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Main Support Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0XFFDFDFDF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Email
                    _buildSupportItem(
                      context,
                      icon: Icons.mail_outline_rounded,
                      title: "Email Support",
                      value: "jeevan.j@neopaceinfotech.com",
                      onTap: () => _launchEmail(context),
                      isActionable: true,
                    ),
                    const Divider(height: 32, thickness: 1, color: Color(0XFFF0F0F0)),
                    
                    // Phone
                    _buildSupportItem(
                      context,
                      icon: Icons.phone_outlined,
                      title: "Phone Support",
                      value: "9119591956",
                      onTap: () => _launchPhone(context),
                      isActionable: true,
                    ),
                    const Divider(height: 32, thickness: 1, color: Color(0XFFF0F0F0)),
                    
                    // Working Hours
                    _buildSupportItem(
                      context,
                      icon: Icons.access_time_rounded,
                      title: "Working Hours",
                      value: "10 am to 7pm",
                      onTap: null,
                      isActionable: false,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              // Closing banner text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0XFFFF0B01).withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0XFFFF0B01).withValues(alpha: 0.15)),
                ),
                child: Text(
                  "We aim to provide fast, reliable, and friendly support to ensure your experience with Neo Parlour is always smooth and hassle-free.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0XFF626262),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback? onTap,
    required bool isActionable,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0XFFF9F9F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0XFFDFDFDF)),
              ),
              child: Icon(
                icon,
                color: const Color(0XFFFF0B01),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0XFF868686),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0XFF2D2D2D),
                      decoration: isActionable ? TextDecoration.underline : TextDecoration.none,
                      decorationColor: const Color(0XFFFF0B01),
                    ),
                  ),
                ],
              ),
            ),
            if (isActionable)
              const Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: Color(0XFF868686),
              ),
          ],
        ),
      ),
    );
  }
}
