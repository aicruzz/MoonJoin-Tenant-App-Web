import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/features/analytics/widgets/chart_card.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// Reads from the dashboard summary (already polled by Phase C) instead of
/// hitting the network again. The dashboard tab and analytics tab both share
/// the same `DashboardSummaryModel.moduleBreakdown` source of truth.
class ModuleMixDonut extends StatelessWidget {
  final List<ModuleBreakdownEntry> entries;
  const ModuleMixDonut({super.key, required this.entries});

  static const _palette = <Color>[
    Color(0xFFE6803F),
    Color(0xFF1BAE4E),
    Color(0xFF4F8BF6),
    Color(0xFFAE52D4),
    Color(0xFF666E7A),
    Color(0xFFCC2A36),
    Color(0xFFF1A33A),
    Color(0xFF6E5BD2),
    Color(0xFF2E7DBE),
    Color(0xFF1AA08D),
  ];

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<int>(0, (acc, e) => acc + e.count);
    return ChartCard(
      title: 'Module mix',
      subtitle: total == 0
          ? 'No deliveries to break down yet'
          : '$total orders across ${entries.length} module(s)',
      height: 220,
      child: total == 0
          ? const ChartEmpty()
          : _Donut(entries: entries, total: total),
    );
  }
}

class _Donut extends StatelessWidget {
  final List<ModuleBreakdownEntry> entries;
  final int total;
  const _Donut({required this.entries, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              startDegreeOffset: -90,
              centerSpaceRadius: 48,
              sections: [
                for (int i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].count.toDouble(),
                    color: ModuleMixDonut._palette[
                        i % ModuleMixDonut._palette.length],
                    showTitle: false,
                    radius: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeDefault),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < entries.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: ModuleMixDonut._palette[
                            i % ModuleMixDonut._palette.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Module ${entries[i].moduleId}',
                          overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall)),
                    ),
                    Text(
                      '${entries[i].count} (${((entries[i].count / total) * 100).toStringAsFixed(0)}%)',
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeExtraSmall),
                    ),
                  ]),
                ),
            ],
          ),
        ),
      ),
    ]);
  }
}
