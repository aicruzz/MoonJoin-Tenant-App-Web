import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/virtual_account_model.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class VirtualAccountCard extends StatelessWidget {
  final VirtualAccountModel account;
  const VirtualAccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.account_balance_outlined,
                color: Theme.of(context).primaryColor),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(_providerLabel(account.provider),
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault)),
            const Spacer(),
            if (!account.isActive)
              Text('inactive',
                  style: robotoMedium.copyWith(
                      color: Theme.of(context).disabledColor,
                      fontSize: Dimensions.fontSizeSmall)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if ((account.bankName ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(account.bankName!,
                  style: robotoMedium.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall)),
            ),
          Row(children: [
            Expanded(
              child: Text(account.accountNumber,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      letterSpacing: 1.6)),
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              tooltip: 'Copy account number',
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: account.accountNumber));
                showCustomSnackBar('Account number copied', isError: false);
              },
            ),
          ]),
          if ((account.accountName ?? '').isNotEmpty)
            Text(account.accountName!,
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'Transfers to this account credit your MoonJoin Cloud wallet automatically.',
            style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeExtraSmall),
          ),
        ],
      ),
    );
  }

  String _providerLabel(String key) {
    switch (key) {
      case '9psb':
        return '9PSB virtual account';
      case 'monnify':
        return 'Monnify virtual account';
      case 'paystack':
        return 'Paystack dedicated account';
      case 'flutterwave':
        return 'Flutterwave virtual account';
      default:
        return key;
    }
  }
}
