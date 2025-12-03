import '../entities/sell.dart';

abstract class SellRepository {
  Future<SellDashboard> fetchSellOverview();

  Future<SellPreview> previewSell({
    required String assetId,
    double? quantity,
    double? amountUsd,
    required String priceSource,
  });

  Future<SellExecution> executeSell({
    required String assetId,
    double? quantity,
    double? amountUsd,
    required String priceSource,
  });
}
