class ErrorUtils {
  static String toUserMessage(
    Object error, {
    String fallback = 'Ocurrió un error. Intenta nuevamente.',
  }) {
    final raw = error.toString().trim();
    if (raw.isEmpty) return fallback;

    final prefixes = [
      'Exception: ',
      'HiveError: ',
      'FormatException: ',
      'SocketException: ',
      'TimeoutException: ',
    ];

    var message = raw;
    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message.substring(prefix.length);
      }
    }

    message = message.trim();
    return message.isEmpty ? fallback : message;
  }
}
