import '../../domain/entities/dashboard_models.dart';
import '../models/price_quote_dto.dart';

extension PriceQuoteMapper on PriceQuoteDto {
  PriceQuote toDomain() {
    return PriceQuote(
      assetId: assetId,
      symbol: symbol,
      source: source,
      price: price,
    );
  }
}
