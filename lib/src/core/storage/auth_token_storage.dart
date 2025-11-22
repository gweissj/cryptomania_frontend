import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  AuthTokenStorage(this._secureStorage);

  final FlutterSecureStorage _secureStorage;
  static const _key = 'auth_token';

  Future<String?> readToken() => _secureStorage.read(key: _key);

  Future<void> saveToken(String token) => _secureStorage.write(key: _key, value: token);

  Future<void> clear() => _secureStorage.delete(key: _key);
}

