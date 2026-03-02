/// Utility class for formatting values like duration, dates, etc.
class FormatUtils {
  FormatUtils._();

  /// Formats duration from seconds to MM:SS format
  static String duration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  /// Formats a DateTime to a localized date string
  /// Uses the provided month names for localization
  static String date(DateTime date, List<String> months) {
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a number with compact notation (e.g., 1.2K, 3.5M)
  static String compactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
