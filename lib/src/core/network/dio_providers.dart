import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../app_config.dart';
import '../storage/auth_token_storage.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final authTokenStorageProvider = Provider<AuthTokenStorage>(
  (ref) => AuthTokenStorage(ref.watch(flutterSecureStorageProvider)),
);

final backendDioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(authTokenStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.backendBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await tokenStorage.clear();
        }
        handler.next(error);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => _dioLogger(obj),
    ),
  );
  return dio;
});

final coinGeckoDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.coinGeckoBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final key = AppConfig.coinGeckoApiKey;
        if (key.isNotEmpty) {
          options.headers['x-cg-pro-api-key'] = key;
        }
        handler.next(options);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => _dioLogger(obj),
    ),
  );

  return dio;
});

void _dioLogger(Object object) {
  // ignore: avoid_print
  print(object);
}

