import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class DashboardMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  const DashboardMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: robotoMedium.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall)),
            const SizedBox(height: 4),
            Text(value,
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge)),
            const SizedBox(height: 4),
            Text(trend,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall)),
          ]),
        ),
      ]),
    );
  }
}
