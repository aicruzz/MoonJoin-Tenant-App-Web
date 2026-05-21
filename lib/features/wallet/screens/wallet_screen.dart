import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/common/widgets/feature_placeholder.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Wallet',
      description:
          'Balance, paginated transactions, fund via Paystack / Flutterwave / Monnify, and your 9PSB virtual account.',
      backendStatus: 'Phase 2 — awaiting wallet REST endpoints',
    );
  }
}
