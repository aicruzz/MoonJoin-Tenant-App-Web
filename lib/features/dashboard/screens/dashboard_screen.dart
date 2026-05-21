import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/features/dashboard/widgets/dashboard_metric_tile.dart';
import 'package:moonjoin_cloud/helper/responsive_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.isDesktop(context)
        ? 4
        : ResponsiveHelper.isTab(context)
            ? 2
            : 1;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome back',
            style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeOverLarge)),
        const SizedBox(height: 4),
        Text('Here is what is happening across your workspace today.',
            style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor)),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: Dimensions.paddingSizeDefault,
          mainAxisSpacing: Dimensions.paddingSizeDefault,
          childAspectRatio: 2.2,
          children: const [
            DashboardMetricTile(
              label: 'Wallet balance',
              value: '₦ —',
              trend: 'Pending wallet REST',
              icon: Icons.account_balance_wallet,
            ),
            DashboardMetricTile(
              label: 'Today\'s orders',
              value: '0',
              trend: 'Awaiting analytics endpoint',
              icon: Icons.local_shipping,
            ),
            DashboardMetricTile(
              label: 'Success rate',
              value: '—',
              trend: '7-day average',
              icon: Icons.check_circle_outline,
            ),
            DashboardMetricTile(
              label: 'Webhook health',
              value: '—',
              trend: 'Deliveries / failures',
              icon: Icons.webhook,
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius:
                BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Recent deliveries',
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'Live from /api/v1/partner/orders once a key is configured.',
              style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor),
            ),
          ]),
        ),
      ]),
    );
  }
}
