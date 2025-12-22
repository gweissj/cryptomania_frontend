import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/sell.dart';
import '../../../utils/error_handler.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/sell_controller.dart';

class SellPage extends ConsumerStatefulWidget {
  const SellPage({super.key});

  @override
  ConsumerState<SellPage> createState() => _SellPageState();
}

class _SellPageState extends ConsumerState<SellPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen<SellState>(sellControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        AppErrorHandler.showErrorSnackBar(context, next.error);
      }
      if (next.commandError != null && next.commandError != previous?.commandError) {
        AppErrorHandler.showErrorSnackBar(context, next.commandError);
      }
      if (next.commandMessage != null && next.commandMessage != previous?.commandMessage) {
        AppErrorHandler.showErrorSnackBar(context, next.commandMessage);
      }
      if (next.lastSell != null && next.lastSell != previous?.lastSell) {
        AppErrorHandler.showErrorSnackBar(
          context,
          'Продано ${next.lastSell!.symbol} на \$${next.lastSell!.received.toStringAsFixed(2)} (${next.lastSell!.priceSource})',
        );
        ref.read(homeControllerProvider.notifier).refresh();
        ref.read(sellControllerProvider.notifier).clearSuccess();
      }
    });

    final state = ref.watch(sellControllerProvider);
    final selected = state.selectedAsset;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продажа валюты'),
        actions: [
          IconButton(
            onPressed: () => ref.read(sellControllerProvider.notifier).loadOverview(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(sellControllerProvider.notifier).loadOverview(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              _SellOverviewCard(state: state),
              const SizedBox(height: 12),
              _HoldingsList(
                holdings: state.holdings,
                selected: selected,
                onTap: (asset) =>
                    ref.read(sellControllerProvider.notifier).selectAsset(asset),
              ),
              const SizedBox(height: 12),
              if (selected != null) _SelectedSellAsset(asset: selected),
              const SizedBox(height: 12),
              _PriceSourcePicker(
                selected: state.priceSource,
                onSelect: (value) =>
                    ref.read(sellControllerProvider.notifier).selectSource(value),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.computer),
                label: state.isSendingCommand
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Продать через ПК'),
                onPressed: state.isSendingCommand
                    ? null
                    : () => ref
                    .read(sellControllerProvider.notifier)
                    .requestDesktopSellSession(
                  targetDeviceId: null,
                ),
              ),
              const SizedBox(height: 16),
              _SyncPanel(
                state: state,
                onSendLogin: () => ref
                    .read(sellControllerProvider.notifier)
                    .dispatchLoginCommand(targetDeviceId: null),
                onOpenDashboard: () => ref
                    .read(sellControllerProvider.notifier)
                    .dispatchOpenDesktopDashboard(
                    targetDeviceId: null),
                onRequestDesktopSell: () => ref
                    .read(sellControllerProvider.notifier)
                    .requestDesktopSellSession(
                  targetDeviceId: null,
                ),
                onSendSell: () => ref
                    .read(sellControllerProvider.notifier)
                    .dispatchSellCommand(targetDeviceId: null),
                onPoll: () => ref.read(sellControllerProvider.notifier).pollCommands(
                  targetDevice: 'desktop',
                  targetDeviceId: null,
                ),
                onAck: (id, status) =>
                    ref.read(sellControllerProvider.notifier).acknowledgeCommand(id, status),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SellOverviewCard extends StatelessWidget {
  const _SellOverviewCard({required this.state});

  final SellState state;

  @override
  Widget build(BuildContext context) {
    final currency = state.overview?.currency ?? 'USD';
    final cash = state.overview?.cashBalance ?? 0;
    final total = state.overview?.totalSellableValue ?? 0;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Продажа',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text('Свободные средства: ${formatCurrency(cash, currency)}'),
            const SizedBox(height: 4),
            Text('Текущая стоимость активов: ${formatCurrency(total, currency)}'),
            const SizedBox(height: 4),
            Text('Всего инструментов: ${state.holdings.length}'),
          ],
        ),
      ),
    );
  }
}

