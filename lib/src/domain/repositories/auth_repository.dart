import '../entities/user_profile.dart';
import '../usecases/registration_data.dart';
import '../usecases/profile_update_data.dart';

abstract class AuthRepository {
  Future<UserProfile> login({required String email, required String password});

  Future<UserProfile> register(RegistrationData data);

  Future<UserProfile> fetchProfile({bool forceRefresh = false});

  Future<void> logout();

  Future<UserProfile> updateProfile(ProfileUpdateData data);
}
