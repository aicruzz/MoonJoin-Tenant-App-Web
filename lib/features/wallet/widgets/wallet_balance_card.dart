import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/wallet_balance_model.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class WalletBalanceCard extends StatelessWidget {
  final WalletBalanceModel balance;
  final VoidCallback? onFund;
  final bool fundDisabled;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    this.onFund,
    this.fundDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final ccy = NumberFormat.simpleCurrency(
      name: balance.currency.isEmpty ? 'NGN' : balance.currency,
      decimalDigits: 2,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available balance',
            style: robotoMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: Dimensions.fontSizeSmall),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            ccy.format(balance.balance),
            style: robotoBold.copyWith(
              color: Colors.white,
              fontSize: 32,
              height: 1.1,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(children: [
            _HoldsChip(amount: ccy.format(balance.pendingHolds)),
            const Spacer(),
            if (onFund != null)
              FilledButton.icon(
                onPressed: fundDisabled ? null : onFund,
                icon: const Icon(Icons.add),
                label: const Text('Fund wallet'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                ),
              ),
          ]),
        ],
      ),
    );
  }
}

class _HoldsChip extends StatelessWidget {
  final String amount;
  const _HoldsChip({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          'Funds reserved for in-flight deliveries. Released to riders on confirmed delivery or refunded on cancel.',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.lock_outline, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text('On hold: $amount',
              style: robotoMedium.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeSmall)),
        ]),
      ),
    );
  }
}
