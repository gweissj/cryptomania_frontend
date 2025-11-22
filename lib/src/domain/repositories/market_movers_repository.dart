import '../entities/dashboard_models.dart';

abstract class MarketMoversRepository {
  Future<List<MarketMover>> fetchTopByMarketCap({
    required String vsCurrency,
    required int limit,
  });

  Future<List<MarketMover>> search({
    String? query,
    required int limit,
  });
}
