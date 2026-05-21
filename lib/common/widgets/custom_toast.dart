import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class CustomToast extends StatelessWidget {
  final String text;
  final bool isError;
  const CustomToast({super.key, required this.text, this.isError = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFE84D4F) : Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [
        Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white,
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Text(
            text,
            style: robotoMedium.copyWith(color: Colors.white),
          ),
        ),
      ]),
    );
  }
}
