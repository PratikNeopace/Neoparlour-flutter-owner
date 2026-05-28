import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/providers/analytics_provider.dart';
import 'package:neo_parlour_owner/providers/offer_provider.dart';
import 'package:provider/provider.dart';

class OfferRevenueDialog extends StatelessWidget {
  const OfferRevenueDialog({super.key});

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
                  "Offer Revenue Details",
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
              child: Consumer2<OfferProvider, AnalyticsProvider>(
                builder: (context, offerProvider, analyticsProvider, child) {
                  if (offerProvider.isLoading && offerProvider.offers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0XFFFF0B01)),
                    );
                  }

                  if (offerProvider.offers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("No offers found"),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: offerProvider.offers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0XFFF0F0F0)),
                    itemBuilder: (context, index) {
                      final offer = offerProvider.offers[index];
                      final revenue = analyticsProvider.offerRevenueMap[offer.id] ?? 0.0;
                      final bool isLoadingThis = analyticsProvider.isOfferRevenueLoading && !analyticsProvider.offerRevenueMap.containsKey(offer.id);

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
                                    offer.name.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    offer.description ?? "No description available",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0XFF8B8989),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Revenue/Usage Circle
                            Container(
                              height: 50,
                              width: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0XFF909090), width: 1),
                              ),
                              child: isLoadingThis
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0XFFFF0B01)),
                                    )
                                  : Text(
                                      revenue >= 1000 ? "${(revenue / 1000).toStringAsFixed(1)}k" : revenue.toInt().toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
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
