import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/views/login_page.dart';
import '../features/auth/views/register_page.dart';
import '../features/navigation/main_navigation_page.dart';
import '../features/market/views/market_movers_page.dart';
import '../features/profile/views/profile_settings_page.dart';
import '../features/session/controllers/session_controller.dart';
import '../features/splash/splash_page.dart';

class AppRoute {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const marketMovers = '/market_movers';
  static const profileSettings = '/profile_settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionNotifier = ref.read(sessionControllerProvider.notifier);
  return GoRouter(
    initialLocation: AppRoute.splash,
    refreshListenable: _RouterRefreshStream(sessionNotifier.stream),
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      if (session.isLoading) {
        return state.matchedLocation == AppRoute.splash
            ? null
            : AppRoute.splash;
      }

      final loggingIn =
          state.matchedLocation == AppRoute.login ||
          state.matchedLocation == AppRoute.register;

      if (!session.isAuthenticated) {
        return loggingIn ? null : AppRoute.login;
      }

      if (session.isAuthenticated &&
          (state.matchedLocation == AppRoute.login ||
              state.matchedLocation == AppRoute.register ||
              state.matchedLocation == AppRoute.splash)) {
        return AppRoute.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoute.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoute.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoute.home,
        builder: (context, state) => const MainNavigationPage(),
      ),
      GoRoute(
        path: AppRoute.profileSettings,
        builder: (context, state) => const ProfileSettingsPage(),
      ),
      GoRoute(
        path: '${AppRoute.marketMovers}/:currency',
        builder: (context, state) {
          final currency = state.pathParameters['currency'] ?? 'usd';
          return MarketMoversPage(currency: currency);
        },
      ),
    ],
  );
});

class _RouterRefreshStream extends ChangeNotifier {
  _RouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
