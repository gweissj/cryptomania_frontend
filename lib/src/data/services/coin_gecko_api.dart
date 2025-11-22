import 'package:dio/dio.dart';

import '../models/coin_gecko_dto.dart';

class CoinGeckoApi {
  CoinGeckoApi(this._dio);

  final Dio _dio;

  Future<List<CoinMarketDto>> getCoinsMarkets({
    required String vsCurrency,
    int perPage = 6,
    int page = 1,
    bool sparkline = true,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/coins/markets',
      queryParameters: {
        'vs_currency': vsCurrency.toLowerCase(),
        'order': 'market_cap_desc',
        'per_page': perPage,
        'page': page,
        'sparkline': sparkline,
        'price_change_percentage': '24h',
        'locale': 'ru',
      },
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(CoinMarketDto.fromJson)
        .toList();
  }
}

