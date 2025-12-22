import '../entities/dashboard_models.dart';

const List<String> _excludedKeywords = [
  'wrapped',
  'bridged',
  'staked',
  'staking',
  'binance-peg',
];

bool isStandardMarketMover(MarketMover mover) {
  final name = mover.name.toLowerCase();
  final symbol = mover.symbol.toLowerCase();
  final pair = mover.pair.toLowerCase();
  for (final keyword in _excludedKeywords) {
    if (name.contains(keyword) || symbol.contains(keyword) || pair.contains(keyword)) {
      return false;
    }
  }
  return true;
}

List<MarketMover> filterStandardMarketMovers(List<MarketMover> movers) {
  return movers.where(isStandardMarketMover).toList();
}
