import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/dashboard_repository_impl.dart';
import '../data/repositories/device_command_repository_impl.dart';
import '../data/repositories/market_movers_repository_impl.dart';
import '../data/repositories/sell_repository_impl.dart';
import '../data/repositories/wallet_repository_impl.dart';
import '../data/services/kursach_api.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../domain/repositories/device_command_repository.dart';
import '../domain/repositories/market_movers_repository.dart';
import '../domain/repositories/sell_repository.dart';
import '../domain/repositories/wallet_repository.dart';
import 'network/dio_providers.dart';

final kursachApiProvider = Provider<KursachApi>(
  (ref) => KursachApi(ref.watch(backendDioProvider)),
);

final marketMoversRepositoryProvider = Provider<MarketMoversRepository>(
  (ref) => MarketMoversRepositoryImpl(ref.watch(kursachApiProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(kursachApiProvider),
    ref.watch(authTokenStorageProvider),
  ),
);

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImpl(ref.watch(kursachApiProvider)),
);

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepositoryImpl(ref.watch(kursachApiProvider)),
);

final sellRepositoryProvider = Provider<SellRepository>(
  (ref) => SellRepositoryImpl(ref.watch(kursachApiProvider)),
);

final deviceCommandRepositoryProvider = Provider<DeviceCommandRepository>(
  (ref) => DeviceCommandRepositoryImpl(ref.watch(kursachApiProvider)),
);
