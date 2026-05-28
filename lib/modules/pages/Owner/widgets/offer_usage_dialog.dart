import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/providers/analytics_provider.dart';
import 'package:provider/provider.dart';

class OfferUsageDialog extends StatelessWidget {
  const OfferUsageDialog({super.key});

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
                Text(
                  "Offer Claim Details",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
              child: Consumer<AnalyticsProvider>(
                builder: (context, analyticsProvider, child) {
                  if (analyticsProvider.isLoading && analyticsProvider.offerUsageLimits.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
                    );
                  }

                  if (analyticsProvider.offerUsageLimits.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("No usage data found"),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: analyticsProvider.offerUsageLimits.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0XFFF0F0F0)),
                    itemBuilder: (context, index) {
                      final usage = analyticsProvider.offerUsageLimits[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          children: [
                            // Offer Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    usage.offerName.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Total Limit: ${usage.totalUsageLimit == 0 ? 'Unlimited' : usage.totalUsageLimit}",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0XFF8B8989),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Usage Count Circle
                            Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0XFFFF0B01), width: 1.5),
                                    color: const Color(0XFFFF0B01).withOpacity(0.05),
                                  ),
                                  child: Text(
                                    usage.usedCount.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0XFFFF0B01),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "USED",
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey,
                                  ),
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
