import 'package:flutter/material.dart';
import '../../app.dart';
import '../../features/auth/view/login_screen.dart';
import 'app_routes.dart';

/// Generates routes for [MaterialApp.onGenerateRoute].
/// Add a new [case] here whenever a new screen is added.
class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashScreen());
      case AppRoutes.login:
        return _page(const LoginScreen());
      // ── Add new routes below ──────────────────────────────────────────────
      // case AppRoutes.home:
      //   return _page(const HomeScreen());
      default:
        return _page(_NotFoundScreen(route: settings.name ?? 'unknown'));
    }
  }

  static MaterialPageRoute<T> _page<T>(Widget child) =>
      MaterialPageRoute<T>(builder: (_) => child);
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.route});
  final String route;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: Text('Route not found: $route')),
      );
}
