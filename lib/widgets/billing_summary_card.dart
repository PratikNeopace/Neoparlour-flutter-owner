import 'package:flutter/material.dart';

class BillingSummaryCard extends StatelessWidget {
  final double subtotal;
  final double discountAmount;
  final double homeCharge;
  final bool includeGst;
  final String gstin;

  const BillingSummaryCard({
    Key? key,
    required this.subtotal,
    this.discountAmount = 0.0,
    this.homeCharge = 0.0,
    required this.includeGst,
    this.gstin = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double baseNet = (subtotal - discountAmount + homeCharge).clamp(0.0, double.infinity);
    final double cgst = includeGst ? baseNet * 0.09 : 0.0;
    final double sgst = includeGst ? baseNet * 0.09 : 0.0;
    final double grandTotal = includeGst ? (baseNet + cgst + sgst) : baseNet;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BILLING BREAKDOWN',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.0),
              ),
              if (includeGst)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Text(
                    'GST 18% ENABLED',
                    style: TextStyle(color: Colors.green, fontSize: 10.0, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const Divider(height: 24.0),
          _buildRow('Item Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          if (discountAmount > 0)
            _buildRow('Discount', '- ₹${discountAmount.toStringAsFixed(2)}', color: Colors.green),
          if (homeCharge > 0)
            _buildRow('Home Charge', '+ ₹${homeCharge.toStringAsFixed(2)}'),
          if (includeGst) ...[
            const Divider(),
            _buildRow('Net Taxable Amount', '₹${baseNet.toStringAsFixed(2)}', isBold: true),
            _buildRow('CGST (9%)', '₹${cgst.toStringAsFixed(2)}', isSubText: true),
            _buildRow('SGST (9%)', '₹${sgst.toStringAsFixed(2)}', isSubText: true),
            if (gstin.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('GSTIN: $gstin', style: const TextStyle(fontSize: 10.0, color: Colors.grey)),
              ),
          ],
          const Divider(height: 24.0),
          _buildRow(
            'Total Amount Payable',
            '₹${grandTotal.toStringAsFixed(2)}',
            isBold: true,
            color: Colors.red,
            fontSize: 14.0,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool isSubText = false, Color? color, double fontSize = 12.0}) {
    return Padding(
      padding: EdgeInsets.only(left: isSubText ? 12.0 : 0.0, bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}
