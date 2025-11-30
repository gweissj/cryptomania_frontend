import '../../domain/entities/dashboard_models.dart';
import '../../domain/entities/wallet.dart';
import '../models/dashboard_dto.dart';
import '../models/wallet_dto.dart';

extension WalletSummaryDtoMapper on WalletSummaryDto {
  WalletSummaryData toDomain() {
    return WalletSummaryData(
      currency: currency,
      cashBalance: cashBalance,
      holdingsBalance: holdingsBalance,
      totalBalance: totalBalance,
      balanceChangePct: balanceChangePct,
      assets: assets
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

extension WalletTransactionDtoMapper on WalletTransactionDto {
  WalletTransaction toDomain() {
    return WalletTransaction(
      id: id,
      type: txType,
      assetId: assetId,
      assetSymbol: assetSymbol,
      assetName: assetName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalValue: totalValue,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}

extension TradeExecutionDtoMapper on TradeExecutionDto {
  TradeExecution toDomain() {
    return TradeExecution(
      assetId: assetId,
      symbol: symbol,
      name: name,
      quantity: quantity,
      price: price,
      spent: spent,
      cashBalance: cashBalance,
      totalBalance: totalBalance,
      executedAt: DateTime.tryParse(executedAt) ?? DateTime.now(),
      priceSource: priceSource,
    );
  }
}
