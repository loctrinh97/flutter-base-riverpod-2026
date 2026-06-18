import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static String currency(
    double amount, {
    String symbol = '\$',
    int decimalDigits = 2,
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  static String date(DateTime date, {String pattern = 'MMM dd, yyyy'}) =>
      DateFormat(pattern).format(date);

  static String time(DateTime time, {bool use24Hour = false}) =>
      DateFormat(use24Hour ? 'HH:mm' : 'hh:mm a').format(time);

  static String dateTime(DateTime dt, {String pattern = 'MMM dd, yyyy hh:mm a'}) =>
      DateFormat(pattern).format(dt);

  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(dt);
  }

  static String compactNumber(num value) =>
      NumberFormat.compact().format(value);
}
