import '../../domain/entities/dashboard_models.dart';
import '../../domain/repositories/market_movers_repository.dart';
import '../services/kursach_api.dart';

class MarketMoversRepositoryImpl implements MarketMoversRepository {
  MarketMoversRepositoryImpl(this._api);

  final KursachApi _api;

  @override
  Future<List<MarketMover>> fetchTopByMarketCap({
    required String vsCurrency,
    required int limit,
  }) async {
    final response = await _api.fetchMarketMovers(limit: limit);
    return response
        .map(
          (e) => MarketMover(
            id: e.id,
            name: e.name,
            symbol: e.symbol,
            pair: e.pair.isNotEmpty ? e.pair : '${e.symbol}/$vsCurrency'.toUpperCase(),
            currentPrice: e.currentPrice,
            change24hPct: e.change24hPct,
            volume24h: e.volume24h,
            imageUrl: e.imageUrl,
            sparkline: null,
          ),
        )
        .toList();
  }

  @override
  Future<List<MarketMover>> search({
    String? query,
    required int limit,
  }) async {
    final response = await _api.searchAssets(query: query, limit: limit);
    return response
        .map(
          (e) => MarketMover(
            id: e.id,
            name: e.name,
            symbol: e.symbol,
            pair: e.pair.isNotEmpty ? e.pair : '${e.symbol}/USD',
            currentPrice: e.currentPrice,
            change24hPct: e.change24hPct,
            volume24h: e.volume24h,
            imageUrl: e.imageUrl,
            sparkline: null,
          ),
        )
        .toList();
  }
}
