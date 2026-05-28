import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonjoin_cloud/features/analytics/domain/models/analytics_models.dart';
import 'package:moonjoin_cloud/features/analytics/widgets/chart_card.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class WebhooksStackedBar extends StatelessWidget {
  final AnalyticsWebhookSeries? series;
  const WebhooksStackedBar({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final pts = series?.series ?? const <WebhookSeriesPoint>[];
    final hasData = pts.any((p) => p.deliveriesTotal > 0);
    return ChartCard(
      title: 'Webhook delivery health',
      subtitle: 'Delivered + failed per day',
      child: !hasData
          ? const ChartEmpty(message: 'No webhook events yet')
          : _buildBar(context, pts),
    );
  }

  Widget _buildBar(BuildContext context, List<WebhookSeriesPoint> pts) {
    const delivered = Color(0xFF1BAE4E);
    const failed = Color(0xFFCC2A36);
    final maxY = pts.fold<int>(
        0, (acc, p) => p.deliveriesTotal > acc ? p.deliveriesTotal : acc) * 1.2;
    final niceMax = (maxY <= 4 ? 4 : maxY).toDouble();

    return BarChart(
      BarChartData(
        maxY: niceMax,
        barGroups: [
          for (int i = 0; i < pts.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: pts[i].deliveriesTotal.toDouble(),
                width: 12,
                color: delivered,
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    (pts[i].deliveriesTotal - pts[i].failures).toDouble(),
                    delivered,
                  ),
                  BarChartRodStackItem(
                    (pts[i].deliveriesTotal - pts[i].failures).toDouble(),
                    pts[i].deliveriesTotal.toDouble(),
                    failed,
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]),
        ],
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, meta) => Text(
                v.toStringAsFixed(0),
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: pts.length > 12
                  ? (pts.length / 6).floorToDouble()
                  : 1,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= pts.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('d MMM').format(pts[i].date),
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Theme.of(context).hintColor.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
