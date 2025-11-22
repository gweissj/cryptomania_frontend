import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/profile_update_data.dart';
import '../../common/utils/validation_utils.dart';
import '../../session/controllers/session_controller.dart';

final profileSettingsControllerProvider =
StateNotifierProvider.autoDispose<
    ProfileSettingsController,
    ProfileSettingsState
>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final session = ref.watch(sessionControllerProvider);
  return ProfileSettingsController(repository, ref, session.user);
});

class ProfileSettingsController extends StateNotifier<ProfileSettingsState> {
  ProfileSettingsController(this._repository, this._ref, UserProfile? user)
      : super(ProfileSettingsState.fromUser(user));

  final AuthRepository _repository;
  final Ref _ref;

  void onFirstNameChanged(String value) {
    state = state.copyWith(
      firstName: value,
      firstNameError: null,
      generalError: null,
    );
  }

  void onLastNameChanged(String value) {
    state = state.copyWith(
      lastName: value,
      lastNameError: null,
      generalError: null,
    );
  }

  void onEmailChanged(String value) {
    state = state.copyWith(email: value, emailError: null, generalError: null);
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(
      newPassword: value,
      passwordError: null,
      generalError: null,
    );
  }

  void onRepeatPasswordChanged(String value) {
    state = state.copyWith(
      repeatPassword: value,
      repeatPasswordError: null,
      generalError: null,
    );
  }

  Future<void> submit() async {
    final firstNameError = ValidationUtils.validateRequired(
      state.firstName,
      '���',
    );
    final lastNameError = ValidationUtils.validateRequired(
      state.lastName,
      '�������',
    );
    final emailError = ValidationUtils.validateEmail(state.email);

    String? passwordError;
    String? repeatPasswordError;
    final wantsPasswordChange =
        state.newPassword.isNotEmpty || state.repeatPassword.isNotEmpty;
    if (wantsPasswordChange) {
      passwordError = ValidationUtils.validatePassword(state.newPassword);
      repeatPasswordError = ValidationUtils.validatePasswordConfirmation(
        state.newPassword,
        state.repeatPassword,
      );
    }

    final hasErrors = [
      firstNameError,
      lastNameError,
      emailError,
      passwordError,
      repeatPasswordError,
    ].any((element) => element != null);

    if (hasErrors) {
      state = state.copyWith(
        firstNameError: firstNameError,
        lastNameError: lastNameError,
        emailError: emailError,
        passwordError: passwordError,
        repeatPasswordError: repeatPasswordError,
      );
      return;
    }

    final trimmedFirstName = state.firstName.trim();
    final trimmedLastName = state.lastName.trim();
    final trimmedEmail = state.email.trim();

    final data = ProfileUpdateData(
      firstName: trimmedFirstName != state.initialFirstName
          ? trimmedFirstName
          : null,
      lastName: trimmedLastName != state.initialLastName
          ? trimmedLastName
          : null,
      email: trimmedEmail != state.initialEmail ? trimmedEmail : null,
      password: wantsPasswordChange ? state.newPassword : null,
    );

    if (!data.hasUpdates) {
      state = state.copyWith(
        generalError: '��� ��������� ��� ����������',
        passwordError: null,
        repeatPasswordError: null,
      );
      return;
    }

    state = state.copyWith(isLoading: true, generalError: null);
    try {
      final profile = await _repository.updateProfile(data);
      if (!mounted) return;
      _ref.read(sessionControllerProvider.notifier).setAuthenticated(profile);
      state = state.copyWith(
        isLoading: false,
        successProfile: profile,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        newPassword: '',
        repeatPassword: '',
        initialFirstName: profile.firstName,
        initialLastName: profile.lastName,
        initialEmail: profile.email,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, generalError: error.toString());
    }
  }

  void acknowledgeSuccess() {
    if (state.successProfile != null) {
      state = state.copyWith(successProfile: null);
    }
  }
}

class ProfileSettingsState {
  const ProfileSettingsState({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.newPassword,
    required this.repeatPassword,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialEmail,
    this.birthDate,
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.passwordError,
    this.repeatPasswordError,
    this.generalError,
    this.isLoading = false,
    this.successProfile,
  });

  factory ProfileSettingsState.fromUser(UserProfile? user) {
    return ProfileSettingsState(
      firstName: user?.firstName ?? '',
      lastName: user?.lastName ?? '',
      email: user?.email ?? '',
      newPassword: '',
      repeatPassword: '',
      birthDate: user?.birthDate,
      initialFirstName: user?.firstName ?? '',
      initialLastName: user?.lastName ?? '',
      initialEmail: user?.email ?? '',
    );
  }

  final String firstName;
  final String lastName;
  final String email;
  final String newPassword;
  final String repeatPassword;
  final DateTime? birthDate;
  final String initialFirstName;
  final String initialLastName;
  final String initialEmail;
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? passwordError;
  final String? repeatPasswordError;
  final String? generalError;
  final bool isLoading;
  final UserProfile? successProfile;

  bool get hasChanges =>
      firstName.trim() != initialFirstName ||
          lastName.trim() != initialLastName ||
          email.trim() != initialEmail ||
          newPassword.isNotEmpty ||
          repeatPassword.isNotEmpty;

  bool get canSubmit =>
      !isLoading &&
          firstName.trim().isNotEmpty &&
          lastName.trim().isNotEmpty &&
          email.trim().isNotEmpty &&
          hasChanges;

  String get formattedBirthDate {
    if (birthDate == null) return '—';
    return DateFormat('dd.MM.yyyy').format(birthDate!);
  }

  ProfileSettingsState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? newPassword,
    String? repeatPassword,
    DateTime? birthDate,
    bool clearBirthDate = false,
    String? initialFirstName,
    String? initialLastName,
    String? initialEmail,
    Object? firstNameError = _sentinel,
    Object? lastNameError = _sentinel,
    Object? emailError = _sentinel,
    Object? passwordError = _sentinel,
    Object? repeatPasswordError = _sentinel,
    Object? generalError = _sentinel,
    bool? isLoading,
    Object? successProfile = _sentinel,
  }) {
    return ProfileSettingsState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      newPassword: newPassword ?? this.newPassword,
      repeatPassword: repeatPassword ?? this.repeatPassword,
      birthDate: clearBirthDate ? null : birthDate ?? this.birthDate,
      initialFirstName: initialFirstName ?? this.initialFirstName,
      initialLastName: initialLastName ?? this.initialLastName,
      initialEmail: initialEmail ?? this.initialEmail,
      firstNameError: firstNameError == _sentinel
          ? this.firstNameError
          : firstNameError as String?,
      lastNameError: lastNameError == _sentinel
          ? this.lastNameError
          : lastNameError as String?,
      emailError: emailError == _sentinel
          ? this.emailError
          : emailError as String?,
      passwordError: passwordError == _sentinel
          ? this.passwordError
          : passwordError as String?,
      repeatPasswordError: repeatPasswordError == _sentinel
          ? this.repeatPasswordError
          : repeatPasswordError as String?,
      generalError: generalError == _sentinel
          ? this.generalError
          : generalError as String?,
      isLoading: isLoading ?? this.isLoading,
      successProfile: successProfile == _sentinel
          ? this.successProfile
          : successProfile as UserProfile?,
    );
  }
}

const _sentinel = Object();
