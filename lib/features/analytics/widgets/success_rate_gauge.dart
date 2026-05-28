import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/features/analytics/domain/models/analytics_models.dart';
import 'package:moonjoin_cloud/features/analytics/widgets/chart_card.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class SuccessRateGauge extends StatelessWidget {
  final AnalyticsSuccessRate? summary;
  const SuccessRateGauge({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Delivery success rate',
      subtitle: summary == null || summary!.ordersTotal == 0
          ? 'Waiting for first orders'
          : '${summary!.ordersDelivered} of ${summary!.ordersTotal} delivered',
      height: 200,
      child: summary == null || summary!.ordersTotal == 0
          ? const ChartEmpty()
          : _Donut(summary: summary!),
    );
  }
}

class _Donut extends StatelessWidget {
  final AnalyticsSuccessRate summary;
  const _Donut({required this.summary});

  @override
  Widget build(BuildContext context) {
    final delivered = summary.ordersDelivered.toDouble();
    final other = (summary.ordersTotal - summary.ordersDelivered).toDouble();
    final pct = summary.successRatePercent;
    return Row(children: [
      Expanded(
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(alignment: Alignment.center, children: [
            PieChart(
              PieChartData(
                startDegreeOffset: -90,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    value: delivered,
                    color: Theme.of(context).primaryColor,
                    showTitle: false,
                    radius: 14,
                  ),
                  PieChartSectionData(
                    value: other <= 0 ? 0.0001 : other,
                    color:
                        Theme.of(context).hintColor.withValues(alpha: 0.15),
                    showTitle: false,
                    radius: 14,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${pct.toStringAsFixed(pct < 10 ? 1 : 0)}%',
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeOverLarge)),
                Text('success',
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall)),
              ],
            ),
          ]),
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeDefault),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stat(context, 'Total', '${summary.ordersTotal}'),
            const SizedBox(height: 8),
            _stat(context, 'Delivered', '${summary.ordersDelivered}',
                tone: const Color(0xFF137C36)),
            const SizedBox(height: 8),
            _stat(context, 'Cancelled', '${summary.ordersCancelled}',
                tone: const Color(0xFFB31E2A)),
          ],
        ),
      ),
    ]);
  }

  Widget _stat(BuildContext context, String k, String v, {Color? tone}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k,
            style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeSmall)),
        Text(v,
            style: robotoBold.copyWith(
                color: tone, fontSize: Dimensions.fontSizeLarge)),
      ],
    );
  }
}
