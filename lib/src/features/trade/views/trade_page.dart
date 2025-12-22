import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/dashboard_models.dart';
import '../../../utils/error_handler.dart';
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
        AppErrorHandler.showErrorSnackBar(context, next.error);
      }
      if (next.lastTrade != null && next.lastTrade != previous?.lastTrade) {
        AppErrorHandler.showErrorSnackBar(
          context,
          'Bought ${next.lastTrade!.symbol} for \$${next.lastTrade!.spent.toStringAsFixed(2)} via ${next.lastTrade!.priceSource}',
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
        title: const Text('Торги'),
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
                  'Доступно',
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
                hintText: 'Поиск..',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onSubmitted: (value) => ref
                  .read(tradeControllerProvider.notifier)
                  .loadAssets(query: value),
            ),
            if (tradeState.lastUpdated != null) ...[
              const SizedBox(height: 8),
              Text(
                'Обновлено в ${DateFormat('HH:mm').format(tradeState.lastUpdated!)}',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
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
            if (tradeState.selectedAsset != null) ...[
              const SizedBox(height: 12),
              _PriceOptions(
                quotes: tradeState.quotes,
                loading: tradeState.quotesLoading,
                selectedSource: tradeState.selectedSource,
                onSelect: (source) =>
                    ref.read(tradeControllerProvider.notifier).selectSource(source),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: false),
              decoration: InputDecoration(
                labelText: 'Сумма в USD',
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
                        : const Text('Купить'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(mainTabProvider.notifier).state = MainTab.wallet,
                  child: const Text('Пополнить счет'),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      asset.pair,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

class _PriceOptions extends StatelessWidget {
  const _PriceOptions({
    required this.quotes,
    required this.loading,
    required this.selectedSource,
    required this.onSelect,
  });

  final List<PriceQuote> quotes;
  final bool loading;
  final String selectedSource;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quotes.isEmpty) {
      return const Text('Нет данных о ценах. Попробуйте обновить.');
    }

    final cheapest = quotes.map((e) => e.price).reduce(
          (value, element) => element < value ? element : value,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Цена из двух источников — выберите выгодную',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...quotes.map((quote) {
          final isCheapest = quote.price <= cheapest;
          final isSelected = quote.source == selectedSource;
          final colorScheme = Theme.of(context).colorScheme;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : Colors.grey.withAlpha((0.3 * 255).round()),
                width: isSelected ? 1.6 : 1,
              ),
              color: isCheapest
                  ? colorScheme.primary.withAlpha((0.08 * 255).round())
                  : colorScheme.surfaceVariant.withAlpha((0.4 * 255).round()),
            ),
            child: ListTile(
              onTap: () => onSelect(quote.source),
              title: Text(
                quote.source.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: isCheapest
                  ? const Text('Дешевле сейчас')
                  : const Text('Цена выше'),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatCurrency(quote.price, 'USD'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        if (quotes.length < 2)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Сейчас доступен только один источник цены. Покупка возможна по нему.',
            ),
          ),
      ],
    );
  }
}
