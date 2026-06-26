import '../../core/config/app_config.dart';

abstract final class AppConstants {
  static String get baseUrl => AppConfig.instance.baseUrl;

  // Storage keys
  static const keyOnboardingSeen = 'onboarding_seen';
  static const keyLanguageCode = 'language_code';
  static const keyThemeMode = 'theme_mode';
}
