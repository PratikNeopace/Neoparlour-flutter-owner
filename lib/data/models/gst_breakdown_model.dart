class GstBreakdownModel {
  final double basePrice;
  final double cgstAmount;
  final double sgstAmount;
  final double totalGstAmount;
  final double grandTotal;
  final bool isGstEnabled;
  final String? gstin;

  GstBreakdownModel({
    required this.basePrice,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.totalGstAmount,
    required this.grandTotal,
    required this.isGstEnabled,
    this.gstin,
  });

  factory GstBreakdownModel.calculate({
    required double amount,
    required bool isGstEnabled,
    bool isTaxInclusive = true,
    String? gstin,
  }) {
    if (!isGstEnabled || amount <= 0) {
      return GstBreakdownModel(
        basePrice: amount,
        cgstAmount: 0.0,
        sgstAmount: 0.0,
        totalGstAmount: 0.0,
        grandTotal: amount,
        isGstEnabled: false,
        gstin: gstin,
      );
    }
    if (isTaxInclusive) {
      final double base = amount / 1.18;
      final double totalGst = amount - base;
      final double halfGst = totalGst / 2;
      return GstBreakdownModel(
        basePrice: base,
        cgstAmount: halfGst,
        sgstAmount: halfGst,
        totalGstAmount: totalGst,
        grandTotal: amount,
        isGstEnabled: true,
        gstin: gstin,
      );
    } else {
      final double cgst = amount * 0.09;
      final double sgst = amount * 0.09;
      final double totalGst = cgst + sgst;
      return GstBreakdownModel(
        basePrice: amount,
        cgstAmount: cgst,
        sgstAmount: sgst,
        totalGstAmount: totalGst,
        grandTotal: amount + totalGst,
        isGstEnabled: true,
        gstin: gstin,
      );
    }
  }
}
