import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/common/widgets/feature_placeholder.dart';

class WebhooksScreen extends StatelessWidget {
  const WebhooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.webhook_outlined,
      title: 'Webhooks',
      description:
          'Configure webhook URL & secret, view delivery log via /api/v1/partner/webhooks/deliveries, retry failed events, send a test ping.',
      backendStatus: 'Phase 3 — delivery log EXISTS; test/ping pending',
    );
  }
}
