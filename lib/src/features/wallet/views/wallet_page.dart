import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/wallet.dart';
import '../../../utils/error_handler.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/wallet_controller.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<WalletState>(walletControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        AppErrorHandler.showErrorSnackBar(context, next.error);
      }
    });

    final state = ref.watch(walletControllerProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final summary = state.summary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(walletControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: summary == null
          ? const Center(child: Text('No wallet data yet'))
          : RefreshIndicator(
        onRefresh: () => ref.read(walletControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCard(summary: summary),
            const SizedBox(height: 16),
            Text(
              'Deposit USD',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: state.isProcessing
                      ? null
                      : () async {
                    final value = double.tryParse(
                      _amountController.text.replaceAll(',', '.'),
                    ) ??
                        0;
                    if (value <= 0) {
                      AppErrorHandler.showErrorSnackBar(
                        context,
                        'Enter a valid deposit amount',
                      );
                      return;
                    }
                    await ref
                        .read(walletControllerProvider.notifier)
                        .deposit(value);
                    await ref.read(homeControllerProvider.notifier).refresh();
                    _amountController.clear();
                  },
                  child: state.isProcessing
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Deposit'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Holdings',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...summary.assets.map((asset) {
              final value = formatCurrency(asset.value, summary.currency);
              final qty = asset.quantity.toStringAsFixed(6);
              final change = formatSignedPercent(asset.change24hPct);
              final changePositive = asset.change24hPct >= 0;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      asset.symbol.isNotEmpty ? asset.symbol[0] : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(asset.name),
                  subtitle: Text('$qty ${asset.symbol}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        change,
                        style: TextStyle(
                          color: changePositive
                              ? const Color(0xFF24C16B)
                              : const Color(0xFFDA5B5B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Text(
              'Transactions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (state.transactions.isEmpty)
              const Text('No transactions yet', style: TextStyle(color: Colors.grey))
            else
              ...state.transactions.map((tx) {
                final type = tx.type.toUpperCase();
                final isDeposit = type == 'DEPOSIT';
                final isSell = type == 'SELL';
                final iconData = isDeposit
                    ? Icons.add
                    : isSell
                    ? Icons.trending_down
                    : Icons.shopping_bag;
                final bgColor = isDeposit
                    ? Colors.blue.shade100
                    : isSell
                    ? Colors.orange.shade100
                    : Colors.green.shade100;
                final label = isDeposit
                    ? 'Deposit'
                    : isSell
                    ? 'Sell ${tx.assetSymbol ?? tx.assetName ?? ''}'
                    : 'Buy ${tx.assetSymbol ?? tx.assetName ?? ''}';
                final cashIn = isDeposit || isSell;
                final amountText =
                    '${cashIn ? '+' : '-'}${formatCurrency(tx.totalValue, summary.currency)}';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: bgColor,
                    child: Icon(
                      iconData,
                      color: Colors.blueGrey,
                    ),
                  ),
                  title: Text(label),
                  subtitle: Text(
                    '${tx.createdAt.toLocal()}'.split('.').first,
                  ),
                  trailing: Text(
                    amountText,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final WalletSummaryData summary;

  @override
  Widget build(BuildContext context) {
    final balance = formatCurrency(summary.totalBalance, summary.currency);
    final cash = formatCurrency(summary.cashBalance, summary.currency);
    final holdings = formatCurrency(summary.holdingsBalance, summary.currency);
    final change = formatSignedPercent(summary.balanceChangePct);
    final changePositive = summary.balanceChangePct >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio Balance',
                style: TextStyle(color: Colors.grey),
              ),
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
          const SizedBox(height: 8),
          Text(
            balance,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Holdings', style: TextStyle(color: Colors.grey)),
                  Text(
                    holdings,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Cash', style: TextStyle(color: Colors.grey)),
                  Text(
                    cash,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
