import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.network(String message, {int? statusCode}) = NetworkFailure;
  const factory Failure.unauthorized([
    @Default('Unauthorized. Please login again.') String message,
  ]) = UnauthorizedFailure;
  const factory Failure.notFound([
    @Default('Resource not found.') String message,
  ]) = NotFoundFailure;
  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.storage(String message) = StorageFailure;
  const factory Failure.unknown([
    @Default('An unexpected error occurred.') String message,
  ]) = UnknownFailure;
}
