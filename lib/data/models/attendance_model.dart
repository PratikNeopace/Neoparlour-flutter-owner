class StaffAttendance {
  final int? id;
  final int salonId;
  final int staffId;
  final DateTime attendanceDate;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status;
  final DateTime? createdAt;

  StaffAttendance({
    this.id,
    required this.salonId,
    required this.staffId,
    required this.attendanceDate,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.createdAt,
  });

  factory StaffAttendance.fromJson(Map<String, dynamic> json) {
    return StaffAttendance(
      id: json['id'],
      salonId: json['salonId'] ?? 0,
      staffId: json['staffId'] ?? 0,
      attendanceDate: json['attendanceDate'] != null ? DateTime.parse(json['attendanceDate']) : DateTime.now(),
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn']) : null,
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut']) : null,
      status: json['status'] ?? 'ABSENT',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'salonId': salonId,
      'staffId': staffId,
      'attendanceDate': attendanceDate.toIso8601String(),
      if (checkIn != null) 'checkIn': checkIn!.toIso8601String(),
      if (checkOut != null) 'checkOut': checkOut!.toIso8601String(),
      'status': status,
    };
  }
  }


class LeaveRequestResponse {
  final int? id;
  final int salonId;
  final int staffId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  LeaveRequestResponse({
    this.id,
    required this.salonId,
    required this.staffId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestResponse(
      id: json['id'],
      salonId: json['salonId'] ?? 0,
      staffId: json['staffId'] ?? 0,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      approvedBy: json['approvedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'salonId': salonId,
      'staffId': staffId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'status': status,
    };
  }
}

class StaffAttendanceResponseWrapper {
  final List<StaffAttendance> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final int size;

  StaffAttendanceResponseWrapper({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
  });

  factory StaffAttendanceResponseWrapper.fromJson(Map<String, dynamic> json) {
    final page = json['page'] ?? {};
    return StaffAttendanceResponseWrapper(
      content: (json['content'] as List? ?? [])
          .map((item) => StaffAttendance.fromJson(item))
          .toList(),
      totalElements: page['totalElements'] ?? 0,
      totalPages: page['totalPages'] ?? 0,
      number: page['number'] ?? 0,
      size: page['size'] ?? 10,
    );
  }
}
