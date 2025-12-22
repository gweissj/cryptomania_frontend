import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/dashboard_models.dart';
import '../../../domain/repositories/market_movers_repository.dart';
import '../../../utils/error_handler.dart';

final marketMoversControllerProvider =
    StateNotifierProvider.autoDispose<MarketMoversController, MarketMoversState>((ref) {
  final repository = ref.watch(marketMoversRepositoryProvider);
  return MarketMoversController(repository);
});

class MarketMoversController extends StateNotifier<MarketMoversState> {
  MarketMoversController(this._repository) : super(const MarketMoversState()) {
    _startPeriodicRefresh();
  }

  final MarketMoversRepository _repository;
  Timer? _timer;

  Future<void> loadTop(String vsCurrency, {bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (!forceRefresh && state.currency == vsCurrency && state.items.isNotEmpty) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      currency: vsCurrency,
      error: null,
    );

    try {
      final items = await _repository.fetchTopByMarketCap(
        vsCurrency: vsCurrency,
        limit: 15,
        priceSource: 'coingecko',
        forceRefresh: forceRefresh,
      );
      state = state.copyWith(
        isLoading: false,
        items: items,
        lastUpdated: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: AppErrorHandler.readableMessage(error),
      );
    }
  }

  Future<void> retry() async {
    final currency = state.currency;
    if (currency != null) {
      await loadTop(currency, forceRefresh: true);
    }
  }

  void _startPeriodicRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 3), (_) {
      if (!mounted || state.isLoading) {
        return;
      }
      final currency = state.currency;
      if (currency == null) {
        return;
      }
      loadTop(currency, forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class MarketMoversState {
  const MarketMoversState({
    this.isLoading = false,
    this.items = const [],
    this.currency,
    this.lastUpdated,
    this.error,
  });

  final bool isLoading;
  final List<MarketMover> items;
  final String? currency;
  final DateTime? lastUpdated;
  final String? error;

  MarketMoversState copyWith({
    bool? isLoading,
    List<MarketMover>? items,
    String? currency,
    DateTime? lastUpdated,
    Object? error = _sentinel,
  }) {
    return MarketMoversState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
