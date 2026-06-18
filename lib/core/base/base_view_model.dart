import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../error/failure.dart';
import '../utils/logger.dart';

abstract class BaseViewModel<S> extends StateNotifier<S> {
  BaseViewModel(super.initialState) {
    _log = AppLogger(runtimeType.toString());
  }

  late final AppLogger _log;

  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeSetState(S newState) {
    if (!_disposed) state = newState;
  }

  /// Maps a [Failure] to a human-readable message.
  String mapFailure(Failure failure) => failure.when(
        network: (msg, _) => msg,
        unauthorized: (msg) => msg,
        notFound: (msg) => msg,
        validation: (msg) => msg,
        storage: (msg) => msg,
        unknown: (msg) => msg,
      );

  void logDebug(String message) => _log.d(message);
  void logInfo(String message) => _log.i(message);
  void logWarning(String message) => _log.w(message);
  void logError(String message, [dynamic error, StackTrace? stack]) =>
      _log.e(message, error, stack);
}
