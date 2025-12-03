class SellableAsset {
  const SellableAsset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.quantity,
    required this.avgBuyPrice,
    required this.currentPrice,
    required this.currentValue,
    required this.unrealizedPnl,
    required this.unrealizedPnlPct,
  });

  final String id;
  final String name;
  final String symbol;
  final double quantity;
  final double avgBuyPrice;
  final double currentPrice;
  final double currentValue;
  final double unrealizedPnl;
  final double unrealizedPnlPct;
}

class SellDashboard {
  const SellDashboard({
    required this.currency,
    required this.cashBalance,
    required this.holdings,
    required this.totalSellableValue,
    required this.updatedAt,
  });

  final String currency;
  final double cashBalance;
  final List<SellableAsset> holdings;
  final double totalSellableValue;
  final DateTime updatedAt;
}

class SellPreview {
  const SellPreview({
    required this.assetId,
    required this.symbol,
    required this.name,
    required this.priceSource,
    required this.unitPrice,
    required this.quantity,
    required this.proceeds,
    required this.availableQuantity,
    required this.isFullPosition,
  });

  final String assetId;
  final String symbol;
  final String name;
  final String priceSource;
  final double unitPrice;
  final double quantity;
  final double proceeds;
  final double availableQuantity;
  final bool isFullPosition;
}

class SellExecution {
  const SellExecution({
    required this.assetId,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.price,
    required this.received,
    required this.cashBalance,
    required this.totalBalance,
    required this.executedAt,
    required this.priceSource,
    required this.realizedPnl,
  });

  final String assetId;
  final String symbol;
  final String name;
  final double quantity;
  final double price;
  final double received;
  final double cashBalance;
  final double totalBalance;
  final DateTime executedAt;
  final String priceSource;
  final double realizedPnl;
}

class DeviceCommand {
  const DeviceCommand({
    required this.id,
    required this.action,
    this.payload,
    required this.sourceDevice,
    this.sourceDeviceId,
    required this.targetDevice,
    this.targetDeviceId,
    required this.status,
    this.expiresAt,
    required this.createdAt,
  });

  final int id;
  final String action;
  final Map<String, dynamic>? payload;
  final String sourceDevice;
  final String? sourceDeviceId;
  final String targetDevice;
  final String? targetDeviceId;
  final String status;
  final DateTime? expiresAt;
  final DateTime createdAt;
}

class DeviceCommandPoll {
  const DeviceCommandPoll({
    required this.commands,
    required this.polledAt,
  });

  final List<DeviceCommand> commands;
  final DateTime polledAt;
}
