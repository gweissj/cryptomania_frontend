class UserProfile {
  const UserProfile({
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
  final DateTime birthDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => '$firstName $lastName';
}
