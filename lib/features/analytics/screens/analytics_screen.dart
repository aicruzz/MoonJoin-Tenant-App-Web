import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/analytics/controllers/analytics_controller.dart';
import 'package:moonjoin_cloud/features/analytics/widgets/module_mix_donut.dart';
import 'package:moonjoin_cloud/features/analytics/widgets/orders_line_chart.dart';
import 'package:moonjoin_cloud/features/analytics/widgets/success_rate_gauge.dart';
import 'package:moonjoin_cloud/features/analytics/widgets/webhooks_stacked_bar.dart';
import 'package:moonjoin_cloud/features/dashboard/controllers/dashboard_controller.dart';
import 'package:moonjoin_cloud/helper/responsive_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _kicked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_kicked) return;
      _kicked = true;
      final c = Get.find<AnalyticsController>();
      if (c.status == LoadingStatus.idle) {
        // ignore: discarded_futures
        c.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnalyticsController>(builder: (controller) {
      return LoadingState(
        status: controller.status,
        errorMessage: controller.errorMessage,
        onRetry: controller.load,
        content: (_) => _Content(controller: controller),
      );
    });
  }
}

class _Content extends StatelessWidget {
  final AnalyticsController controller;
  const _Content({required this.controller});

  @override
  Widget build(BuildContext context) {
    final twoCol = ResponsiveHelper.isDesktop(context) ||
        ResponsiveHelper.isTab(context);
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: GetBuilder<DashboardController>(builder: (dashboard) {
        final breakdown = dashboard.summary.moduleBreakdown;
        return ListView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          children: [
            _Header(controller: controller),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            OrdersLineChart(series: controller.orders),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            if (twoCol)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child:
                          SuccessRateGauge(summary: controller.successRate),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(child: ModuleMixDonut(entries: breakdown)),
                  ],
                ),
              )
            else ...[
              SuccessRateGauge(summary: controller.successRate),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              ModuleMixDonut(entries: breakdown),
            ],
            const SizedBox(height: Dimensions.paddingSizeDefault),
            WebhooksStackedBar(series: controller.webhooks),
            const SizedBox(height: 60),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  final AnalyticsController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeOverLarge)),
              const SizedBox(height: 4),
              Text(
                'Orders, success rate, webhook health, and module mix.',
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Range',
          initialValue: controller.range,
          onSelected: controller.setRange,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'today', child: Text('Today')),
            PopupMenuItem(value: '7d', child: Text('Last 7 days')),
            PopupMenuItem(value: '30d', child: Text('Last 30 days')),
            PopupMenuItem(value: '90d', child: Text('Last 90 days')),
          ],
          child: Chip(
            avatar: const Icon(Icons.calendar_month, size: 16),
            label: Text(controller.range.toUpperCase()),
          ),
        ),
      ],
    );
  }
}
