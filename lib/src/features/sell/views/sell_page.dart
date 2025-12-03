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
  final _quantityController = TextEditingController();
  final _amountController = TextEditingController();
  final _targetDeviceController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _amountController.dispose();
    _targetDeviceController.dispose();
    super.dispose();
  }

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
        _quantityController.clear();
        _amountController.clear();
        ref.read(sellControllerProvider.notifier).clearSuccess();
      }
    });

    final state = ref.watch(sellControllerProvider);
    final selected = state.selectedAsset;

    if (_quantityController.text != state.quantityInput) {
      _quantityController.text = state.quantityInput;
      _quantityController.selection =
          TextSelection.fromPosition(TextPosition(offset: _quantityController.text.length));
    }
    if (_amountController.text != state.amountInput) {
      _amountController.text = state.amountInput;
      _amountController.selection =
          TextSelection.fromPosition(TextPosition(offset: _amountController.text.length));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продажа и синхронизация'),
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
              const SizedBox(height: 12),
              _InputRow(
                quantityController: _quantityController,
                amountController: _amountController,
                onQuantityChanged: (value) =>
                    ref.read(sellControllerProvider.notifier).setQuantityInput(value),
                onAmountChanged: (value) =>
                    ref.read(sellControllerProvider.notifier).setAmountInput(value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.isProcessing
                          ? null
                          : () => ref.read(sellControllerProvider.notifier).previewSell(),
                      child: state.isPreviewLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Предпросмотр'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: state.isProcessing
                          ? null
                          : () => ref.read(sellControllerProvider.notifier).executeSell(),
                      child: state.isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Продать'),
                    ),
                  ),
                ],
              ),
              if (state.preview != null) ...[
                const SizedBox(height: 12),
                _PreviewCard(preview: state.preview!),
              ],
              if (state.lastSell != null) ...[
                const SizedBox(height: 12),
                _SellResultCard(execution: state.lastSell!),
              ],
              const SizedBox(height: 16),
              _SyncPanel(
                controller: _targetDeviceController,
                state: state,
                onSendLogin: () => ref
                    .read(sellControllerProvider.notifier)
                    .dispatchLoginCommand(targetDeviceId: _targetDeviceController.text),
                onSendOpen: () => ref
                    .read(sellControllerProvider.notifier)
                    .dispatchOpenSellView(targetDeviceId: _targetDeviceController.text),
                onSendSell: () => ref
                    .read(sellControllerProvider.notifier)
                    .dispatchSellCommand(targetDeviceId: _targetDeviceController.text),
                onPoll: () => ref.read(sellControllerProvider.notifier).pollCommands(
                      targetDevice: 'desktop',
                      targetDeviceId: _targetDeviceController.text.isEmpty
                          ? null
                          : _targetDeviceController.text,
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

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.quantityController,
    required this.amountController,
    required this.onQuantityChanged,
    required this.onAmountChanged,
  });

  final TextEditingController quantityController;
  final TextEditingController amountController;
  final ValueChanged<String> onQuantityChanged;
  final ValueChanged<String> onAmountChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: quantityController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true, signed: false),
            decoration: InputDecoration(
              labelText: 'Количество',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: onQuantityChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true, signed: false),
            decoration: InputDecoration(
              labelText: 'Сумма USD',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: onAmountChanged,
          ),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview});

  final SellPreview preview;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Предпросмотр',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Источник цены: ${preview.priceSource.toUpperCase()}'),
            Text('Цена за единицу: ${formatCurrency(preview.unitPrice, 'USD')}'),
            Text('Количество к продаже: ${preview.quantity.toStringAsFixed(6)}'),
            Text('Выручка: ${formatCurrency(preview.proceeds, 'USD')}'),
            Text('Доступно: ${preview.availableQuantity.toStringAsFixed(6)}'),
            Text(preview.isFullPosition ? 'Продается вся позиция' : 'Частичная продажа'),
          ],
        ),
      ),
    );
  }
}

class _SellResultCard extends StatelessWidget {
  const _SellResultCard({required this.execution});

  final SellExecution execution;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.withAlpha((0.08 * 255).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Сделка выполнена',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '${execution.symbol}: ${execution.quantity.toStringAsFixed(6)} шт по ${formatCurrency(execution.price, 'USD')}',
            ),
            Text('Получено: ${formatCurrency(execution.received, 'USD')}'),
            Text('Новая наличность: ${formatCurrency(execution.cashBalance, 'USD')}'),
            Text('PnL: ${formatCurrency(execution.realizedPnl, 'USD')}'),
          ],
        ),
      ),
    );
  }
}

class _SyncPanel extends StatelessWidget {
  const _SyncPanel({
    required this.controller,
    required this.state,
    required this.onSendLogin,
    required this.onSendOpen,
    required this.onSendSell,
    required this.onPoll,
    required this.onAck,
  });

  final TextEditingController controller;
  final SellState state;
  final VoidCallback onSendLogin;
  final VoidCallback onSendOpen;
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
            Text(
              'Синхронизация с ПК',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'ID ПК (опционально)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Отправить LOGIN'),
                  onPressed: state.isSendingCommand ? null : onSendLogin,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Открыть вкладку продаж'),
                  onPressed: state.isSendingCommand ? null : onSendOpen,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Команда EXECUTE_SELL'),
                  onPressed: state.isSendingCommand ? null : onSendSell,
                ),
                IconButton.outlined(
                  tooltip: 'Получить команды для ПК',
                  icon: const Icon(Icons.sync),
                  onPressed: state.isSendingCommand ? null : onPoll,
                ),
              ],
            ),
            if (state.pendingCommands.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Ожидающие команды (debug для ПК клиента):',
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
                        child: const Text('ACK'),
                      ),
                      TextButton(
                        onPressed: () => onAck(cmd.id, 'FAILED'),
                        child: const Text('FAIL'),
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
