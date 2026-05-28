import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/common/widgets/module_badge.dart';
import 'package:moonjoin_cloud/features/api_products/domain/models/api_product_model.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class ApiProductCard extends StatelessWidget {
  final ApiProductModel product;
  final VoidCallback onTap;

  const ApiProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final keys = product.activeCredentialsCount;
    final hasWebhook =
        product.webhookUrl != null && product.webhookUrl!.isNotEmpty;
    final tags = product.productType == 'modules_delivery'
        ? product.modules.map((e) => e.moduleKey).toList()
        : product.supportedCategories;

    return Container(
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
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                _StatusPill(status: product.status),
              ]),
              const SizedBox(height: 4),
              Text(
                product.productType == 'modules_delivery'
                    ? 'Modules Delivery'
                    : 'MoonJoin Delivery',
                style: robotoMedium.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              if (tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < tags.length && i < 4; i++)
                      ModuleBadge(moduleKey: tags[i], small: true),
                    if (tags.length > 4)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusLarge),
                        ),
                        child: Text('+${tags.length - 4}',
                            style: robotoMedium.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeExtraSmall)),
                      ),
                  ],
                ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(children: [
                _Stat(
                  icon: Icons.vpn_key_outlined,
                  text: keys == 1 ? '1 key' : '$keys keys',
                ),
                const SizedBox(width: Dimensions.paddingSizeLarge),
                Expanded(
                  child: _Stat(
                    icon: Icons.webhook_outlined,
                    text: hasWebhook
                        ? Uri.tryParse(product.webhookUrl!)?.host ??
                            product.webhookUrl!
                        : 'No webhook',
                    muted: !hasWebhook,
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: Theme.of(context).hintColor),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Text(status.toUpperCase(),
          style: robotoMedium.copyWith(
              color: tone.text,
              fontSize: Dimensions.fontSizeExtraSmall,
              letterSpacing: 0.3)),
    );
  }

  ({Color bg, Color text}) _toneFor(String status) {
    switch (status) {
      case 'active':
        return (bg: const Color(0xFFE6F8EE), text: const Color(0xFF137C36));
      case 'pending':
        return (bg: const Color(0xFFFFF6E0), text: const Color(0xFFA66B00));
      case 'suspended':
        return (bg: const Color(0xFFFCEAEC), text: const Color(0xFFB31E2A));
      case 'draft':
      default:
        return (bg: const Color(0xFFEDF0F5), text: const Color(0xFF3F4855));
    }
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool muted;
  const _Stat({required this.icon, required this.text, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final color = muted
        ? Theme.of(context).hintColor
        : Theme.of(context).colorScheme.onSurface;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Flexible(
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(
                color: color, fontSize: Dimensions.fontSizeSmall)),
      ),
    ]);
  }
}
