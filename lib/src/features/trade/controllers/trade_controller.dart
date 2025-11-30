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
    state = state.copyWith(
      isLoading: true,
      error: null,
      quotes: const [],
      selectedSource: 'coincap',
    );
    try {
      final assets = query == null || query.isEmpty
          ? await _assetsRepository.fetchTopByMarketCap(
              vsCurrency: 'USD',
              limit: 20,
            )
          : await _assetsRepository.search(query: query, limit: 30);
      final selected = assets.isNotEmpty ? assets.first : null;
      state = state.copyWith(
        isLoading: false,
        assets: assets,
        selectedAsset: selected,
      );
      if (selected != null) {
        await _loadQuotesFor(selected.id);
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> selectAsset(MarketMover asset) async {
    state = state.copyWith(selectedAsset: asset, error: null);
    await _loadQuotesFor(asset.id);
  }

  void setAmountInput(String value) {
    state = state.copyWith(amountInput: value, error: null);
  }

  void selectSource(String source) {
    state = state.copyWith(selectedSource: source, error: null);
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
        priceSource: state.selectedSource,
      );
      _ref.read(walletControllerProvider.notifier).refresh();
      state = state.copyWith(
        isProcessing: false,
        lastTrade: result,
        amountInput: '',
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
    this.quotes = const [],
    this.selectedSource = 'coincap',
    this.quotesLoading = false,
    this.error,
    this.lastTrade,
  });

  final bool isLoading;
  final bool isProcessing;
  final List<MarketMover> assets;
  final MarketMover? selectedAsset;
  final String amountInput;
  final List<PriceQuote> quotes;
  final String selectedSource;
  final bool quotesLoading;
  final String? error;
  final TradeExecution? lastTrade;

  TradeState copyWith({
    bool? isLoading,
    bool? isProcessing,
    List<MarketMover>? assets,
    MarketMover? selectedAsset,
    String? amountInput,
    List<PriceQuote>? quotes,
    String? selectedSource,
    bool? quotesLoading,
    Object? error = _sentinel,
    TradeExecution? lastTrade,
  }) {
    return TradeState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      assets: assets ?? this.assets,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      amountInput: amountInput ?? this.amountInput,
      quotes: quotes ?? this.quotes,
      selectedSource: selectedSource ?? this.selectedSource,
      quotesLoading: quotesLoading ?? this.quotesLoading,
      error: error == _sentinel ? this.error : error as String?,
      lastTrade: lastTrade ?? this.lastTrade,
    );
  }
}

const _sentinel = Object();

extension _TradeControllerQuotes on TradeController {
  Future<void> _loadQuotesFor(String assetId) async {
    state = state.copyWith(quotesLoading: true, error: null);
    try {
      final quotes = await _assetsRepository.fetchQuotes(assetId: assetId);
      final sortedQuotes = [...quotes]
        ..sort((a, b) => a.price.compareTo(b.price));
      final cheapestSource = sortedQuotes.isNotEmpty ? sortedQuotes.first.source : 'coincap';
      state = state.copyWith(
        quotes: sortedQuotes,
        quotesLoading: false,
        selectedSource: cheapestSource,
      );
    } catch (error) {
      state = state.copyWith(
        quotesLoading: false,
        error: error.toString(),
      );
    }
  }
}
