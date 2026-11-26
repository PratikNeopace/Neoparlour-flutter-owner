import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/data/models/maintenance_status.dart';
import 'package:neo_parlour_owner/modules/pages/splash_screen_one.dart';
import 'package:neo_parlour_owner/l10n/generated/app_localizations.dart';

class OwnerMaintenanceScreen extends StatefulWidget {
  final MaintenanceStatus status;
  const OwnerMaintenanceScreen({super.key, required this.status});

  @override
  State<OwnerMaintenanceScreen> createState() => _OwnerMaintenanceScreenState();
}

class _OwnerMaintenanceScreenState extends State<OwnerMaintenanceScreen> {
  bool _isChecking = false;

  Future<void> _refreshStatus() async {
    setState(() => _isChecking = true);
    try {
      final dio = ApiClient().dio;
      final response = await dio.get('${ApiClient.baseUrl}v1/maintenance/status');
      final status = MaintenanceStatus.fromJson(response.data);
      
      if (!status.enabled) {
        if (mounted) {
          // Restart app flow
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SplashOneScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(AppLocalizations.of(context)!.maintenanceInProgressToast),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)!.maintenanceNoInternetToast)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Block back button during maintenance
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Light Theme GIF Image based on UI reference
                Image.asset(
                  'assets/Images/MaintainanceMode/server_under_maintenance.gif',
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                     return const Icon(Icons.build_circle_outlined, size: 100, color: Colors.grey);
                  },
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  AppLocalizations.of(context)!.maintenanceTitle,
                  style: GoogleFonts.poppins(
                    color: const Color(0XFF2D2D2D),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 14),
                
                Text(
                  widget.status.message,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: Colors.blueAccent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.maintenanceSafeMessage,
                          style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (widget.status.estimatedEndTime != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0XFFFF0B01).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0XFFFF0B01).withOpacity(0.3)),
                    ),
                    child: Text(
                      "${AppLocalizations.of(context)!.maintenanceEstimatedCompletion}${widget.status.estimatedEndTime!.hour.toString().padLeft(2, '0')}:${widget.status.estimatedEndTime!.minute.toString().padLeft(2, '0')}",
                      style: GoogleFonts.poppins(color: const Color(0XFFFF0B01), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                
                const Spacer(),
                
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _refreshStatus,
                    icon: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: Text(
                      _isChecking ? AppLocalizations.of(context)!.checkingStatus : AppLocalizations.of(context)!.checkSystemStatus,
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFFFF0B01),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
