class MaintenanceStatus {
  final bool enabled;
  final String message;
  final DateTime? estimatedEndTime;
  final String? updatedAt;

  MaintenanceStatus({
    required this.enabled,
    required this.message,
    this.estimatedEndTime,
    this.updatedAt,
  });

  factory MaintenanceStatus.fromJson(Map<String, dynamic> json) {
    return MaintenanceStatus(
      enabled: json['enabled'] ?? json['maintenance'] ?? false,
      message: json['message'] ?? 'NeoParlour Partner services are temporarily under maintenance for server updates.',
      estimatedEndTime: json['estimatedEndTime'] != null 
          ? DateTime.tryParse(json['estimatedEndTime']) 
          : null,
      updatedAt: json['updatedAt'],
    );
  }
}
