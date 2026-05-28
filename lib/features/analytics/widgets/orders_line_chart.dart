import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonjoin_cloud/features/analytics/domain/models/analytics_models.dart';
import 'package:moonjoin_cloud/features/analytics/widgets/chart_card.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class OrdersLineChart extends StatelessWidget {
  final AnalyticsOrdersSeries? series;
  const OrdersLineChart({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final points = series?.points ?? const <OrdersSeriesPoint>[];
    final hasData = points.any((p) => p.ordersTotal > 0);
    return ChartCard(
      title: 'Orders over time',
      subtitle: 'Total vs delivered',
      child: !hasData
          ? const ChartEmpty(message: 'No orders in this range yet')
          : _buildChart(context, points),
    );
  }

  Widget _buildChart(BuildContext context, List<OrdersSeriesPoint> pts) {
    final primary = Theme.of(context).primaryColor;
    const delivered = Color(0xFF1BAE4E);
    final maxY = pts.fold<int>(0, (acc, p) => p.ordersTotal > acc ? p.ordersTotal : acc) * 1.2;
    final niceMax = (maxY <= 4 ? 4 : maxY).toDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: niceMax,
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
        lineBarsData: [
          _line(pts.map((p) => p.ordersTotal.toDouble()).toList(),
              primary, true),
          _line(pts.map((p) => p.ordersDelivered.toDouble()).toList(),
              delivered, false),
        ],
      ),
    );
  }

  LineChartBarData _line(List<double> ys, Color color, bool fill) {
    return LineChartBarData(
      spots: [for (int i = 0; i < ys.length; i++) FlSpot(i.toDouble(), ys[i])],
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: fill
          ? BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.12),
            )
          : BarAreaData(show: false),
    );
  }
}
