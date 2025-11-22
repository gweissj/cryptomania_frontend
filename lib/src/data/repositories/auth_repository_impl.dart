import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/registration_data.dart';
import '../../domain/usecases/profile_update_data.dart';
import '../mappers/user_mapper.dart';
import '../services/kursach_api.dart';
import '../../core/storage/auth_token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._tokenStorage);

  final KursachApi _api;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokenResponse = await _api.login(email: email, password: password);
      await _tokenStorage.saveToken(tokenResponse.accessToken);
      final user = await _api.fetchCurrentUser();
      return user.toDomain();
    } catch (error) {
      await _tokenStorage.clear();
      rethrow;
    }
  }

  @override
  Future<UserProfile> register(RegistrationData data) async {
    try {
      await _api.register(
        email: data.email,
        password: data.password,
        firstName: data.firstName,
        lastName: data.lastName,
        birthDate: data.birthDate,
      );
      final tokenResponse = await _api.login(
        email: data.email,
        password: data.password,
      );
      await _tokenStorage.saveToken(tokenResponse.accessToken);
      final user = await _api.fetchCurrentUser();
      return user.toDomain();
    } catch (error) {
      await _tokenStorage.clear();
      rethrow;
    }
  }

  @override
  Future<UserProfile> fetchProfile({bool forceRefresh = false}) async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      throw const SessionMissingException();
    }
    try {
      final dto = await _api.fetchCurrentUser();
      return dto.toDomain();
    } catch (error) {
      await _tokenStorage.clear();
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      await _tokenStorage.clear();
    }
  }

  @override
  Future<UserProfile> updateProfile(ProfileUpdateData data) async {
    final dto = await _api.updateProfile(
      email: data.email,
      firstName: data.firstName,
      lastName: data.lastName,
      password: data.password,
    );
    return dto.toDomain();
  }
}

class SessionMissingException implements Exception {
  const SessionMissingException();

  @override
  String toString() => 'SessionMissingException: Сессия не найдена';
}
