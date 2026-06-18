import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/secure_storage_service.dart';

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        userId: json['user_id'] as String,
      );
}

abstract interface class IAuthRepository {
  Future<Either<Failure, LoginResponse>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<bool> isAuthenticated();
}

class AuthRepository implements IAuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  })  : _api = apiClient,
        _secureStorage = secureStorage;

  final ApiClient _api;
  final SecureStorageService _secureStorage;

  @override
  Future<Either<Failure, LoginResponse>> login(
    String email,
    String password,
  ) async {
    final result = await _api.post<LoginResponse>(
      '/auth/login',
      data: {'email': email, 'password': password},
      decoder: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
    );

    return result.fold(
      Left.new,
      (response) async {
        await _secureStorage.saveAccessToken(response.accessToken);
        await _secureStorage.saveRefreshToken(response.refreshToken);
        return Right(response);
      },
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await _secureStorage.clearTokens();
    return const Right(null);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
