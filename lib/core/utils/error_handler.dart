class ErrorHandler {
  static String parseError(dynamic e) {
    final str = e.toString();
    if (str.contains('Failed host lookup') || 
        str.contains('SocketException') || 
        str.contains('Network is unreachable') || 
        str.contains('Connection refused')) {
      return "Please check your internet connection and try again.";
    }
    return str.replaceAll('Exception: ', '');
  }
}
