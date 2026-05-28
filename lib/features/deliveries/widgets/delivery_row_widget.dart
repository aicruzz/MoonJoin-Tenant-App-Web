import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/models/delivery_model.dart';
import 'package:moonjoin_cloud/features/deliveries/widgets/delivery_status_pill.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class DeliveryRowWidget extends StatelessWidget {
  final DeliveryModel delivery;
  final VoidCallback onTap;
  const DeliveryRowWidget({
    super.key,
    required this.delivery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ccy = NumberFormat.simpleCurrency(name: 'NGN', decimalDigits: 0);
    final total = delivery.pricing.orderAmount + delivery.pricing.deliveryCharge;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Icon(Icons.local_shipping_outlined,
                  color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        delivery.partnerReference?.isNotEmpty == true
                            ? delivery.partnerReference!
                            : 'Order #${delivery.id}',
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DeliveryStatusPill(status: delivery.orderStatus),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    [
                      delivery.customer.name,
                      if (delivery.delivery.address != null &&
                          delivery.delivery.address!.isNotEmpty)
                        delivery.delivery.address,
                    ].whereType<String>().join(' · '),
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(children: [
                    if (total > 0)
                      Text(ccy.format(total),
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall)),
                    if (total > 0)
                      Text(' · ',
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall)),
                    Text(_relativeTime(delivery.createdAt),
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall)),
                  ]),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
          ]),
        ),
      ),
    );
  }

  String _relativeTime(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d.toLocal());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 30) return '${diff.inDays}d';
    return DateFormat('d MMM').format(d.toLocal());
  }
}
