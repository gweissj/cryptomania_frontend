class ProfileUpdateData {
  const ProfileUpdateData({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;

  bool get hasUpdates =>
      firstName != null ||
      lastName != null ||
      email != null ||
      password != null;
}
