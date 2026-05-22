import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/dashboard/controllers/dashboard_controller.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:moonjoin_cloud/features/dashboard/widgets/dashboard_metric_tile.dart';
import 'package:moonjoin_cloud/helper/responsive_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      return LoadingState(
        status: controller.status,
        errorMessage: controller.errorMessage,
        onRetry: controller.initialLoad,
        content: (ctx) => _DashboardContent(controller: controller),
      );
    });
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardController controller;
  const _DashboardContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.isDesktop(context)
        ? 4
        : ResponsiveHelper.isTab(context)
            ? 2
            : 1;
    final s = controller.summary;
    final ccy = NumberFormat.simpleCurrency(
      name: s.walletCurrency.isEmpty ? 'NGN' : s.walletCurrency,
      decimalDigits: 2,
    );

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        children: [
          _Header(controller: controller),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            crossAxisSpacing: Dimensions.paddingSizeDefault,
            mainAxisSpacing: Dimensions.paddingSizeDefault,
            childAspectRatio: 2.2,
            children: [
              DashboardMetricTile(
                label: 'Wallet balance',
                value: ccy.format(s.walletBalance),
                trend: 'Pending holds: ${ccy.format(s.walletPendingHolds)}',
                icon: Icons.account_balance_wallet_outlined,
              ),
              DashboardMetricTile(
                label: 'Orders (${_rangeLabel(controller.range)})',
                value: s.ordersTotal.toString(),
                trend:
                    '${s.ordersDelivered} delivered · ${s.ordersCancelled} cancelled',
                icon: Icons.local_shipping_outlined,
              ),
              DashboardMetricTile(
                label: 'Success rate',
                value: _percent(s.successRatePercent),
                trend: s.ordersTotal == 0
                    ? 'No orders yet'
                    : '${s.ordersDelivered}/${s.ordersTotal} delivered',
                icon: Icons.check_circle_outline,
              ),
              DashboardMetricTile(
                label: 'Webhook health',
                value: _percent(s.webhookHealthPercent),
                trend: s.webhookDeliveriesTotal == 0
                    ? 'No webhook events yet'
                    : '${s.webhookFailures} failed / ${s.webhookDeliveriesTotal} sent',
                icon: Icons.webhook_outlined,
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _SpendingCard(summary: s, ccy: ccy),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _ModuleMixCard(summary: s),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _RecentDeliveriesCard(summary: s),
        ],
      ),
    );
  }

  String _rangeLabel(String r) => switch (r) {
        'today' => 'today',
        '24h' || '1d' => '24h',
        '7d' => '7 d',
        '30d' => '30 d',
        '90d' => '90 d',
        _ => r,
      };

  String _percent(double? v) {
    if (v == null) return '—';
    return '${v.toStringAsFixed(v < 10 ? 1 : 0)}%';
  }
}

class _Header extends StatelessWidget {
  final DashboardController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final name = auth.merchant?.companyName ?? 'there';
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, $name',
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeOverLarge)),
            const SizedBox(height: 4),
            Text(
              'Live metrics for ${_rangeText(controller.range)}'
              '${controller.isPolling ? " · refreshing…" : ""}',
              style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
      _RangeChooser(
        current: controller.range,
        onChanged: controller.setRange,
      ),
    ]);
  }

  String _rangeText(String r) => switch (r) {
        'today' => 'today',
        '24h' || '1d' => 'the past 24 h',
        '7d' => 'the past 7 days',
        '30d' => 'the past 30 days',
        '90d' => 'the past 90 days',
        _ => r,
      };
}

class _RangeChooser extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _RangeChooser({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Range',
      initialValue: current,
      onSelected: onChanged,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'today', child: Text('Today')),
        PopupMenuItem(value: '7d', child: Text('Last 7 days')),
        PopupMenuItem(value: '30d', child: Text('Last 30 days')),
        PopupMenuItem(value: '90d', child: Text('Last 90 days')),
      ],
      child: Chip(
        avatar: const Icon(Icons.calendar_month, size: 16),
        label: Text(current.toUpperCase()),
      ),
    );
  }
}

class _SpendingCard extends StatelessWidget {
  final DashboardSummaryModel summary;
  final NumberFormat ccy;
  const _SpendingCard({required this.summary, required this.ccy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [
        Expanded(
          child: _Stat(
            label: 'Delivery spend',
            value: ccy.format(summary.deliveryChargesSum),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeLarge),
        Expanded(
          child: _Stat(
            label: 'Escrow released to riders',
            value: ccy.format(summary.escrowReleasedSum),
          ),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: robotoMedium.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeSmall)),
      const SizedBox(height: 4),
      Text(value,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
    ]);
  }
}

class _ModuleMixCard extends StatelessWidget {
  final DashboardSummaryModel summary;
  const _ModuleMixCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.moduleBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }
    final total =
        summary.moduleBreakdown.fold<int>(0, (acc, e) => acc + e.count);
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Module mix',
              style:
                  robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ...summary.moduleBreakdown.map((e) {
            final pct = total > 0 ? (e.count / total) * 100 : 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                SizedBox(
                  width: 90,
                  child: Text('Module ${e.moduleId}',
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall)),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: total > 0 ? e.count / total : 0,
                    minHeight: 6,
                    backgroundColor: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text('${e.count} (${pct.toStringAsFixed(0)}%)',
                    style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor)),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

class _RecentDeliveriesCard extends StatelessWidget {
  final DashboardSummaryModel summary;
  const _RecentDeliveriesCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Recent deliveries',
              style:
                  robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const Spacer(),
          if (summary.ordersTotal > 0)
            Text('${summary.ordersTotal} total',
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall)),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          summary.ordersTotal == 0
              ? 'Create an API product and dispatch your first delivery to see it here.'
              : 'Open the Deliveries tab for the full timeline.',
          style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
        ),
      ]),
    );
  }
}
