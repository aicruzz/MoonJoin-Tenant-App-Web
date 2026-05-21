import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/common/widgets/feature_placeholder.dart';

class DeliveriesScreen extends StatelessWidget {
  const DeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.local_shipping_outlined,
      title: 'Deliveries',
      description:
          'List + detail with status timeline. Created externally via the partner API; tracked here once the session-auth wrapper lands.',
      backendStatus: 'Phase 4 — /api/merchant/deliveries pending',
    );
  }
}
