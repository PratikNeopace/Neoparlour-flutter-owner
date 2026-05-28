class RevenuePointDTO {
  final String label;
  final double revenue;
  final String? startDate;

  RevenuePointDTO({
    required this.label,
    required this.revenue,
    this.startDate,
  });

  factory RevenuePointDTO.fromJson(Map<String, dynamic> json) {
    return RevenuePointDTO(
      label: json['label'] ?? '',
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      startDate: json['startDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'revenue': revenue,
      'startDate': startDate,
    };
  }
}

class DashboardResponse {
  final double revenue;
  final int booked;
  final int cancelled;
  final int completed;
  final int rescheduled;
  final int offerUsage;

  DashboardResponse({
    required this.revenue,
    required this.booked,
    required this.cancelled,
    required this.completed,
    required this.rescheduled,
    required this.offerUsage,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      booked: json['booked'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      completed: json['completed'] ?? 0,
      rescheduled: json['rescheduled'] ?? 0,
      offerUsage: json['offerUsage'] ?? 0,
    );
  }
}

class OfferUsageLimit {
  final int totalUsageLimit;
  final String offerName;
  final int usedCount;

  OfferUsageLimit({
    required this.totalUsageLimit,
    required this.offerName,
    required this.usedCount,
  });

  factory OfferUsageLimit.fromJson(Map<String, dynamic> json) {
    return OfferUsageLimit(
      totalUsageLimit: json['totalUsageLimit'] ?? 0,
      offerName: json['offerName'] ?? 'Unknown Offer',
      usedCount: json['usedCount'] ?? 0,
    );
  }
}
