import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/dashboard_models.dart';
import '../../navigation/main_navigation_controller.dart';
import '../../session/controllers/session_controller.dart';
import '../controllers/home_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    ref.listen<HomeState>(homeControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        if (!mounted) {
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(SnackBar(content: Text(next.error!)));
        ref.read(homeControllerProvider.notifier).clearError();
      }
    });

    final session = ref.watch(sessionControllerProvider);
    final homeState = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final user = session.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('comoney'),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: CircleAvatar(
            child: Text(
              user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          if (homeState.isRefreshing)
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
              tooltip: 'Обновить данные',
              onPressed: () => controller.refresh(
                forceShowLoading: homeState.dashboard == null,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '����ன��',
            onPressed: session.isLoading
                ? null
                : () => context.push(AppRoute.profileSettings),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '��� �� ������',
            onPressed: session.isLoading
                ? null
                : () async =>
                      ref.read(sessionControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: homeState.isLoading && !homeState.hasContent
            ? ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : homeState.dashboard == null
            ? ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Нет данных для отображения')),
                ],
              )
            : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                children: [
                  FilledButton.icon(
                    onPressed: () =>
                        ref.read(mainTabProvider.notifier).state = MainTab.trade,
                    icon: const Icon(Icons.add_shopping_cart_outlined),
                    label: const Text('Buy crypto'),
                  ),
                  const SizedBox(height: 12),
                  BalanceSection(data: homeState.dashboard!),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Market Movers',
                    actionLabel: 'More',
                    onAction: () => context.push(
                      '${AppRoute.marketMovers}/${homeState.dashboard!.currency}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  MarketMoversRow(
                    movers: homeState.dashboard!.marketMovers,
                    currency: homeState.dashboard!.currency,
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Portfolio'),
                  const SizedBox(height: 12),
                  const Text(
                    'Здесь появится ваш портфель после добавления активов',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Обновлено в ${DateFormat('HH:mm').format(homeState.dashboard!.lastUpdated)}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
      ),
    );
  }
}

class BalanceSection extends StatelessWidget {
  const BalanceSection({required this.data, super.key});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final balance = formatCurrency(data.portfolioBalance, data.currency);
    final changeText = formatSignedPercent(data.balanceChangePct);
    final changePositive = data.balanceChangePct >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Balance',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  balance,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (changePositive ? _positiveColor : _negativeColor)
                      .withAlpha((0.12 * 255).round()),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  changeText,
                  style: TextStyle(
                    color: changePositive ? _positiveColor : _negativeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class MarketMoversRow extends StatelessWidget {
  const MarketMoversRow({
    required this.movers,
    required this.currency,
    super.key,
  });

  final List<MarketMover> movers;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (movers.isEmpty) {
      return const Text('Нет данных по рынку');
    }
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final mover = movers[index];
          return MarketMoverCard(mover: mover, currency: currency);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: movers.length,
      ),
    );
  }
}

class MarketMoverCard extends StatelessWidget {
  const MarketMoverCard({
    required this.mover,
    required this.currency,
    super.key,
  });

  final MarketMover mover;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final price = formatCurrency(mover.currentPrice, currency);
    final change = formatSignedPercent(mover.change24hPct);
    final changePositive = mover.change24hPct >= 0;
    final volume = formatVolume(mover.volume24h);

    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B8CFF), Color(0xFF7AE582)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x335B8CFF),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AssetAvatar(imageUrl: mover.imageUrl, title: mover.name),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mover.pair,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      mover.name,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            price,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            change,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: changePositive
                  ? const Color(0xFFB9FFD0)
                  : const Color(0xFFFFD0D0),
            ),
          ),
          const Spacer(),
          Text(
            '24H Vol.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          Text(
            volume,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class AssetAvatar extends StatelessWidget {
  const AssetAvatar({required this.imageUrl, required this.title, super.key});

  final String? imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 40,
        width: 40,
        child: imageUrl == null
            ? Container(
                color: Colors.white24,
                child: Center(
                  child: Text(
                    title.isNotEmpty ? title[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Colors.white24,
                  child: Center(
                    child: Text(
                      title.isNotEmpty ? title[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

const _positiveColor = Color(0xFF24C16B);
const _negativeColor = Color(0xFFDA5B5B);
