import '../../domain/entities/dashboard_models.dart';
import '../models/dashboard_dto.dart';

extension DashboardDtoMapper on CryptoDashboardDto {
  DashboardData toDomain() {
    return DashboardData(
      currency: currency,
      portfolioBalance: portfolioBalance,
      holdingsBalance: holdingsBalance,
      cashBalance: cashBalance,
      balanceChangePct: balanceChangePct,
      chart: chart.map((e) => ChartPoint(timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestamp), price: e.price)).toList(),
      marketMovers: marketMovers
          .map(
            (e) => MarketMover(
              id: e.id,
              name: e.name,
              symbol: e.symbol,
              pair: e.pair,
              currentPrice: e.currentPrice,
              change24hPct: e.change24hPct,
              volume24h: e.volume24h,
              imageUrl: e.imageUrl,
              sparkline: e.sparkline,
            ),
          )
          .toList(),
      portfolio: portfolio
          .map(
            (e) => PortfolioAsset(
              id: e.id,
              name: e.name,
              symbol: e.symbol,
              quantity: e.quantity,
              currentPrice: e.currentPrice,
              value: e.value,
              change24hPct: e.change24hPct,
              imageUrl: e.imageUrl,
            ),
          )
          .toList(),
      lastUpdated: DateTime.tryParse(lastUpdated) ?? DateTime.now(),
    );
  }
}
