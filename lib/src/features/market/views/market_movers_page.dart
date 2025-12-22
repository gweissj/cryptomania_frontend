import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/dashboard_models.dart';
import '../controllers/market_movers_controller.dart';

class MarketMoversPage extends ConsumerStatefulWidget {
  const MarketMoversPage({required this.currency, super.key});

  final String currency;

  @override
  ConsumerState<MarketMoversPage> createState() => _MarketMoversPageState();
}

class _MarketMoversPageState extends ConsumerState<MarketMoversPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketMoversControllerProvider.notifier).loadTop(widget.currency);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketMoversControllerProvider);
    final controller = ref.read(marketMoversControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Маркет - цены валют'),
        actions: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh market',
              onPressed: () =>
                  controller.loadTop(widget.currency, forceRefresh: true),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadTop(widget.currency, forceRefresh: true),
        child: Builder(
          builder: (context) {
            if (state.isLoading) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (state.error != null) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(state.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: controller.retry,
                    child: const Text('Повторить'),
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.lastUpdated != null) ...[
                  Text(
                    'Время обновления данных ${DateFormat('HH:mm').format(state.lastUpdated!)}',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                ],
                for (var i = 0; i < state.items.length; i++) ...[
                  MoverRow(mover: state.items[i], currency: widget.currency),
                  if (i != state.items.length - 1) const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class MoverRow extends StatelessWidget {
  const MoverRow({required this.mover, required this.currency, super.key});

  final MarketMover mover;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final price = formatCurrency(mover.currentPrice, currency);
    final change = formatSignedPercent(mover.change24hPct);
    final changePositive = mover.change24hPct >= 0;
    final volume = formatVolume(mover.volume24h);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: mover.imageUrl == null
                      ? Container(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha((0.1 * 255).round()),
                          child: Center(
                            child: Text(
                              mover.name.isNotEmpty ? mover.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: mover.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mover.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          change,
                          style: TextStyle(
                            color: changePositive ? _positiveColor : _negativeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          mover.pair,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                        Text(
                          price,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: Sparkline(
              values: mover.sparkline ?? const [],
              isPositive: changePositive,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '24H Vol.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              Text(volume),
            ],
          ),
        ],
      ),
    );
  }
}

class Sparkline extends StatelessWidget {
  const Sparkline({required this.values, required this.isPositive, super.key});

  final List<double> values;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      final surface = Theme.of(context).colorScheme.surfaceContainerHighest;
      return Container(
        decoration: BoxDecoration(
          color: surface.withAlpha((0.3 * 255).round()),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }
    return CustomPaint(
      painter: _SparklinePainter(values: values, isPositive: isPositive),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.isPositive});

  final List<double> values;
  final bool isPositive;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = (max - min).clamp(1e-6, double.infinity);
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final yRatio = (values[i] - min) / range;
      final y = size.height - yRatio * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = isPositive ? _positiveColor : _negativeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.isPositive != isPositive;
  }
}

const _positiveColor = Color(0xFF24C16B);
const _negativeColor = Color(0xFFDA5B5B);
