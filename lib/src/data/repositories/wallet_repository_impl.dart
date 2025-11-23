import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../mappers/wallet_mapper.dart';
import '../services/kursach_api.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._api);

  final KursachApi _api;

  @override
  Future<WalletSummaryData> fetchSummary() async {
    final dto = await _api.fetchPortfolio();
    return dto.toDomain();
  }

  @override
  Future<WalletSummaryData> deposit(double amount) async {
    final dto = await _api.deposit(amount: amount);
    return dto.toDomain();
  }

  @override
  Future<TradeExecution> buyAsset({
    required String assetId,
    required double amountUsd,
    required String priceSource,
  }) async {
    final dto = await _api.buyAsset(
      assetId: assetId,
      amountUsd: amountUsd,
      priceSource: priceSource,
    );
    return dto.toDomain();
  }

  @override
  Future<List<WalletTransaction>> fetchTransactions() async {
    final dtos = await _api.fetchTransactions();
    return dtos.map((e) => e.toDomain()).toList();
  }
}
