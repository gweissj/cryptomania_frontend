class DashboardData {
  const DashboardData({
    required this.currency,
    required this.portfolioBalance,
    required this.holdingsBalance,
    required this.cashBalance,
    required this.balanceChangePct,
    required this.chart,
    required this.marketMovers,
    required this.portfolio,
    required this.lastUpdated,
  });

  final String currency;
  final double portfolioBalance;
  final double holdingsBalance;
  final double cashBalance;
  final double balanceChangePct;
  final List<ChartPoint> chart;
  final List<MarketMover> marketMovers;
  final List<PortfolioAsset> portfolio;
  final DateTime lastUpdated;

  DashboardData copyWith({
    List<MarketMover>? marketMovers,
    double? portfolioBalance,
    double? balanceChangePct,
    double? holdingsBalance,
    double? cashBalance,
    List<PortfolioAsset>? portfolio,
    List<ChartPoint>? chart,
    DateTime? lastUpdated,
  }) {
    return DashboardData(
      currency: currency,
      portfolioBalance: portfolioBalance ?? this.portfolioBalance,
      holdingsBalance: holdingsBalance ?? this.holdingsBalance,
      cashBalance: cashBalance ?? this.cashBalance,
      balanceChangePct: balanceChangePct ?? this.balanceChangePct,
      chart: chart ?? this.chart,
      marketMovers: marketMovers ?? this.marketMovers,
      portfolio: portfolio ?? this.portfolio,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ChartPoint {
  const ChartPoint({
    required this.timestamp,
    required this.price,
  });

  final DateTime timestamp;
  final double price;
}

class MarketMover {
  const MarketMover({
    required this.id,
    required this.name,
    required this.symbol,
    required this.pair,
    required this.currentPrice,
    required this.change24hPct,
    required this.volume24h,
    this.imageUrl,
    this.sparkline,
  });

  final String id;
  final String name;
  final String symbol;
  final String pair;
  final double currentPrice;
  final double change24hPct;
  final double volume24h;
  final String? imageUrl;
  final List<double>? sparkline;
}

class PortfolioAsset {
  const PortfolioAsset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.quantity,
    required this.currentPrice,
    required this.value,
    required this.change24hPct,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String symbol;
  final double quantity;
  final double currentPrice;
  final double value;
  final double change24hPct;
  final String? imageUrl;
}
