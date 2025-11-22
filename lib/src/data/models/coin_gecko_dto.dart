class CoinMarketDto {
  const CoinMarketDto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChange24h,
    required this.totalVolume,
    required this.sparkline,
  });

  final String id;
  final String symbol;
  final String name;
  final String? image;
  final double currentPrice;
  final double priceChange24h;
  final double totalVolume;
  final List<double> sparkline;

  factory CoinMarketDto.fromJson(Map<String, dynamic> json) {
    return CoinMarketDto(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      priceChange24h: (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      sparkline: (json['sparkline_in_7d']?['price'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

