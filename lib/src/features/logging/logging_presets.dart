/// Configuration for console logging in `dio_more`.
///
/// Exposes predefined immutable presets (e.g., [Logging.all], [Logging.errorsOnly],
/// and [Logging.none]) to simplify developer setup and provide autocompletion.
class Logging {
  // Private constructor to prevent direct instantiation/subclassing from outside the package.
  const Logging._({
    required this.request,
    required this.response,
    required this.error,
    required this.performance,
  });

  /// Whether HTTP requests (method, URL, headers, body metadata) should be logged.
  final bool request;

  /// Whether HTTP responses (status, timing, headers, body payload) should be logged.
  final bool response;

  /// Whether HTTP errors and exceptions should be logged.
  final bool error;

  /// Whether performance details (request duration, payload sizes) should be logged.
  final bool performance;

  /// Logging preset that logs all network events and diagnostics.
  static const all = Logging._(
    request: true,
    response: true,
    error: true,
    performance: true,
  );

  /// Logging preset that logs only failed requests, timeouts, and exceptions.
  static const errorsOnly = Logging._(
    request: false,
    response: false,
    error: true,
    performance: false,
  );

  /// Logging preset that disables all logging output.
  static const none = Logging._(
    request: false,
    response: false,
    error: false,
    performance: false,
  );
}
