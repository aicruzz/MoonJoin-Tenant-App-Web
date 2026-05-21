import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/common/widgets/feature_placeholder.dart';

class ApiProductsScreen extends StatelessWidget {
  const ApiProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.api_outlined,
      title: 'API Products',
      description:
          'Issue keys for MoonJoin Delivery (food / grocery / pharmacy / fashion / parcel) or Modules Delivery (fuel / gas / drink / electronics / market). Reveal once, rotate, revoke.',
      backendStatus: 'Phase 3 — REST CRUD endpoints needed',
    );
  }
}
