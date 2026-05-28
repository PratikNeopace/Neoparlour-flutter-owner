import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/providers/analytics_provider.dart';
import 'package:neo_parlour_owner/providers/staff_provider.dart';
import 'package:provider/provider.dart';

class StaffRevenueDialog extends StatelessWidget {
  const StaffRevenueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<AnalyticsProvider>(
                  builder: (context, provider, child) => Text(
                    provider.isRevenueMetric ? "Staff Revenue" : "Staff Appointment Details",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black87),
                ),
              ],
            ),
            const Divider(height: 30),

            // Dialog Content
            Flexible(
              child: Consumer2<StaffProvider, AnalyticsProvider>(
                builder: (context, staffProvider, analyticsProvider, child) {
                  if (staffProvider.isLoading && staffProvider.staffMembers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
                    );
                  }

                  if (staffProvider.staffMembers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("No staff found"),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: staffProvider.staffMembers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0XFFF0F0F0)),
                    itemBuilder: (context, index) {
                      final staff = staffProvider.staffMembers[index];
                      final count = analyticsProvider.staffRevenueMap[staff.id] ?? 0.0;
                      final bool isLoadingThis = analyticsProvider.isStaffRevenueLoading && !analyticsProvider.staffRevenueMap.containsKey(staff.id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            // Staff Image/Initial
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: const Color(0XFFF9F9F9),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ClipOval(
                                child: staff.imageBase64 != null && staff.imageBase64!.isNotEmpty
                                    ? Image.memory(base64Decode(staff.imageBase64!), fit: BoxFit.cover)
                                    : Center(
                                        child: Text(
                                          staff.name.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0XFFFF0B01)),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Staff Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    staff.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    staff.role,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0XFF8B8989),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Stats Circle
                            Column(
                              children: [
                                Container(
                                  height: 36,
                                  width: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0XFFF9F9F9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0XFF909090).withOpacity(0.3), width: 1),
                                  ),
                                  child: isLoadingThis
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0XFFFF0B01)),
                                        )
                                      : Text(
                                          analyticsProvider.isRevenueMetric
                                              ? "₹${count.toStringAsFixed(0)}"
                                              : count.toInt().toString(),
                                          style: GoogleFonts.inter(
                                            fontSize: analyticsProvider.isRevenueMetric ? 10 : 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  analyticsProvider.isRevenueMetric ? "Revenue" : "Apps",
                                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
