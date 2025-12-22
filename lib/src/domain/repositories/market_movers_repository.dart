import '../entities/dashboard_models.dart';

abstract class MarketMoversRepository {
  Future<List<MarketMover>> fetchTopByMarketCap({
    required String vsCurrency,
    required int limit,
    String? priceSource,
  });

  Future<List<MarketMover>> search({
    String? query,
    required int limit,
  });

  Future<List<PriceQuote>> fetchQuotes({
    required String assetId,
  });
}
