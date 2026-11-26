class AvailableSlot {
  final DateTime startTime;
  final String displayTime;
  final bool busy;

  AvailableSlot({
    required this.startTime,
    required this.displayTime,
    this.busy = false,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      startTime: DateTime.parse(json['startTime']).toLocal(),
      displayTime: json['displayTime'] ?? '',
      busy: json['busy'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'displayTime': displayTime,
      'busy': busy,
    };
  }
}
