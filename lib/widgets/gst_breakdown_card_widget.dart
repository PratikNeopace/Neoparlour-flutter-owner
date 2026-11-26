import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/gst_breakdown_model.dart';

class GstBreakdownCardWidget extends StatelessWidget {
  final GstBreakdownModel breakdown;

  const GstBreakdownCardWidget({
    super.key,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    if (!breakdown.isGstEnabled) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        "INCLUSIVE GST BREAKDOWN (18%)",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: Color(0xFF27272A),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (breakdown.gstin != null && breakdown.gstin!.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0ECFF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFC4B5FD)),
                  ),
                  child: Text(
                    "GSTIN: ${breakdown.gstin!.toUpperCase()}",
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE5DEFF), height: 1, thickness: 1),
          const SizedBox(height: 12),

          // 4 Columns: Base Value, Total Tax, CGST, SGST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildStatColumn("BASE VALUE", breakdown.basePrice)),
              const SizedBox(width: 4),
              Expanded(child: _buildStatColumn("TOTAL TAX (18%)", breakdown.totalGstAmount)),
              const SizedBox(width: 4),
              Expanded(child: _buildStatColumn("CGST (9%)", breakdown.cgstAmount)),
              const SizedBox(width: 4),
              Expanded(child: _buildStatColumn("SGST (9%)", breakdown.sgstAmount)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5DEFF), height: 1, thickness: 1),
          const SizedBox(height: 12),

          // Bottom section: Invoice Amount
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 4),
                  Text(
                    "Customer invoice amount: ",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF27272A),
                    ),
                  ),
                ],
              ),
              Text(
                "₹${breakdown.grandTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF10B981),
                  decorationThickness: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description_outlined, size: 15, color: Color(0xFFA1A1AA)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  "Note: This tax distribution is for salon accounting reference only and will not be displayed to customers when booking.",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF71717A),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF71717A),
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            "₹${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
