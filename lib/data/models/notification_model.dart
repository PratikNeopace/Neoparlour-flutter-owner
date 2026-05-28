class NotificationModel {
  final int id;
  final int? appointmentId;
  final String? customerName;
  final String message;
  final String? ownerMessage;
  final String? phoneNumber;
  final int salonId;
  final String status; // matches "sent", "pending" from API

  NotificationModel({
    required this.id,
    this.appointmentId,
    this.customerName,
    required this.message,
    this.ownerMessage,
    this.phoneNumber,
    required this.salonId,
    required this.status,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      appointmentId: json['appointmentId'],
      customerName: json['customerName'],
      message: json['message'] ?? '',
      ownerMessage: json['ownerMessage'],
      phoneNumber: json['phoneNumber'],
      salonId: json['salonId'] ?? 0,
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'customerName': customerName,
      'message': message,
      'ownerMessage': ownerMessage,
      'phoneNumber': phoneNumber,
      'salonId': salonId,
      'status': status,
    };
  }
}

class PaginatedNotifications {
  final List<NotificationModel> content;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int size;
  final int number;

  PaginatedNotifications({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.size,
    required this.number,
  });

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    final List<dynamic> contentList = json['content'] ?? [];
    final pageInfo = json['page'] ?? {};
    final int totalPages = pageInfo['totalPages'] ?? json['totalPages'] ?? 0;
    final int number = pageInfo['number'] ?? json['number'] ?? 0;

    return PaginatedNotifications(
      content: contentList.map((item) => NotificationModel.fromJson(item)).toList(),
      totalElements: pageInfo['totalElements'] ?? json['totalElements'] ?? 0,
      totalPages: totalPages,
      last: totalPages == 0 ? true : number >= totalPages - 1,
      size: pageInfo['size'] ?? json['size'] ?? 10,
      number: number,
    );
  }
}
