import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../error/app_exception.dart';
import '../error/failure.dart';
import 'api_interceptor.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    required AuthInterceptor authInterceptor,
    required LoggingInterceptor loggingInterceptor,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )
      ..interceptors.add(authInterceptor)
      ..interceptors.add(loggingInterceptor);
  }

  late final Dio _dio;

  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) decoder,
  }) =>
      _safeCall(() => _dio.get(path, queryParameters: queryParameters), decoder);

  Future<Either<Failure, T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) decoder,
  }) =>
      _safeCall(
        () => _dio.post(path, data: data, queryParameters: queryParameters),
        decoder,
      );

  Future<Either<Failure, T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) decoder,
  }) =>
      _safeCall(() => _dio.put(path, data: data), decoder);

  Future<Either<Failure, T>> patch<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) decoder,
  }) =>
      _safeCall(() => _dio.patch(path, data: data), decoder);

  Future<Either<Failure, T>> delete<T>(
    String path, {
    required T Function(dynamic) decoder,
  }) =>
      _safeCall(() => _dio.delete(path), decoder);

  Future<Either<Failure, T>> _safeCall<T>(
    Future<Response> Function() call,
    T Function(dynamic) decoder,
  ) async {
    try {
      final response = await call();
      return Right(decoder(response.data));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } on AppException catch (e) {
      return Left(Failure.unknown(e.message));
    } catch (e) {
      return Left(Failure.unknown(e.toString()));
    }
  }

  Failure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure.network('Request timed out. Please try again.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) return const Failure.unauthorized();
        if (code == 404) return const Failure.notFound();
        final message = _extractErrorMessage(e.response?.data);
        return Failure.network(message, statusCode: code);
      case DioExceptionType.connectionError:
        return const Failure.network('No internet connection.');
      default:
        return Failure.unknown(e.message ?? 'Unknown network error.');
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'Request failed.';
    }
    return 'Request failed.';
  }
}
