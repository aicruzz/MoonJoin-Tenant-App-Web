import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/common/widgets/feature_placeholder.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.insights_outlined,
      title: 'Analytics',
      description:
          'Orders over time, delivery success rate, webhook health, module mix, and recent activity. Charts via fl_chart.',
      backendStatus: 'Phase 4 — analytics aggregation REST pending',
    );
  }
}
