class InclusiveGstResult {
  final double totalPrice;
  final double baseValue;
  final double totalGst;
  final double cgst;
  final double sgstOrUtgst;
  final String secondTaxLabel;
  InclusiveGstResult({
    required this.totalPrice,
    required this.baseValue,
    required this.totalGst,
    required this.cgst,
    required this.sgstOrUtgst,
    required this.secondTaxLabel,
  });
}

class TaxUtils {
  static const Set<String> unionTerritories = {
    'CHANDIGARH',
    'LAKSHADWEEP',
    'ANDAMAN_AND_NICOBAR_ISLANDS',
    'DADRA_AND_NAGAR_HAVELI_AND_DAMAN_AND_DIU',
    'LADAKH'
  };

  /// Calculates Inclusive GST Breakdown (18%)
  static InclusiveGstResult? calculateInclusiveGst(double price, String stateEnum) {
    if (price <= 0) return null;
    final bool isUt = unionTerritories.contains(stateEnum.toUpperCase());
    final double baseValue = price / 1.18;
    final double totalGst = price - baseValue;
    final double cgst = totalGst / 2;
    final double sgstOrUtgst = totalGst - cgst;
    return InclusiveGstResult(
      totalPrice: price,
      baseValue: double.parse(baseValue.toStringAsFixed(2)),
      totalGst: double.parse(totalGst.toStringAsFixed(2)),
      cgst: double.parse(cgst.toStringAsFixed(2)),
      sgstOrUtgst: double.parse(sgstOrUtgst.toStringAsFixed(2)),
      secondTaxLabel: isUt ? 'UTGST (9%)' : 'SGST (9%)',
    );
  }

  /// Calculates Billing Summary with Exclusive GST (18%)
  static Map<String, double> calculateBillingSummary({
    required double subtotal,
    required double discount,
    required double homeCharge,
    required bool includeGst,
  }) {
    final double baseNet = (subtotal - discount + homeCharge).clamp(0.0, double.infinity);
    final double cgst = includeGst ? baseNet * 0.09 : 0.0;
    final double sgst = includeGst ? baseNet * 0.09 : 0.0;
    final double totalGst = cgst + sgst;
    final double grandTotal = includeGst ? (baseNet + totalGst) : baseNet;
    return {
      'baseNet': double.parse(baseNet.toStringAsFixed(2)),
      'cgst': double.parse(cgst.toStringAsFixed(2)),
      'sgst': double.parse(sgst.toStringAsFixed(2)),
      'totalGst': double.parse(totalGst.toStringAsFixed(2)),
      'grandTotal': double.parse(grandTotal.toStringAsFixed(2)),
    };
  }
}
