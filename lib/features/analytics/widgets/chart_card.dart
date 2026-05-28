import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final double height;
  const ChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall)),
          ],
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(height: height, child: child),
        ],
      ),
    );
  }
}

class ChartEmpty extends StatelessWidget {
  final String message;
  const ChartEmpty({super.key, this.message = 'No data yet'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message,
          style: robotoMedium.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeSmall)),
    );
  }
}
