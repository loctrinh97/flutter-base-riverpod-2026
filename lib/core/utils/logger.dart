import 'package:logger/logger.dart';

class AppLogger {
  AppLogger(this._tag);

  final String _tag;

  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  void d(String message) => _logger.d('[$_tag] $message');
  void i(String message) => _logger.i('[$_tag] $message');
  void w(String message) => _logger.w('[$_tag] $message');
  void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e('[$_tag] $message', error: error, stackTrace: stackTrace);
}
