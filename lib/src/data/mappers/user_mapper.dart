import '../../domain/entities/user_profile.dart';
import '../models/user_dto.dart';

extension UserDtoToDomain on UserResponseDto {
  UserProfile toDomain() {
    return UserProfile(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      birthDate:
          DateTime.tryParse(birthDate) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      createdAt:
          DateTime.tryParse(createdAt) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(updatedAt) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
