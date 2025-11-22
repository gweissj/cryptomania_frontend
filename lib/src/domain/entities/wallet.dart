import 'dashboard_models.dart';

class WalletSummaryData {
  const WalletSummaryData({
    required this.currency,
    required this.cashBalance,
    required this.holdingsBalance,
    required this.totalBalance,
    required this.balanceChangePct,
    required this.assets,
    required this.lastUpdated,
  });

  final String currency;
  final double cashBalance;
  final double holdingsBalance;
  final double totalBalance;
  final double balanceChangePct;
  final List<PortfolioAsset> assets;
  final DateTime lastUpdated;
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    this.assetId,
    this.assetSymbol,
    this.assetName,
    required this.quantity,
    required this.unitPrice,
    required this.totalValue,
    required this.createdAt,
  });

  final int id;
  final String type;
  final String? assetId;
  final String? assetSymbol;
  final String? assetName;
  final double quantity;
  final double unitPrice;
  final double totalValue;
  final DateTime createdAt;
}

class TradeExecution {
  const TradeExecution({
    required this.assetId,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.price,
    required this.spent,
    required this.cashBalance,
    required this.totalBalance,
    required this.executedAt,
  });

  final String assetId;
  final String symbol;
  final String name;
  final double quantity;
  final double price;
  final double spent;
  final double cashBalance;
  final double totalBalance;
  final DateTime executedAt;
}
