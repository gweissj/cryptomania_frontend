import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/wallet.dart';
import '../../../domain/repositories/wallet_repository.dart';
import '../../../utils/error_handler.dart';

final walletControllerProvider =
    StateNotifierProvider<WalletController, WalletState>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletController(repository);
});

class WalletController extends StateNotifier<WalletState> {
  WalletController(this._repository) : super(const WalletState(isLoading: true)) {
    load();
  }

  final WalletRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _repository.fetchSummary();
      final transactions = await _repository.fetchTransactions();
      state = state.copyWith(
        isLoading: false,
        summary: summary,
        transactions: transactions,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: AppErrorHandler.readableMessage(error),
      );
    }
  }

  Future<void> refresh() async {
    await load();
  }

  Future<void> deposit(double amount) async {
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final summary = await _repository.deposit(amount);
      final transactions = await _repository.fetchTransactions();
      state = state.copyWith(
        isProcessing: false,
        summary: summary,
        transactions: transactions,
      );
    } catch (error) {
      state = state.copyWith(
        isProcessing: false,
        error: AppErrorHandler.readableMessage(error),
      );
    }
  }
}

class WalletState {
  const WalletState({
    this.isLoading = false,
    this.isProcessing = false,
    this.summary,
    this.transactions = const [],
    this.error,
  });

  final bool isLoading;
  final bool isProcessing;
  final WalletSummaryData? summary;
  final List<WalletTransaction> transactions;
  final String? error;

  bool get hasContent => summary != null;

  WalletState copyWith({
    bool? isLoading,
    bool? isProcessing,
    WalletSummaryData? summary,
    List<WalletTransaction>? transactions,
    Object? error = _sentinel,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      summary: summary ?? this.summary,
      transactions: transactions ?? this.transactions,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
