import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/common/widgets/feature_placeholder.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.store_outlined,
      title: 'Branches',
      description:
          'CRUD with Google Maps picker (Places + Reverse Geocoding) and zone availability preview.',
      backendStatus: 'Phase 4 — /api/merchant/branches + /zones/check pending',
    );
  }
}
