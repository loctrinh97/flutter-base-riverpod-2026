import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/app_routes.dart';
import 'core/navigation/navigation_service.dart';
import 'shared/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => ProviderScope(
        child: MaterialApp(
          title: 'INNO Mobile',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
          builder: EasyLoading.init(),
        ),
      );
}

/// Placeholder splash screen — replace with your own SplashScreen widget.
/// Exported so [AppRouter] can reference it.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    locator<NavigationService>().pushAndClearStack(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}
