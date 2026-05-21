import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class NoDataScreen extends StatelessWidget {
  final String text;
  final IconData icon;
  const NoDataScreen({
    super.key,
    this.text = 'No data found',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            text,
            style: robotoMedium.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}
