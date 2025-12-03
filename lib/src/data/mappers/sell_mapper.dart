import '../../domain/entities/sell.dart';
import '../models/sell_dto.dart';

extension SellDashboardDtoMapper on SellDashboardDto {
  SellDashboard toDomain() {
    return SellDashboard(
      currency: currency,
      cashBalance: cashBalance,
      holdings: holdings.map((e) => e.toDomain()).toList(),
      totalSellableValue: totalSellableValue,
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
    );
  }
}

extension SellableAssetDtoMapper on SellableAssetDto {
  SellableAsset toDomain() {
    return SellableAsset(
      id: id,
      name: name,
      symbol: symbol,
      quantity: quantity,
      avgBuyPrice: avgBuyPrice,
      currentPrice: currentPrice,
      currentValue: currentValue,
      unrealizedPnl: unrealizedPnl,
      unrealizedPnlPct: unrealizedPnlPct,
    );
  }
}

extension SellPreviewDtoMapper on SellPreviewDto {
  SellPreview toDomain() {
    return SellPreview(
      assetId: assetId,
      symbol: symbol,
      name: name,
      priceSource: priceSource,
      unitPrice: unitPrice,
      quantity: quantity,
      proceeds: proceeds,
      availableQuantity: availableQuantity,
      isFullPosition: isFullPosition,
    );
  }
}

extension SellExecutionDtoMapper on SellExecutionDto {
  SellExecution toDomain() {
    return SellExecution(
      assetId: assetId,
      symbol: symbol,
      name: name,
      quantity: quantity,
      price: price,
      received: received,
      cashBalance: cashBalance,
      totalBalance: totalBalance,
      executedAt: DateTime.tryParse(executedAt) ?? DateTime.now(),
      priceSource: priceSource,
      realizedPnl: realizedPnl,
    );
  }
}

extension DeviceCommandDtoMapper on DeviceCommandDto {
  DeviceCommand toDomain() {
    return DeviceCommand(
      id: id,
      action: action,
      payload: payload,
      sourceDevice: sourceDevice,
      sourceDeviceId: sourceDeviceId,
      targetDevice: targetDevice,
      targetDeviceId: targetDeviceId,
      status: status,
      expiresAt: expiresAt == null ? null : DateTime.tryParse(expiresAt!),
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}

extension DeviceCommandPollDtoMapper on DeviceCommandPollDto {
  DeviceCommandPoll toDomain() {
    return DeviceCommandPoll(
      commands: commands.map((e) => e.toDomain()).toList(),
      polledAt: DateTime.tryParse(polledAt) ?? DateTime.now(),
    );
  }
}
