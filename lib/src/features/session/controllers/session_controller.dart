import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SessionController(repository);
});

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._repository)
      : super(const SessionState(isLoading: true)) {
    refreshSession();
  }

  final AuthRepository _repository;

  Future<void> refreshSession() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.fetchProfile();
      state = SessionState(isLoading: false, user: profile, error: null);
    } on SessionMissingException {
      state = const SessionState(isLoading: false, user: null, error: null);
    } catch (error) {
      state = SessionState(
        isLoading: false,
        user: null,
        error: error.toString(),
      );
    }
  }

  void setAuthenticated(UserProfile profile) {
    state = SessionState(isLoading: false, user: profile, error: null);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
      state = const SessionState(isLoading: false, user: null, error: null);
    } catch (error) {
      state = SessionState(
        isLoading: false,
        user: null,
        error: error.toString(),
      );
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

class SessionState {
  const SessionState({
    required this.isLoading,
    this.user,
    this.error,
  });

  final bool isLoading;
  final UserProfile? user;
  final String? error;

  bool get isAuthenticated => user != null;

  SessionState copyWith({
    bool? isLoading,
    UserProfile? user,
    bool clearUser = false,
    Object? error = _sentinel,
  }) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : user ?? this.user,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
