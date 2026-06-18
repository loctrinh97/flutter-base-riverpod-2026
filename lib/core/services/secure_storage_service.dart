import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class ISecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

class SecureStorageService implements ISecureStorageService {
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  final FlutterSecureStorage _storage;

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  Future<void> saveAccessToken(String token) =>
      write(_keyAccessToken, token);

  Future<String?> getAccessToken() => read(_keyAccessToken);

  Future<void> saveRefreshToken(String token) =>
      write(_keyRefreshToken, token);

  Future<String?> getRefreshToken() => read(_keyRefreshToken);

  Future<void> clearTokens() async {
    await delete(_keyAccessToken);
    await delete(_keyRefreshToken);
  }
}
