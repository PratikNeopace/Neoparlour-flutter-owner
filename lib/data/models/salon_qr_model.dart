import 'dart:convert';
import 'dart:typed_data';

class SalonQRCode {
  final String salonName;
  final String salonCode;
  final Uint8List qrCode;

  SalonQRCode({
    required this.salonName,
    required this.salonCode,
    required this.qrCode,
  });

  factory SalonQRCode.fromJson(Map<String, dynamic> json) {
    return SalonQRCode(
      salonName: json['salonName'] ?? '',
      salonCode: json['salonCode'] ?? '',
      qrCode: json['qrCode'] != null 
          ? base64Decode(json['qrCode']) 
          : Uint8List(0),
    );
  }
}
