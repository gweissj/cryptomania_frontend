class UserResponseDto {
  const UserResponseDto({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String birthDate;
  final String createdAt;
  final String updatedAt;

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      birthDate: json['birth_date'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}
