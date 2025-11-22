import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/dashboard_models.dart';
import '../../../domain/entities/wallet.dart';
import '../../../domain/repositories/market_movers_repository.dart';
import '../../../domain/repositories/wallet_repository.dart';
import '../../wallet/controllers/wallet_controller.dart';

final tradeControllerProvider =
    StateNotifierProvider.autoDispose<TradeController, TradeState>((ref) {
  final assetsRepository = ref.watch(marketMoversRepositoryProvider);
  final walletRepository = ref.watch(walletRepositoryProvider);
  return TradeController(ref, assetsRepository, walletRepository);
});

class TradeController extends StateNotifier<TradeState> {
  TradeController(this._ref, this._assetsRepository, this._walletRepository)
      : super(const TradeState(isLoading: true)) {
    loadAssets();
  }

  final Ref _ref;
  final MarketMoversRepository _assetsRepository;
  final WalletRepository _walletRepository;

  Future<void> loadAssets({String? query}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final assets = query == null || query.isEmpty
          ? await _assetsRepository.fetchTopByMarketCap(
              vsCurrency: 'USD',
              limit: 20,
            )
          : await _assetsRepository.search(query: query, limit: 30);
      state = state.copyWith(
        isLoading: false,
        assets: assets,
        selectedAsset: assets.isNotEmpty ? assets.first : null,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  void selectAsset(MarketMover asset) {
    state = state.copyWith(selectedAsset: asset, error: null);
  }

  void setAmountInput(String value) {
    state = state.copyWith(amountInput: value, error: null);
  }

  void clearSuccess() {
    if (state.lastTrade != null) {
      state = state.copyWith(lastTrade: null);
    }
  }

  Future<void> executeBuy() async {
    final asset = state.selectedAsset;
    if (asset == null) {
      state = state.copyWith(error: 'Choose an asset first');
      return;
    }

    final normalized = state.amountInput.replaceAll(',', '.');
    final amount = double.tryParse(normalized) ?? 0;
    if (amount <= 0) {
      state = state.copyWith(error: 'Enter a valid amount in USD');
      return;
    }

    state = state.copyWith(isProcessing: true, error: null);
    try {
      final result = await _walletRepository.buyAsset(
        assetId: asset.id,
        amountUsd: amount,
      );
      _ref.read(walletControllerProvider.notifier).refresh();
      state = state.copyWith(
        isProcessing: false,
        lastTrade: result,
      );
    } catch (error) {
      state = state.copyWith(isProcessing: false, error: error.toString());
    }
  }
}

class TradeState {
  const TradeState({
    this.isLoading = false,
    this.isProcessing = false,
    this.assets = const [],
    this.selectedAsset,
    this.amountInput = '',
    this.error,
    this.lastTrade,
  });

  final bool isLoading;
  final bool isProcessing;
  final List<MarketMover> assets;
  final MarketMover? selectedAsset;
  final String amountInput;
  final String? error;
  final TradeExecution? lastTrade;

  TradeState copyWith({
    bool? isLoading,
    bool? isProcessing,
    List<MarketMover>? assets,
    MarketMover? selectedAsset,
    String? amountInput,
    Object? error = _sentinel,
    TradeExecution? lastTrade,
  }) {
    return TradeState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      assets: assets ?? this.assets,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      amountInput: amountInput ?? this.amountInput,
      error: error == _sentinel ? this.error : error as String?,
      lastTrade: lastTrade ?? this.lastTrade,
    );
  }
}

const _sentinel = Object();
