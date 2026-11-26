class StaffReferralStatsModel {
  final int staffId;
  final String staffName;
  final int invitesSent;
  final int downloads;
  final int registrations;
  final int bookings;
  final int totalPointsEarned;
  final double totalRewardsEarned;

  StaffReferralStatsModel({
    required this.staffId,
    required this.staffName,
    required this.invitesSent,
    required this.downloads,
    required this.registrations,
    required this.bookings,
    required this.totalPointsEarned,
    required this.totalRewardsEarned,
  });

  factory StaffReferralStatsModel.fromJson(Map<String, dynamic> json) {
    return StaffReferralStatsModel(
      staffId: json['staffId'] ?? 0,
      staffName: json['staffName'] ?? '',
      invitesSent: json['invitesSent'] ?? 0,
      downloads: json['downloads'] ?? 0,
      registrations: json['registrations'] ?? 0,
      bookings: json['bookings'] ?? 0,
      totalPointsEarned: json['totalPointsEarned'] ?? 0,
      totalRewardsEarned: (json['totalRewardsEarned'] ?? 0).toDouble(),
    );
  }
}
