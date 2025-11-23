class PriceQuoteDto {
  const PriceQuoteDto({
    required this.assetId,
    required this.symbol,
    required this.source,
    required this.price,
  });

  final String assetId;
  final String symbol;
  final String source;
  final double price;

  factory PriceQuoteDto.fromJson(Map<String, dynamic> json) {
    return PriceQuoteDto(
      assetId: json['asset_id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      source: json['source'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
