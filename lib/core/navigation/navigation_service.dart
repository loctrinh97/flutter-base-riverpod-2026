import 'package:flutter/material.dart';

/// Global navigator key — passed to [MaterialApp.navigatorKey].
/// Allows navigation and overlay calls without a [BuildContext].
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

abstract interface class INavigationService {
  Future<T?> push<T>(String route, {Object? arguments});
  Future<T?> pushReplacement<T>(String route, {Object? arguments});
  Future<T?> pushAndClearStack<T>(String route, {Object? arguments});
  void pop<T>([T? result]);
  void popUntil(String route);
  Future<T?> showDialog<T>(Widget dialog);
  Future<T?> showBottomSheet<T>(Widget sheet);
  void showSnackbar(String message, {Duration duration});
  bool get canPop;
}

class NavigationService implements INavigationService {
  NavigatorState get _nav => navigatorKey.currentState!;
  BuildContext get _ctx => navigatorKey.currentContext!;

  @override
  Future<T?> push<T>(String route, {Object? arguments}) =>
      _nav.pushNamed<T>(route, arguments: arguments);

  @override
  Future<T?> pushReplacement<T>(String route, {Object? arguments}) =>
      _nav.pushReplacementNamed<T, dynamic>(route, arguments: arguments);

  @override
  Future<T?> pushAndClearStack<T>(String route, {Object? arguments}) =>
      _nav.pushNamedAndRemoveUntil<T>(route, (_) => false, arguments: arguments);

  @override
  void pop<T>([T? result]) => _nav.pop<T>(result);

  @override
  void popUntil(String route) =>
      _nav.popUntil((page) => page.settings.name == route);

  @override
  Future<T?> showDialog<T>(Widget dialog) => showAdaptiveDialog<T>(
        context: _ctx,
        builder: (_) => dialog,
      );

  @override
  Future<T?> showBottomSheet<T>(Widget sheet) => showModalBottomSheet<T>(
        context: _ctx,
        builder: (_) => sheet,
      );

  @override
  void showSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(_ctx).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }

  @override
  bool get canPop => _nav.canPop();
}
