import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// Colored chip for a MoonJoin category or Modules-Delivery module key.
/// Falls back to a neutral grey when the key isn't in either list.
class ModuleBadge extends StatelessWidget {
  final String moduleKey;
  final bool small;
  const ModuleBadge({super.key, required this.moduleKey, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(moduleKey);
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
        : const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall, vertical: 4);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label(moduleKey),
        style: robotoMedium.copyWith(
          color: color,
          fontSize: small ? Dimensions.fontSizeExtraSmall : Dimensions.fontSizeSmall,
        ),
      ),
    );
  }

  String _label(String key) {
    switch (key) {
      case 'food':
        return 'Food';
      case 'grocery':
        return 'Grocery';
      case 'pharmacy':
        return 'Pharmacy';
      case 'fashion':
        return 'Fashion';
      case 'parcel':
        return 'Parcel';
      case 'fuel':
        return 'Fuel';
      case 'gas':
        return 'Gas';
      case 'drink':
        return 'Drink';
      case 'electronics':
        return 'Electronics';
      case 'market':
        return 'Market';
      default:
        return key;
    }
  }

  Color _colorFor(String key) {
    switch (key) {
      case 'food':
        return const Color(0xFFE6803F);
      case 'grocery':
        return const Color(0xFF1BAE4E);
      case 'pharmacy':
        return const Color(0xFF4F8BF6);
      case 'fashion':
        return const Color(0xFFAE52D4);
      case 'parcel':
        return const Color(0xFF666E7A);
      case 'fuel':
        return const Color(0xFFCC2A36);
      case 'gas':
        return const Color(0xFFF1A33A);
      case 'drink':
        return const Color(0xFF6E5BD2);
      case 'electronics':
        return const Color(0xFF2E7DBE);
      case 'market':
        return const Color(0xFF1AA08D);
      default:
        return const Color(0xFF9F9F9F);
    }
  }
}
