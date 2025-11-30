import '../entities/dashboard_models.dart';
import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<WalletSummaryData> fetchSummary();

  Future<WalletSummaryData> deposit(double amount);

  Future<TradeExecution> buyAsset({
    required String assetId,
    required double amountUsd,
    required String priceSource,
  });

  Future<List<WalletTransaction>> fetchTransactions();
}
