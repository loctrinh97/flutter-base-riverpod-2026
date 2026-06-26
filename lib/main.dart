import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'app.dart';

const _env = String.fromEnvironment('ENV', defaultValue: 'dev');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.load(_env);
  await setupLocator();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const App());
}
