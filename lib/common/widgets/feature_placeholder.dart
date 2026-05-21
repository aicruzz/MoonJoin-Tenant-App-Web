import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// Visual stub for features that will land in later phases.
class FeaturePlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? backendStatus;
  const FeaturePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.backendStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    size: 36, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(title,
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(description,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor)),
              if (backendStatus != null) ...[
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(backendStatus!,
                      style: robotoMedium.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeSmall)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
