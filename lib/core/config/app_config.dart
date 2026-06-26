import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._(this.env);

  final String env;

  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  static Future<void> load(String env) async {
    await dotenv.load(fileName: '.env.$env');
    _instance = AppConfig._(env);
  }

  String get baseUrl => dotenv.env['BASE_URL']!;
  String get appName => dotenv.env['APP_NAME']!;

  bool get isDev => env == 'dev';
  bool get isQa => env == 'qa';
  bool get isStg => env == 'stg';
  bool get isPrd => env == 'prd';
}
