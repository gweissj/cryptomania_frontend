import '../../domain/entities/dashboard_models.dart';
import '../models/coin_gecko_dto.dart';

extension CoinMarketMapper on CoinMarketDto {
  MarketMover toDomain(String vsCurrency) {
    return MarketMover(
      id: id,
      name: name,
      symbol: symbol,
      pair: '${symbol.toUpperCase()}/${vsCurrency.toUpperCase()}',
      currentPrice: currentPrice,
      change24hPct: priceChange24h,
      volume24h: totalVolume,
      imageUrl: image,
      sparkline: sparkline,
    );
  }
}

