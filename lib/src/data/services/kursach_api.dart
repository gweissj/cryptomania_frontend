import 'package:dio/dio.dart';

import '../models/auth_models.dart';
import '../models/dashboard_dto.dart';
import '../models/price_quote_dto.dart';
import '../models/sell_dto.dart';
import '../models/user_dto.dart';
import '../models/wallet_dto.dart';

class KursachApi {
  KursachApi(this._dio);

  final Dio _dio;

  Future<AuthTokenResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthTokenResponseDto.fromJson(response.data ?? const {});
  }

  Future<UserResponseDto> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String birthDate,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate,
      },
    );
    return UserResponseDto.fromJson(response.data ?? const {});
  }

  Future<UserResponseDto> fetchCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('/users/me');
    return UserResponseDto.fromJson(response.data ?? const {});
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<UserResponseDto> updateProfile({
    String? email,
    String? firstName,
    String? lastName,
    String? password,
  }) async {
    final data = <String, dynamic>{};
    if (email != null) data['email'] = email;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (password != null) data['password'] = password;

    final response = await _dio.put<Map<String, dynamic>>(
      '/users/me',
      data: data,
    );
    return UserResponseDto.fromJson(response.data ?? const {});
  }

  Future<CryptoDashboardDto> fetchDashboard() async {
    final response = await _dio.get<Map<String, dynamic>>('/crypto/dashboard');
    return CryptoDashboardDto.fromJson(response.data ?? const {});
  }

  Future<List<MarketMoverDto>> fetchMarketMovers({
    int limit = 15,
    String? source,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/crypto/market-movers',
      queryParameters: {
        'limit': limit,
        if (source != null) 'source': source,
      },
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(MarketMoverDto.fromJson)
        .toList();
  }

  Future<List<MarketMoverDto>> searchAssets({
    String? query,
    int limit = 30,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/crypto/assets',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'search': query,
        'limit': limit,
      },
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(MarketMoverDto.fromJson)
        .toList();
  }

  Future<WalletSummaryDto> fetchPortfolio() async {
    final response = await _dio.get<Map<String, dynamic>>('/crypto/portfolio');
    return WalletSummaryDto.fromJson(response.data ?? const {});
  }

  Future<WalletSummaryDto> deposit({required double amount}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/crypto/deposit',
      data: {'amount': amount},
    );
    return WalletSummaryDto.fromJson(response.data ?? const {});
  }

  Future<TradeExecutionDto> buyAsset({
    required String assetId,
    required double amountUsd,
    required String priceSource,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/crypto/buy',
      data: {
        'asset_id': assetId,
        'amount_usd': amountUsd,
        'source': priceSource,
      },
    );
    return TradeExecutionDto.fromJson(response.data ?? const {});
  }

  Future<List<WalletTransactionDto>> fetchTransactions() async {
    final response = await _dio.get<List<dynamic>>('/crypto/transactions');
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(WalletTransactionDto.fromJson)
        .toList();
  }

  Future<List<PriceQuoteDto>> fetchQuotes({required String assetId}) async {
    final response = await _dio.get<List<dynamic>>('/crypto/quotes/$assetId');
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(PriceQuoteDto.fromJson)
        .toList();
  }

  Future<SellDashboardDto> fetchSellOverview() async {
    final response = await _dio.get<Map<String, dynamic>>('/crypto/sell/overview');
    return SellDashboardDto.fromJson(response.data ?? const {});
  }

  Future<SellPreviewDto> previewSell({
    required String assetId,
    double? quantity,
    double? amountUsd,
    required String priceSource,
  }) async {
    final body = <String, dynamic>{
      'asset_id': assetId,
      'source': priceSource,
    };
    if (quantity != null) {
      body['quantity'] = quantity;
    }
    if (amountUsd != null) {
      body['amount_usd'] = amountUsd;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/crypto/sell/preview',
      data: body,
    );
    return SellPreviewDto.fromJson(response.data ?? const {});
  }

  Future<SellExecutionDto> sellAsset({
    required String assetId,
    double? quantity,
    double? amountUsd,
    required String priceSource,
  }) async {
    final body = <String, dynamic>{
      'asset_id': assetId,
      'source': priceSource,
    };
    if (quantity != null) {
      body['quantity'] = quantity;
    }
    if (amountUsd != null) {
      body['amount_usd'] = amountUsd;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/crypto/sell',
      data: body,
    );
    return SellExecutionDto.fromJson(response.data ?? const {});
  }

  Future<DeviceCommandDto> dispatchDeviceCommand({
    required String action,
    Map<String, dynamic>? payload,
    String sourceDevice = 'mobile',
    String? sourceDeviceId,
    String targetDevice = 'desktop',
    String? targetDeviceId,
    int ttlSeconds = 60,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/crypto/device-commands',
      data: {
        'action': action,
        if (payload != null) 'payload': payload,
        'source_device': sourceDevice,
        if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
        'target_device': targetDevice,
        if (targetDeviceId != null) 'target_device_id': targetDeviceId,
        'ttl_seconds': ttlSeconds,
      },
    );
    return DeviceCommandDto.fromJson(response.data ?? const {});
  }

  Future<DeviceCommandPollDto> pollDeviceCommands({
    String targetDevice = 'desktop',
    String? targetDeviceId,
    int limit = 10,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/crypto/device-commands/poll',
      queryParameters: {
        'target_device': targetDevice,
        if (targetDeviceId != null) 'target_device_id': targetDeviceId,
        'limit': limit,
      },
    );
    return DeviceCommandPollDto.fromJson(response.data ?? const {});
  }

  Future<DeviceCommandDto> acknowledgeDeviceCommand({
    required int commandId,
    required String status,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/crypto/device-commands/$commandId/ack',
      data: {'status': status},
    );
    return DeviceCommandDto.fromJson(response.data ?? const {});
  }
}
