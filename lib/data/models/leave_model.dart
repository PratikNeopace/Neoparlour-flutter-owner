class LeaveRequestModel {
  final int id;
  final int staffId;
  final String? staffName;
  final int salonId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  LeaveRequestModel({
    required this.id,
    required this.staffId,
    this.staffName,
    required this.salonId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'],
      staffId: json['staffId'],
      staffName: json['staffName'], // Note: response JSON didn't have staffName, but usually useful
      salonId: json['salonId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      approvedBy: json['approvedBy'],
    );
  }
}

class LeaveResponseWrapper {
  final List<LeaveRequestModel> content;
  final int totalElements;
  final int totalPages;

  LeaveResponseWrapper({
    required this.content,
    required this.totalElements,
    required this.totalPages,
  });

  factory LeaveResponseWrapper.fromJson(Map<String, dynamic> json) {
    return LeaveResponseWrapper(
      content: (json['content'] as List)
          .map((item) => LeaveRequestModel.fromJson(item))
          .toList(),
      totalElements: json['page']['totalElements'],
      totalPages: json['page']['totalPages'],
    );
  }
}
