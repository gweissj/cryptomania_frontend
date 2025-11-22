import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/dashboard_models.dart';
import '../../navigation/main_navigation_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../controllers/trade_controller.dart';

class TradePage extends ConsumerStatefulWidget {
  const TradePage({super.key});

  @override
  ConsumerState<TradePage> createState() => _TradePageState();
}

class _TradePageState extends ConsumerState<TradePage> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TradeState>(tradeControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
      if (next.lastTrade != null && next.lastTrade != previous?.lastTrade) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bought ${next.lastTrade!.symbol} for \$${next.lastTrade!.spent.toStringAsFixed(2)}',
            ),
          ),
        );
        _amountController.clear();
        ref.read(homeControllerProvider.notifier).refresh();
        ref.read(tradeControllerProvider.notifier).clearSuccess();
      }
    });

    final tradeState = ref.watch(tradeControllerProvider);
    final walletState = ref.watch(walletControllerProvider);
    final availableCash = walletState.summary?.cashBalance ?? 0.0;

    if (_amountController.text != tradeState.amountInput) {
      _amountController.text = tradeState.amountInput;
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade'),
        actions: [
          IconButton(
            onPressed: () => ref.read(tradeControllerProvider.notifier).loadAssets(
                  query: _searchController.text,
                ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(tradeControllerProvider.notifier).loadAssets(
              query: _searchController.text,
            ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  formatCurrency(availableCash, 'USD'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search assets',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onSubmitted: (value) => ref
                  .read(tradeControllerProvider.notifier)
                  .loadAssets(query: value),
            ),
            const SizedBox(height: 12),
            if (tradeState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (tradeState.assets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No assets found')),
              )
            else
              Column(
                children: tradeState.assets
                    .map(
                      (asset) => _AssetTile(
                        asset: asset,
                        selected: asset.id == tradeState.selectedAsset?.id,
                        onTap: () =>
                            ref.read(tradeControllerProvider.notifier).selectAsset(asset),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 16),
            if (tradeState.selectedAsset != null)
              _SelectedAssetCard(asset: tradeState.selectedAsset!),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: false),
              decoration: InputDecoration(
                labelText: 'Amount in USD',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (value) =>
                  ref.read(tradeControllerProvider.notifier).setAmountInput(value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: tradeState.isProcessing
                        ? null
                        : () => ref.read(tradeControllerProvider.notifier).executeBuy(),
                    child: tradeState.isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Buy now'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(mainTabProvider.notifier).state = MainTab.wallet,
                  child: const Text('Add funds'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final MarketMover asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = formatCurrency(asset.currentPrice, 'USD');
    final change = formatSignedPercent(asset.change24hPct);
    final changePositive = asset.change24hPct >= 0;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 1.2,
        ),
      ),
      elevation: selected ? 4 : 0,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(
            asset.symbol.isNotEmpty ? asset.symbol[0] : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(asset.name),
        subtitle: Text(asset.pair),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              price,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              change,
              style: TextStyle(
                color: changePositive ? const Color(0xFF24C16B) : const Color(0xFFDA5B5B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedAssetCard extends StatelessWidget {
  const _SelectedAssetCard({required this.asset});

  final MarketMover asset;

  @override
  Widget build(BuildContext context) {
    final price = formatCurrency(asset.currentPrice, 'USD');
    final change = formatSignedPercent(asset.change24hPct);
    final changePositive = asset.change24hPct >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(
                  asset.symbol.isNotEmpty ? asset.symbol[0] : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(asset.pair),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (changePositive ? Colors.green : Colors.red)
                      .withAlpha((0.12 * 255).round()),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: changePositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            price,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '24h volume: ${formatVolume(asset.volume24h)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