class _HoldingsList extends StatelessWidget {
  const _HoldingsList({
    required this.holdings,
    required this.selected,
    required this.onTap,
  });

  final List<SellableAsset> holdings;
  final SellableAsset? selected;
  final ValueChanged<SellableAsset> onTap;

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) {
      return const Text('Портфель пуст — нечего продавать.');
    }

    return Column(
      children: holdings
          .map(
            (asset) => Card(
          elevation: selected?.id == asset.id ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: selected?.id == asset.id
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: ListTile(
            onTap: () => onTap(asset),
            title: Text(asset.name),
            subtitle: Text(
              '${asset.symbol} • ${formatCurrency(asset.currentPrice, 'USD')}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${asset.quantity.toStringAsFixed(6)} шт'),
                Text(
                  formatCurrency(asset.currentValue, 'USD'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${asset.unrealizedPnlPct.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: asset.unrealizedPnl >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

class _SelectedSellAsset extends StatelessWidget {
  const _SelectedSellAsset({required this.asset});

  final SellableAsset asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            '${asset.name} (${asset.symbol})',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text('В портфеле: ${asset.quantity.toStringAsFixed(6)} шт'),
          Text('Средняя цена: ${formatCurrency(asset.avgBuyPrice, 'USD')}'),
          Text('Текущая: ${formatCurrency(asset.currentPrice, 'USD')}'),
        ],
      ),
    );
  }
}

class _PriceSourcePicker extends StatelessWidget {
  const _PriceSourcePicker({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('CoinCap'),
          selected: selected == 'coincap',
          onSelected: (_) => onSelect('coincap'),
        ),
        ChoiceChip(
          label: const Text('CoinGecko'),
          selected: selected == 'coingecko',
          onSelected: (_) => onSelect('coingecko'),
        ),
      ],
    );
  }
}

class _SyncPanel extends StatelessWidget {
  const _SyncPanel({
    required this.state,
    required this.onSendLogin,
    required this.onOpenDashboard,
    required this.onRequestDesktopSell,
    required this.onSendSell,
    required this.onPoll,
    required this.onAck,
  });

  final SellState state;
  final VoidCallback onSendLogin;
  final VoidCallback onOpenDashboard;
  final VoidCallback onRequestDesktopSell;
  final VoidCallback onSendSell;
  final VoidCallback onPoll;
  final void Function(int id, String status) onAck;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Синхронизация ПК',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Команды отправляются на подключенный ПК через сервер.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Отправить вход на ПК'),
                  onPressed: state.isSendingCommand ? null : onSendLogin,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Открыть дашборд на ПК'),
                  onPressed: state.isSendingCommand ? null : onOpenDashboard,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.computer),
                  label: const Text('Запросить продажу на ПК'),
                  onPressed: state.isSendingCommand ? null : onRequestDesktopSell,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Отправить команду продажи'),
                  onPressed: state.isSendingCommand ? null : onSendSell,
                ),
                IconButton.outlined(
                  tooltip: 'Обновить команды для ПК',
                  icon: const Icon(Icons.sync),
                  onPressed: state.isSendingCommand ? null : onPoll,
                ),
              ],
            ),
            if (state.pendingCommands.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Ожидающие команды (отладка):',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              ...state.pendingCommands.map(
                    (cmd) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${cmd.id}: ${cmd.action} (${cmd.status})'),
                  subtitle: Text(cmd.payload?.toString() ?? '{}'),
                  trailing: Wrap(
                    spacing: 6,
                    children: [
                      TextButton(
                        onPressed: () => onAck(cmd.id, 'ACKNOWLEDGED'),
                        child: const Text('готово'),
                      ),
                      TextButton(
                        onPressed: () => onAck(cmd.id, 'FAILED'),
                        child: const Text('ошибка'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
