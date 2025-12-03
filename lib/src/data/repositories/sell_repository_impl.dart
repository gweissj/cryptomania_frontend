import '../../domain/entities/sell.dart';
import '../../domain/repositories/sell_repository.dart';
import '../mappers/sell_mapper.dart';
import '../services/kursach_api.dart';

class SellRepositoryImpl implements SellRepository {
  SellRepositoryImpl(this._api);

  final KursachApi _api;

  @override
  Future<SellDashboard> fetchSellOverview() async {
    final dto = await _api.fetchSellOverview();
    return dto.toDomain();
  }

  @override
  Future<SellPreview> previewSell({
    required String assetId,
    double? quantity,
    double? amountUsd,
    required String priceSource,
  }) async {
    final dto = await _api.previewSell(
      assetId: assetId,
      quantity: quantity,
      amountUsd: amountUsd,
      priceSource: priceSource,
    );
    return dto.toDomain();
  }

  @override
  Future<SellExecution> executeSell({
    required String assetId,
    double? quantity,
    double? amountUsd,
    required String priceSource,
  }) async {
    final dto = await _api.sellAsset(
      assetId: assetId,
      quantity: quantity,
      amountUsd: amountUsd,
      priceSource: priceSource,
    );
    return dto.toDomain();
  }
}
