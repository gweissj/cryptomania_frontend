class CryptoDashboardDto {
  const CryptoDashboardDto({
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
  final List<MarketChartPointDto> chart;
  final List<MarketMoverDto> marketMovers;
  final List<PortfolioAssetDto> portfolio;
  final String lastUpdated;

  factory CryptoDashboardDto.fromJson(Map<String, dynamic> json) {
    final portfolioBalanceValue =
        (json['total_balance'] ?? json['portfolio_balance']) as num?;
    return CryptoDashboardDto(
      currency: json['currency'] as String? ?? 'usd',
      portfolioBalance: portfolioBalanceValue?.toDouble() ?? 0.0,
      holdingsBalance: (json['holdings_balance'] as num?)?.toDouble() ?? 0.0,
      cashBalance: (json['cash_balance'] as num?)?.toDouble() ?? 0.0,
      balanceChangePct: (json['balance_change_pct'] as num?)?.toDouble() ?? 0.0,
      chart: (json['chart'] as List<dynamic>? ?? [])
          .map((e) => MarketChartPointDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      marketMovers: (json['market_movers'] as List<dynamic>? ?? [])
          .map((e) => MarketMoverDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      portfolio: (json['portfolio'] as List<dynamic>? ?? [])
          .map((e) => PortfolioAssetDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['last_updated'] as String? ?? '',
    );
  }
}

class MarketChartPointDto {
  const MarketChartPointDto({
    required this.timestamp,
    required this.price,
  });

  final int timestamp;
  final double price;

  factory MarketChartPointDto.fromJson(Map<String, dynamic> json) {
    return MarketChartPointDto(
      timestamp: json['timestamp'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MarketMoverDto {
  const MarketMoverDto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.pair,
    required this.currentPrice,
    required this.change24hPct,
    required this.volume24h,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String symbol;
  final String pair;
  final double currentPrice;
  final double change24hPct;
  final double volume24h;
  final String? imageUrl;

  factory MarketMoverDto.fromJson(Map<String, dynamic> json) {
    return MarketMoverDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      pair: json['pair'] as String? ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      change24hPct: (json['change_24h_pct'] as num?)?.toDouble() ?? 0.0,
      volume24h: (json['volume_24h'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
    );
  }
}

class PortfolioAssetDto {
  const PortfolioAssetDto({
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

  factory PortfolioAssetDto.fromJson(Map<String, dynamic> json) {
    return PortfolioAssetDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      change24hPct: (json['change_24h_pct'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
    );
  }
}
