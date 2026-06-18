import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_state.freezed.dart';

@freezed
class AsyncState<T> with _$AsyncState<T> {
  const factory AsyncState.idle() = _Idle;
  const factory AsyncState.loading() = _Loading;
  const factory AsyncState.success(T data) = _Success;
  const factory AsyncState.failure(String message) = _Failure;
}

extension AsyncStateX<T> on AsyncState<T> {
  bool get isLoading => maybeWhen(loading: () => true, orElse: () => false);
  bool get isSuccess => maybeWhen(success: (_) => true, orElse: () => false);
  bool get isFailure => maybeWhen(failure: (_) => true, orElse: () => false);
  bool get isIdle => maybeWhen(idle: () => true, orElse: () => false);

  T? get dataOrNull => maybeWhen(success: (d) => d, orElse: () => null);
  String? get errorOrNull => maybeWhen(failure: (m) => m, orElse: () => null);
}
