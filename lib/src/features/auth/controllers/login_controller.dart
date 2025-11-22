import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../common/utils/validation_utils.dart';

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginController(repository);
});

class LoginController extends StateNotifier<LoginState> {
  LoginController(this._repository) : super(const LoginState());

  final AuthRepository _repository;

  void onEmailChanged(String value) {
    state = state.copyWith(email: value, emailError: null, generalError: null);
  }

  void onPasswordChanged(String value) {
    state = state.copyWith(password: value, passwordError: null, generalError: null);
  }

  Future<void> submit() async {
    final emailError = ValidationUtils.validateEmail(state.email);
    final passwordError = ValidationUtils.validatePassword(state.password);
    if (emailError != null || passwordError != null) {
      state = state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
      );
      return;
    }

    state = state.copyWith(isLoading: true, generalError: null);
    try {
      final profile = await _repository.login(
        email: state.email.trim(),
        password: state.password,
      );
      state = state.copyWith(isLoading: false, successProfile: profile);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        generalError: _mapError(error),
      );
    }
  }

  void acknowledgeSuccess() {
    if (state.successProfile != null) {
      state = state.copyWith(successProfile: null);
    }
  }

  String _mapError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 0;
      if (statusCode == 400 || statusCode == 401) {
        return 'Неверный e-mail или пароль';
      }
      if (statusCode != 0) {
        return 'Ошибка сервера: $statusCode';
      }
    }
    return error.toString();
  }
}

class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.generalError,
    this.isLoading = false,
    this.successProfile,
  });

  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final String? generalError;
  final bool isLoading;
  final UserProfile? successProfile;

  bool get canSubmit => email.isNotEmpty && password.isNotEmpty && !isLoading;

  LoginState copyWith({
    String? email,
    String? password,
    Object? emailError = _sentinel,
    Object? passwordError = _sentinel,
    Object? generalError = _sentinel,
    bool? isLoading,
    Object? successProfile = _sentinel,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError == _sentinel ? this.emailError : emailError as String?,
      passwordError:
          passwordError == _sentinel ? this.passwordError : passwordError as String?,
      generalError:
          generalError == _sentinel ? this.generalError : generalError as String?,
      isLoading: isLoading ?? this.isLoading,
      successProfile: successProfile == _sentinel
          ? this.successProfile
          : successProfile as UserProfile?,
    );
  }
}

const _sentinel = Object();
