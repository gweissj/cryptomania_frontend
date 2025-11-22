import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/dashboard_models.dart';
import '../../../domain/repositories/dashboard_repository.dart';

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return HomeController(repository);
});

class HomeController extends StateNotifier<HomeState> {
  HomeController(this._repository) : super(const HomeState(isLoading: true)) {
    refresh(forceShowLoading: true);
    _startPeriodicRefresh();
  }

  final DashboardRepository _repository;
  Timer? _timer;

  Future<void> refresh({bool forceShowLoading = false}) async {
    if (state.isLoading && !forceShowLoading) {
      return;
    }
    state = switch ((state.dashboard, forceShowLoading)) {
      (null, _) => state.copyWith(isLoading: true, isRefreshing: false, error: null),
      (_, true) => state.copyWith(isLoading: true, isRefreshing: false, error: null),
      _ => state.copyWith(isRefreshing: true, error: null),
    };

    try {
      final dashboard = await _repository.fetchDashboard();
      state = HomeState(
        isLoading: false,
        isRefreshing: false,
        dashboard: dashboard,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: error.toString(),
      );
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  void _startPeriodicRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 3), (_) {
      refresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class HomeState {
  const HomeState({
    required this.isLoading,
    this.isRefreshing = false,
    this.dashboard,
    this.error,
  });

  final bool isLoading;
  final bool isRefreshing;
  final DashboardData? dashboard;
  final String? error;

  bool get hasContent => dashboard != null;

  HomeState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    DashboardData? dashboard,
    Object? error = _sentinel,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      dashboard: dashboard ?? this.dashboard,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
