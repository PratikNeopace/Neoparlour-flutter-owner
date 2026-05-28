class FeedbackModel {
  final int? id;
  final int? appointmentId;
  final int? customerId;
  final int? staffId;
  final String comment;
  final int rating;
  final String? createdAt;
  final bool? approved;

  FeedbackModel({
    this.id,
    this.appointmentId,
    this.customerId,
    this.staffId,
    required this.comment,
    required this.rating,
    this.createdAt,
    this.approved,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      appointmentId: json['appointmentId'],
      customerId: json['customerId'],
      staffId: json['staffId'],
      comment: json['comment'] ?? '',
      rating: json['rating'] ?? 0,
      createdAt: json['createdAt'],
      approved: json['approved'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'customerId': customerId,
      'staffId': staffId,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt,
      'approved': approved,
    };
  }
}
