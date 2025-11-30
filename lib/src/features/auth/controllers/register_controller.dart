import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/registration_data.dart';
import '../../../utils/error_handler.dart';
import '../../common/utils/validation_utils.dart';

final registerControllerProvider =
    StateNotifierProvider.autoDispose<RegisterController, RegisterState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return RegisterController(repository);
    });

class RegisterController extends StateNotifier<RegisterState> {
  RegisterController(this._repository) : super(const RegisterState());

  final AuthRepository _repository;
  final _birthFormat = DateFormat('yyyy-MM-dd');

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
      password: value,
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

  void onBirthDateSelected(DateTime date) {
    state = state.copyWith(
      birthDate: date,
      birthDateError: null,
      generalError: null,
    );
  }

  Future<void> submit() async {
    final firstNameError = ValidationUtils.validateRequired(
      state.firstName,
      'Имя',
    );
    final lastNameError = ValidationUtils.validateRequired(
      state.lastName,
      'Фамилия',
    );
    final emailError = ValidationUtils.validateEmail(state.email);
    final passwordError = ValidationUtils.validatePassword(state.password);
    final repeatPasswordError = ValidationUtils.validatePasswordConfirmation(
      state.password,
      state.repeatPassword,
    );
    final birthDateError = ValidationUtils.validateAdult(state.birthDate);

    final hasErrors = [
      firstNameError,
      lastNameError,
      emailError,
      passwordError,
      repeatPasswordError,
      birthDateError,
    ].any((element) => element != null);

    if (hasErrors) {
      state = state.copyWith(
        firstNameError: firstNameError,
        lastNameError: lastNameError,
        emailError: emailError,
        passwordError: passwordError,
        repeatPasswordError: repeatPasswordError,
        birthDateError: birthDateError,
      );
      return;
    }

    state = state.copyWith(isLoading: true, generalError: null);
    try {
      final data = RegistrationData(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        email: state.email.trim(),
        password: state.password,
        birthDate: _birthFormat.format(state.birthDate!),
      );
      final profile = await _repository.register(data);
      state = state.copyWith(isLoading: false, successProfile: profile);
    } catch (error) {
      state = state.copyWith(isLoading: false, generalError: _mapError(error));
    }
  }

  void acknowledgeSuccess() {
    if (state.successProfile != null) {
      state = state.copyWith(successProfile: null);
    }
  }

  String _mapError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode ?? 0;
      if (status == 400) {
        final data = error.response?.data;
        if (data is String && data.isNotEmpty) {
          return data
              .replaceAll('"', '')
              .replaceAll('{', '')
              .replaceAll('}', '');
        }
        if (data is Map<String, dynamic>) {
          return data.values.join('\n');
        }
        return 'Проверьте корректность введённых данных';
      }
      if (status == 409) {
        return 'Пользователь с таким e-mail уже существует';
      }
      if (status == 0) {
        return 'Проблемы с подключением к сети';
      }
      return 'Ошибка сервера: $status';
    }
    return AppErrorHandler.readableMessage(error);
  }
}

class RegisterState {
  const RegisterState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.repeatPassword = '',
    this.birthDate,
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.passwordError,
    this.repeatPasswordError,
    this.birthDateError,
    this.generalError,
    this.isLoading = false,
    this.successProfile,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String repeatPassword;
  final DateTime? birthDate;
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? passwordError;
  final String? repeatPasswordError;
  final String? birthDateError;
  final String? generalError;
  final bool isLoading;
  final UserProfile? successProfile;

  bool get canSubmit =>
      [
        firstName,
        lastName,
        email,
        password,
        repeatPassword,
      ].every((element) => element.isNotEmpty) &&
      birthDate != null &&
      !isLoading;

  String get formattedBirthDate {
    if (birthDate == null) return '';
    return DateFormat('dd.MM.yyyy').format(birthDate!);
  }

  RegisterState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? repeatPassword,
    DateTime? birthDate,
    bool clearBirthDate = false,
    Object? firstNameError = _sentinel,
    Object? lastNameError = _sentinel,
    Object? emailError = _sentinel,
    Object? passwordError = _sentinel,
    Object? repeatPasswordError = _sentinel,
    Object? birthDateError = _sentinel,
    Object? generalError = _sentinel,
    bool? isLoading,
    Object? successProfile = _sentinel,
  }) {
    return RegisterState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      repeatPassword: repeatPassword ?? this.repeatPassword,
      birthDate: clearBirthDate ? null : birthDate ?? this.birthDate,
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
      birthDateError: birthDateError == _sentinel
          ? this.birthDateError
          : birthDateError as String?,
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
