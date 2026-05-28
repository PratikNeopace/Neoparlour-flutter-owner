class DateTimeUtils {
  /// Converts a [DateTime] to an ISO 8601 string with the IST (+05:30) offset.
  /// Example: 2026-04-17T11:15:47.000+05:30
  static String toIstIsoString(DateTime dateTime) {
    // IST is UTC + 5 hours 30 minutes
    const istOffset = Duration(hours: 5, minutes: 30);
    // Convert current target to UTC first, then add IST offset
    final istDateTime = dateTime.toUtc().add(istOffset);
    
    // Format to ISO 8601 and append the offset explicitly
    // Removing the 'Z' from toUtc().toIso8601String() if present
    String iso = istDateTime.toIso8601String();
    if (iso.endsWith('Z')) {
      iso = iso.substring(0, iso.length - 1);
    }
    
    return "${iso}+05:30";
  }

  /// Returns current time in IST ISO string format.
  static String nowIstIsoString() {
    return toIstIsoString(DateTime.now());
  }
}
