import 'package:flutter/services.dart';

class IndianState {
  final String enumValue;
  final String displayName;
  final String stateCode;
  
  const IndianState({
    required this.enumValue,
    required this.displayName,
    required this.stateCode,
  });
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class GstValidator {
  static final RegExp gstinRegex = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );
  
  static const List<IndianState> indianStates = [
    IndianState(enumValue: 'JAMMU_AND_KASHMIR', displayName: 'Jammu and Kashmir', stateCode: '01'),
    IndianState(enumValue: 'HIMACHAL_PRADESH', displayName: 'Himachal Pradesh', stateCode: '02'),
    IndianState(enumValue: 'PUNJAB', displayName: 'Punjab', stateCode: '03'),
    IndianState(enumValue: 'CHANDIGARH', displayName: 'Chandigarh', stateCode: '04'),
    IndianState(enumValue: 'UTTARAKHAND', displayName: 'Uttarakhand', stateCode: '05'),
    IndianState(enumValue: 'HARYANA', displayName: 'Haryana', stateCode: '06'),
    IndianState(enumValue: 'DELHI', displayName: 'Delhi', stateCode: '07'),
    IndianState(enumValue: 'RAJASTHAN', displayName: 'Rajasthan', stateCode: '08'),
    IndianState(enumValue: 'UTTAR_PRADESH', displayName: 'Uttar Pradesh', stateCode: '09'),
    IndianState(enumValue: 'BIHAR', displayName: 'Bihar', stateCode: '10'),
    IndianState(enumValue: 'SIKKIM', displayName: 'Sikkim', stateCode: '11'),
    IndianState(enumValue: 'ARUNACHAL_PRADESH', displayName: 'Arunachal Pradesh', stateCode: '12'),
    IndianState(enumValue: 'NAGALAND', displayName: 'Nagaland', stateCode: '13'),
    IndianState(enumValue: 'MANIPUR', displayName: 'Manipur', stateCode: '14'),
    IndianState(enumValue: 'MIZORAM', displayName: 'Mizoram', stateCode: '15'),
    IndianState(enumValue: 'TRIPURA', displayName: 'Tripura', stateCode: '16'),
    IndianState(enumValue: 'MEGHALAYA', displayName: 'Meghalaya', stateCode: '17'),
    IndianState(enumValue: 'ASSAM', displayName: 'Assam', stateCode: '18'),
    IndianState(enumValue: 'WEST_BENGAL', displayName: 'West Bengal', stateCode: '19'),
    IndianState(enumValue: 'JHARKHAND', displayName: 'Jharkhand', stateCode: '20'),
    IndianState(enumValue: 'ODISHA', displayName: 'Odisha', stateCode: '21'),
    IndianState(enumValue: 'CHHATTISGARH', displayName: 'Chhattisgarh', stateCode: '22'),
    IndianState(enumValue: 'MADHYA_PRADESH', displayName: 'Madhya Pradesh', stateCode: '23'),
    IndianState(enumValue: 'GUJARAT', displayName: 'Gujarat', stateCode: '24'),
    IndianState(enumValue: 'DADRA_AND_NAGAR_HAVELI_AND_DAMAN_AND_DIU', displayName: 'Dadra & Nagar Haveli and Daman & Diu', stateCode: '26'),
    IndianState(enumValue: 'MAHARASHTRA', displayName: 'Maharashtra', stateCode: '27'),
    IndianState(enumValue: 'KARNATAKA', displayName: 'Karnataka', stateCode: '29'),
    IndianState(enumValue: 'GOA', displayName: 'Goa', stateCode: '30'),
    IndianState(enumValue: 'LAKSHADWEEP', displayName: 'Lakshadweep', stateCode: '31'),
    IndianState(enumValue: 'KERALA', displayName: 'Kerala', stateCode: '32'),
    IndianState(enumValue: 'TAMIL_NADU', displayName: 'Tamil Nadu', stateCode: '33'),
    IndianState(enumValue: 'PUDUCHERRY', displayName: 'Puducherry', stateCode: '34'),
    IndianState(enumValue: 'ANDAMAN_AND_NICOBAR_ISLANDS', displayName: 'Andaman & Nicobar Islands', stateCode: '35'),
    IndianState(enumValue: 'TELANGANA', displayName: 'Telangana', stateCode: '36'),
    IndianState(enumValue: 'ANDHRA_PRADESH', displayName: 'Andhra Pradesh', stateCode: '37'),
    IndianState(enumValue: 'LADAKH', displayName: 'Ladakh', stateCode: '38'),
  ];
  
  /// Validates format, 15-character length, and checks for state code mismatch
  static String? validateGstinAndState(String? gstin, String? selectedStateEnum, {bool isRequired = true}) {
    if (gstin == null || gstin.trim().isEmpty) {
      return isRequired ? 'Please enter 15-digit GSTIN (e.g. 27AAAAA0000A1Z5)' : null;
    }
    final cleanGstin = gstin.trim().toUpperCase();
    
    // 1. Length check
    if (cleanGstin.length != 15) {
      return 'GSTIN must be exactly 15 characters (e.g. 27AAAAA0000A1Z5)';
    }

    // 2. Format check
    if (!gstinRegex.hasMatch(cleanGstin)) {
      return 'Invalid 15-digit GSTIN format (e.g. 27AAAAA0000A1Z5)';
    }
    
    // 3. State mismatch check
    if (selectedStateEnum != null && cleanGstin.length >= 2) {
      final prefix = cleanGstin.substring(0, 2);
      final selectedStateObj = indianStates.firstWhere(
        (s) => s.enumValue == selectedStateEnum,
        orElse: () => const IndianState(enumValue: '', displayName: '', stateCode: ''),
      );
      
      if (selectedStateObj.stateCode.isNotEmpty && selectedStateObj.stateCode != prefix) {
        final derivedStateObj = indianStates.firstWhere(
          (s) => s.stateCode == prefix,
          orElse: () => IndianState(enumValue: '', displayName: 'Code $prefix', stateCode: prefix),
        );
        return "The entered GSTIN state code ($prefix - ${derivedStateObj.displayName}) does not belong to the selected state (${selectedStateObj.displayName}). If you don't have a GSTIN for ${selectedStateObj.displayName}, please turn off 'Include GST in Invoices'.";
      }
    }
    return null;
  }
}
