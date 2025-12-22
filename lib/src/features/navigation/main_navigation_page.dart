import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/views/home_page.dart';
import '../market/views/market_movers_page.dart';
import '../sell/views/sell_page.dart';
import '../trade/views/trade_page.dart';
import '../wallet/views/wallet_page.dart';
import 'main_navigation_controller.dart';
import '../market/controllers/market_movers_controller.dart';
import '../home/controllers/home_controller.dart';

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(mainTabProvider);
    final index = MainTab.values.indexOf(tab);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HomePage(),
          TradePage(),
          MarketTabPage(),
          SellPage(),
          WalletPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) => ref.read(mainTabProvider.notifier).state = MainTab.values[value],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_calls), label: 'Торги'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Маркет'),
          BottomNavigationBarItem(icon: Icon(Icons.sell_outlined), label: 'Продажа'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Кошелек'),
        ],
      ),
    );
  }
}

class MarketTabPage extends ConsumerStatefulWidget {
  const MarketTabPage({super.key});

  @override
  ConsumerState<MarketTabPage> createState() => _MarketTabPageState();
}

class _MarketTabPageState extends ConsumerState<MarketTabPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final homeState = ref.read(homeControllerProvider);
    final currency = homeState.dashboard?.currency ?? 'USD';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketMoversControllerProvider.notifier).loadTop(currency);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final currency = homeState.dashboard?.currency ?? 'USD';
    return MarketMoversPage(currency: currency);
  }
}

class FavoritesPlaceholderPage extends StatelessWidget {
  const FavoritesPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SellPage();
  }
}
