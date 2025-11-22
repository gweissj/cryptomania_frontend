import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/dashboard_models.dart';
import '../../../domain/repositories/market_movers_repository.dart';

final marketMoversControllerProvider =
    StateNotifierProvider.autoDispose<MarketMoversController, MarketMoversState>((ref) {
  final repository = ref.watch(marketMoversRepositoryProvider);
  return MarketMoversController(repository);
});

class MarketMoversController extends StateNotifier<MarketMoversState> {
  MarketMoversController(this._repository) : super(const MarketMoversState());

  final MarketMoversRepository _repository;

  Future<void> loadTop(String vsCurrency) async {
    if (state.isLoading) return;
    if (state.currency == vsCurrency && state.items.isNotEmpty) return;

    state = state.copyWith(
      isLoading: true,
      currency: vsCurrency,
      error: null,
    );

    try {
      final items = await _repository.fetchTopByMarketCap(
        vsCurrency: vsCurrency,
        limit: 15,
      );
      state = state.copyWith(isLoading: false, items: items);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> retry() async {
    final currency = state.currency;
    if (currency != null) {
      await loadTop(currency);
    }
  }
}

class MarketMoversState {
  const MarketMoversState({
    this.isLoading = false,
    this.items = const [],
    this.currency,
    this.error,
  });

  final bool isLoading;
  final List<MarketMover> items;
  final String? currency;
  final String? error;

  MarketMoversState copyWith({
    bool? isLoading,
    List<MarketMover>? items,
    String? currency,
    Object? error = _sentinel,
  }) {
    return MarketMoversState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      currency: currency ?? this.currency,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
