import 'dart:convert';
import 'dart:typed_data';

class SalonQRCode {
  final String salonName;
  final String salonCode;
  final Uint8List qrCode;
  final String? qrCodeUrl;

  SalonQRCode({
    required this.salonName,
    required this.salonCode,
    required this.qrCode,
    this.qrCodeUrl,
  });

  factory SalonQRCode.fromJson(Map<String, dynamic> json) {
    final String? qrField = json['qrCode'] ?? json['qrCodeUrl'];
    final bool isUrl = qrField != null && qrField.startsWith('http');
    
    return SalonQRCode(
      salonName: json['salonName'] ?? '',
      salonCode: json['salonCode'] ?? '',
      qrCodeUrl: isUrl ? qrField : json['qrCodeUrl'],
      qrCode: qrField != null && !isUrl
          ? base64Decode(qrField) 
          : Uint8List(0),
    );
  }
}
