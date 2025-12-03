class SellableAssetDto {
  const SellableAssetDto({
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

  factory SellableAssetDto.fromJson(Map<String, dynamic> json) {
    return SellableAssetDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      avgBuyPrice: (json['avg_buy_price'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      unrealizedPnl: (json['unrealized_pnl'] as num?)?.toDouble() ?? 0.0,
      unrealizedPnlPct: (json['unrealized_pnl_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SellDashboardDto {
  const SellDashboardDto({
    required this.currency,
    required this.cashBalance,
    required this.holdings,
    required this.totalSellableValue,
    required this.updatedAt,
  });

  final String currency;
  final double cashBalance;
  final List<SellableAssetDto> holdings;
  final double totalSellableValue;
  final String updatedAt;

  factory SellDashboardDto.fromJson(Map<String, dynamic> json) {
    final assets = (json['holdings'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(SellableAssetDto.fromJson)
        .toList();
    return SellDashboardDto(
      currency: json['currency'] as String? ?? 'USD',
      cashBalance: (json['cash_balance'] as num?)?.toDouble() ?? 0.0,
      holdings: assets,
      totalSellableValue: (json['total_sellable_value'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class SellPreviewDto {
  const SellPreviewDto({
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

  factory SellPreviewDto.fromJson(Map<String, dynamic> json) {
    return SellPreviewDto(
      assetId: json['asset_id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      priceSource: json['price_source'] as String? ?? 'coincap',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      proceeds: (json['proceeds'] as num?)?.toDouble() ?? 0.0,
      availableQuantity: (json['available_quantity'] as num?)?.toDouble() ?? 0.0,
      isFullPosition: json['is_full_position'] as bool? ?? false,
    );
  }
}

class SellExecutionDto {
  const SellExecutionDto({
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
  final String executedAt;
  final String priceSource;
  final double realizedPnl;

  factory SellExecutionDto.fromJson(Map<String, dynamic> json) {
    return SellExecutionDto(
      assetId: json['asset_id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      received: (json['received'] as num?)?.toDouble() ?? 0.0,
      cashBalance: (json['cash_balance'] as num?)?.toDouble() ?? 0.0,
      totalBalance: (json['total_balance'] as num?)?.toDouble() ?? 0.0,
      executedAt: json['executed_at'] as String? ?? '',
      priceSource: json['price_source'] as String? ?? 'coincap',
      realizedPnl: (json['realized_pnl'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DeviceCommandDto {
  const DeviceCommandDto({
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
  final String? expiresAt;
  final String createdAt;

  factory DeviceCommandDto.fromJson(Map<String, dynamic> json) {
    return DeviceCommandDto(
      id: json['id'] as int? ?? 0,
      action: json['action'] as String? ?? '',
      payload: json['payload'] as Map<String, dynamic>?,
      sourceDevice: json['source_device'] as String? ?? '',
      sourceDeviceId: json['source_device_id'] as String?,
      targetDevice: json['target_device'] as String? ?? '',
      targetDeviceId: json['target_device_id'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      expiresAt: json['expires_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class DeviceCommandPollDto {
  const DeviceCommandPollDto({
    required this.commands,
    required this.polledAt,
  });

  final List<DeviceCommandDto> commands;
  final String polledAt;

  factory DeviceCommandPollDto.fromJson(Map<String, dynamic> json) {
    final items = (json['commands'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(DeviceCommandDto.fromJson)
        .toList();
    return DeviceCommandPollDto(
      commands: items,
      polledAt: json['polled_at'] as String? ?? '',
    );
  }
}
