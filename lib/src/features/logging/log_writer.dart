/// Utility to write console logs line-by-line.
///
/// Prevents OS-level log truncation (e.g. Android logcat 4KB truncation limit)
/// and preserves visual alignment of Unicode borders.
class LogWriter {
  /// Splitting the formatted message by newlines and printing line-by-line.
  static void printLog(String message) {
    final lines = message.split('\n');
    for (var i = 0; i < lines.length; i++) {
      print(lines[i]);
    }
  }
}
