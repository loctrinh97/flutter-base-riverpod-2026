import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoadingService {
  static Future<void> show([String? message]) =>
      EasyLoading.show(status: message);

  static Future<void> showSuccess(String message) =>
      EasyLoading.showSuccess(message);

  static Future<void> showError(String message) =>
      EasyLoading.showError(message);

  static Future<void> showInfo(String message) =>
      EasyLoading.showInfo(message);

  static Future<void> dismiss() => EasyLoading.dismiss();
}
