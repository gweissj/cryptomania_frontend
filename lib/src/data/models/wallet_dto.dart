import 'dashboard_dto.dart';

class WalletSummaryDto {
  const WalletSummaryDto({
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
  final List<PortfolioAssetDto> assets;
  final String lastUpdated;

  factory WalletSummaryDto.fromJson(Map<String, dynamic> json) {
    return WalletSummaryDto(
      currency: json['currency'] as String? ?? 'USD',
      cashBalance: (json['cash_balance'] as num?)?.toDouble() ?? 0.0,
      holdingsBalance: (json['holdings_balance'] as num?)?.toDouble() ?? 0.0,
      totalBalance: (json['total_balance'] as num?)?.toDouble() ??
          (json['portfolio_balance'] as num?)?.toDouble() ??
          0.0,
      balanceChangePct: (json['balance_change_pct'] as num?)?.toDouble() ?? 0.0,
      assets: (json['portfolio'] as List<dynamic>? ?? [])
          .map((e) => PortfolioAssetDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['last_updated'] as String? ?? '',
    );
  }
}

class WalletTransactionDto {
  const WalletTransactionDto({
    required this.id,
    required this.txType,
    this.assetId,
    this.assetSymbol,
    this.assetName,
    required this.quantity,
    required this.unitPrice,
    required this.totalValue,
    required this.createdAt,
  });

  final int id;
  final String txType;
  final String? assetId;
  final String? assetSymbol;
  final String? assetName;
  final double quantity;
  final double unitPrice;
  final double totalValue;
  final String createdAt;

  factory WalletTransactionDto.fromJson(Map<String, dynamic> json) {
    return WalletTransactionDto(
      id: json['id'] as int? ?? 0,
      txType: json['tx_type'] as String? ?? '',
      assetId: json['asset_id'] as String?,
      assetSymbol: json['asset_symbol'] as String?,
      assetName: json['asset_name'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class TradeExecutionDto {
  const TradeExecutionDto({
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
  final String executedAt;

  factory TradeExecutionDto.fromJson(Map<String, dynamic> json) {
    return TradeExecutionDto(
      assetId: json['asset_id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      cashBalance: (json['cash_balance'] as num?)?.toDouble() ?? 0.0,
      totalBalance: (json['total_balance'] as num?)?.toDouble() ??
          (json['portfolio_balance'] as num?)?.toDouble() ??
          0.0,
      executedAt: json['executed_at'] as String? ?? '',
    );
  }
}
